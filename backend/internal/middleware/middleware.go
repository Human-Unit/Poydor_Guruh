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
		claims, err := ParseToken(token)
		if err != nil {
			c.AbortWithStatusJSON(401, gin.H{"error": "Invalid or expired token"})
			return
		}

		customClaims := claims.(*CustomClaims)
		c.Set("userID", customClaims.UserID)
		c.Set("username", customClaims.Username)
		c.Set("userRole", customClaims.Role)
		c.Next()
	}
}

func AdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("userRole")
		if !exists || userRole != "admin" {
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
		secret := os.Getenv("JWT_SECRET")
		if secret == "" {
			secret = os.Getenv("SecretKey")
		}
		return []byte(secret), nil
	})
	if err != nil {
		return nil, err
	}
	return claims, nil
}

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
