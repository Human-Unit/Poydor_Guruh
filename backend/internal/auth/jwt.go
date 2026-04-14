package auth

import (
	"github.com/golang-jwt/jwt"
	"gorm.io/gorm"
	"os"
	"time"
)

func getSecretKey() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = os.Getenv("SecretKey")
	}
	return []byte(secret)
}

type CustomClaims struct {
	UserID   uint   `json:"user_id"`
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.StandardClaims
}

var DB *gorm.DB

func SetDB(database *gorm.DB) {
	DB = database
}

func CreateToken(userID uint, username string, role string) (string, error) {
	claims := CustomClaims{
		UserID:   userID,
		Username: username,
		Role:     role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(time.Hour * 24).Unix(),
			IssuedAt:  time.Now().Unix(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	if err := token.Claims.Valid(); err != nil {
		return "", err
	}
	return token.SignedString(getSecretKey())
}

func CreateAdminToken(role string) (string, error) {
	claims := CustomClaims{
		Role: role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Add(time.Hour * 24).Unix(),
			IssuedAt:  time.Now().Unix(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	if err := token.Claims.Valid(); err != nil {
		return "", err
	}
	return token.SignedString(getSecretKey())
}
