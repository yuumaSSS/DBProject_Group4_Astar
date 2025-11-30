package handler

import (
	"context"
	"database/sql"
	"fmt"

	"backend/internal/app/admindb"
	"backend/internal/app/publicdb"
	"backend/pb"

	"github.com/jackc/pgx/v5/pgtype"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type astar struct {
	pb.UnimplementedStorefrontServiceServer
	pb.UnimplementedAdminServiceServer

	DB      *sql.DB
	PublicQ *publicdb.Queries
	AdminQ  *admindb.Queries
}

func Newastar(db *sql.DB) *astar {
	return &astar{
		DB:      db,
		PublicQ: publicdb.New(db),
		AdminQ:  admindb.New(db),
	}
}

// Web

func (s *astar) ListAvailableProducts(ctx context.Context, _ *pb.Empty) (*pb.ProductListResponse, error) {
	products, err := s.PublicQ.ListAvailableProducts(ctx)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal mengambil data produk: %v", err)
	}

	var pbProducts []*pb.Product
	for _, p := range products {
		price, _ := p.UnitPrice.Float64Value()

		pbProducts = append(pbProducts, &pb.Product{
			Id:       p.ProductID,
			Name:     p.ProductName,
			Category: p.Category,
			Price:    price.Float64,
			ImageUrl: p.ImageUrl,
			Stock:    p.Stock,
		})
	}

	return &pb.ProductListResponse{Products: pbProducts}, nil
}

func (s *astar) GetProductDetail(ctx context.Context, req *pb.ProductIDRequest) (*pb.ProductDetailResponse, error) {
	p, err := s.PublicQ.GetProductDetail(ctx, req.Id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, status.Error(codes.NotFound, "Produk tidak ditemukan")
		}
		return nil, status.Errorf(codes.Internal, "DB Error: %v", err)
	}

	price, _ := p.UnitPrice.Float64Value()

	return &pb.ProductDetailResponse{
		Product: &pb.Product{
			Id:          p.ProductID,
			Name:        p.ProductName,
			Category:    p.Category,
			Description: p.Description,
			Price:       price.Float64,
			ImageUrl:    p.ImageUrl,
			Stock:       p.Stock,
		},
	}, nil
}

// Mobile

func (s *astar) ListAllProducts(ctx context.Context, _ *pb.Empty) (*pb.ProductListResponse, error) {
	products, err := s.AdminQ.ListAllProductsAdmin(ctx)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal fetch products: %v", err)
	}

	var pbProducts []*pb.Product
	for _, p := range products {
		price, _ := p.UnitPrice.Float64Value()
		pbProducts = append(pbProducts, &pb.Product{
			Id:       p.ProductID,
			Name:     p.ProductName,
			Category: p.Category,
			Price:    price.Float64,
			ImageUrl: p.ImageUrl,
			Stock:    p.Stock,
		})
	}
	return &pb.ProductListResponse{Products: pbProducts}, nil
}

func (s *astar) CreateProduct(ctx context.Context, req *pb.CreateProductRequest) (*pb.CreateProductResponse, error) {
	var priceNumeric pgtype.Numeric
	priceNumeric.Scan(fmt.Sprintf("%f", req.Price))

	arg := admindb.CreateProductParams{
		ProductName: req.Name,
		Category:    req.Category,
		Description: req.Description,
		UnitPrice:   priceNumeric,
		ImageUrl:    req.ImageUrl,
		Stock:       req.Stock,
	}

	id, err := s.AdminQ.CreateProduct(ctx, arg)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal create product: %v", err)
	}

	return &pb.CreateProductResponse{Id: id}, nil
}

func (s *astar) UpdateProduct(ctx context.Context, req *pb.UpdateProductRequest) (*pb.Empty, error) {
	var priceNumeric pgtype.Numeric
	priceNumeric.Scan(fmt.Sprintf("%f", req.Price))

	arg := admindb.UpdateProductParams{
		ProductID:   req.Id,
		ProductName: req.Name,
		Category:    req.Category,
		Description: req.Description,
		UnitPrice:   priceNumeric,
		ImageUrl:    req.ImageUrl,
		Stock:       req.Stock,
	}

	err := s.AdminQ.UpdateProduct(ctx, arg)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal update product: %v", err)
	}

	return &pb.Empty{}, nil
}

func (s *astar) DeleteProduct(ctx context.Context, req *pb.ProductIDRequest) (*pb.Empty, error) {
	err := s.AdminQ.DeleteProduct(ctx, req.Id)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal delete product: %v", err)
	}
	return &pb.Empty{}, nil
}

// Order management

func (s *astar) ListPendingOrders(ctx context.Context, _ *pb.Empty) (*pb.OrderListResponse, error) {
	orders, err := s.AdminQ.ListPendingOrders(ctx)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal fetch orders: %v", err)
	}

	var pbOrders []*pb.Order
	for _, o := range orders {
		total, _ := o.TotalAmount.Float64Value()

		custName := "Unknown"
		if o.CustomerName.Valid {
			custName = o.CustomerName.String
		}

		phone := "-"
		if o.PhoneNumber.Valid {
			phone = o.PhoneNumber.String
		}

		prodName := "Produk Terhapus"
		if o.ProductName.Valid {
			prodName = o.ProductName.String
		}

		imgUrl := ""
		if o.ImageUrl.Valid {
			imgUrl = o.ImageUrl.String
		}

		dateStr := ""
		if o.OrderDate.Valid {
			dateStr = o.OrderDate.Time.Format("2006-01-02 15:04")
		}

		pbOrders = append(pbOrders, &pb.Order{
			OrderId:      o.OrderID,
			CustomerName: custName,
			PhoneNumber:  phone,
			ProductName:  prodName,
			ImageUrl:     imgUrl,
			TotalAmount:  total.Float64,
			Quantity:     o.Quantity,
			Status:       o.Status,
			OrderDate:    dateStr,
		})
	}

	return &pb.OrderListResponse{Orders: pbOrders}, nil
}

func (s *astar) UpdateOrderStatus(ctx context.Context, req *pb.UpdateStatusRequest) (*pb.Empty, error) {
	tx, err := s.DB.Begin()
	if err != nil {
		return nil, status.Error(codes.Internal, "Gagal memulai transaksi DB")
	}
	defer tx.Rollback()

	qtx := s.AdminQ.WithTx(tx)

	err = qtx.UpdateOrderStatus(ctx, admindb.UpdateOrderStatusParams{
		OrderID: req.OrderId,
		Status:  req.Status,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "Gagal update status: %v", err)
	}

	if req.Status == "paid" {
		orderInfo, err := qtx.GetOrderQuantityAndProduct(ctx, req.OrderId)
		if err != nil {
			return nil, status.Errorf(codes.NotFound, "Order info tidak ditemukan: %v", err)
		}

		err = qtx.DecreaseProductStock(ctx, admindb.DecreaseProductStockParams{
			ProductID: orderInfo.ProductID,
			Stock:     orderInfo.Quantity,
		})
		if err != nil {
			return nil, status.Errorf(codes.Aborted, "Gagal mengurangi stok (Mungkin stok habis): %v", err)
		}
	}

	if err := tx.Commit(); err != nil {
		return nil, status.Error(codes.Internal, "Gagal commit transaksi")
	}

	return &pb.Empty{}, nil
}