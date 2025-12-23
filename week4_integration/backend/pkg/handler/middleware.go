package handler

import (
	"context"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v4"
)

func (h *HttpServer) AdminOnly(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			http.Error(w, "Unauthorized: Invalid token format", http.StatusUnauthorized)
			return
		}
		tokenString := parts[1]

		token, _, err := new(jwt.Parser).ParseUnverified(tokenString, jwt.MapClaims{})
		if err != nil {
			http.Error(w, "Unauthorized: Bad token", http.StatusUnauthorized)
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			http.Error(w, "Unauthorized: Invalid claims", http.StatusUnauthorized)
			return
		}
		
		userIDStr, ok := claims["sub"].(string) 
		if !ok {
			http.Error(w, "Unauthorized: No user ID found in token", http.StatusUnauthorized)
			return
		}

		var role string
		err = h.DB.QueryRow(r.Context(), "SELECT role FROM users WHERE user_id = $1", userIDStr).Scan(&role)
		
		if err != nil {
			http.Error(w, "Forbidden: User not registered", http.StatusForbidden)
			return
		}

		if role != "admin" {
			http.Error(w, "Forbidden: You are not admin!", http.StatusForbidden)
			return
		}

		ctx := context.WithValue(r.Context(), "userID", userIDStr)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}