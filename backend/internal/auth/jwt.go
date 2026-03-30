package auth

import (
	"os"
	"time"

	"app/internal/models"

	"github.com/golang-jwt/jwt"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func getSecretKey() []byte {
	return []byte(os.Getenv("JWT_SECRET"))
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

func HashPassword(password string) (string, error) {
	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.MinCost)
	return string(hashedBytes), err
}

func CheckPasswordHash(password, email string) bool {
	var User models.User
	if er := DB.Where("email = ?", email).First(&User).Error; er != nil {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(User.PasswordHash), []byte(password))
	return err == nil
}
