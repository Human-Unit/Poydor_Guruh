package middleware

import (
	"app/internal/auth"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
)

type CustomClaims struct {
	UserID   uint   `json:"user_id"`
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.StandardClaims
}

func IsAdmin(username, password string) (bool, string) {

	adminPassword := os.Getenv("ADMIN_PASSWORD")
	if adminPassword == "" {
		return false, "Admin password not set"
	}
	if username == "admin" && password == adminPassword {
		token, err := auth.CreateAdminToken("admin")
		if err != nil {
			return false, "Failed to create admin token"
		}
		return true, token
	}
	return false, "Invalid admin credentials"
}

func ExtractToken(c *gin.Context) string {
	authHeader := c.GetHeader("Authorization")
	if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
		return strings.TrimPrefix(authHeader, "Bearer ")
	}
	return authHeader
}

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := ExtractToken(c)
		if token == "" {
			c.AbortWithStatusJSON(401, gin.H{"error": "Authorization token required"})
			return
		}
		valid, err := ValidateToken(token)
		if !valid || err != nil {
			c.AbortWithStatusJSON(401, gin.H{"error": "Invalid or expired token"})
			return
		}
	}
}

func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := ExtractToken(c)
		if token == "" {
			c.AbortWithStatusJSON(401, gin.H{"error": "Authorization token required"})
			return
		}
		validation, err := ValidateAdminToken(token)
		if !validation || err != nil {
			c.AbortWithStatusJSON(403, gin.H{"error": "Admin privileges required"})
			return
		}
		c.Next()
	}
}

func ValidateToken(token string) (bool, error) {
	_, err := ParseToken(token)
	if err != nil {
		return false, err
	}
	return true, nil
}

func ValidateAdminToken(token string) (bool, error) {
	claims, err := ParseToken(token)
	if err != nil {
		return false, err
	}
	if claims.(*CustomClaims).Role != "admin" {
		return false, nil
	}
	return true, nil
}

func ParseToken(token string) (jwt.Claims, error) {
	claims := &CustomClaims{}
	_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv("JWT_SECRET")), nil
	})
	if err != nil {
		return nil, err
	}
	return claims, nil
}
