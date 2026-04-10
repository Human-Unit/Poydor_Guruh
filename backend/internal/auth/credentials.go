package auth

import (
	"app/internal/models"
	"regexp"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func HashPassword(password string) (string, error) {
	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.MinCost)
	return string(hashedBytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func RegexEmail(email string) bool {
	// Simple regex for email validation
	re := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	matched, _ := regexp.MatchString(re, email)
	return matched
}

func IsExistsEmail(email string) bool {
	var User models.User
	if er := DB.Where("email = ?", email).First(&User).Error; er != nil {
		return false
	}
	return true
}

func IsExistsUsername(username string) bool {
	var User models.User
	if er := DB.Where("username = ?", username).First(&User).Error; er != nil {
		return false
	}
	return true
}

func CredentialCheck(user models.User, c *gin.Context) (bool, gin.H) {
	if user.Email == "" || user.PasswordHash == "" {
		return false, gin.H{"error": "Email and password are required"}
	}
	if !RegexEmail(user.Email) {
		return false, gin.H{"error": "Invalid email format"}
	}
	if IsExistsEmail(user.Email) {
		return false, gin.H{"error": "Email already exists"}
	}
	if IsExistsUsername(user.Username) {
		return false, gin.H{"error": "Username already exists"}
	}
	return true, nil
}
