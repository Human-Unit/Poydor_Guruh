package handler

import (
	"app/internal/middleware"
	"app/internal/models"

	"app/internal/auth"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

var DB *gorm.DB

func SetDB(database *gorm.DB) {
	DB = database
}

func CreateUser(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request format"})
		return
	}

	// Validate credentials (duplicates, email format, etc.)
	if valid, errData := auth.CredentialCheck(user, c); !valid {
		c.JSON(400, errData)
		return
	}

	// Hash the password before saving
	hashedPassword, err := auth.HashPassword(user.PasswordHash)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to hash password"})
		return
	}
	user.PasswordHash = hashedPassword

	// Save user to database
	if err := DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(201, gin.H{
		"status": "User created successfully",
		"user": gin.H{
			"id":       user.ID,
			"name":     user.Name,
			"username": user.Username,
			"email":    user.Email,
		},
	})
}

func LoginUser(c *gin.Context) {
	var req struct {
		Email    string `json:"email"`
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}
	if req.Email == "" || req.Password == "" {
		c.JSON(400, gin.H{"error": "Email and password are required"})
		return
	}

	// Check if admin login by entering 'admin' in email field
	usernameForAdmin := req.Username
	if req.Email == "admin" {
		usernameForAdmin = "admin"
	}

	isAdmin, token := middleware.IsAdmin(usernameForAdmin, req.Password)
	if isAdmin {
		c.JSON(200, gin.H{
			"role":  "admin",
			"token": token,
		})
		return
	}

	var user models.User
	if err := DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(401, gin.H{"error": "Invalid email or password"})
		return
	}
	if !auth.CheckPasswordHash(req.Password, user.PasswordHash) {
		c.JSON(401, gin.H{"error": "Invalid email or password"})
		return
	}
	token, err := auth.CreateToken(user.ID, user.Username, "user")
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to generate token"})
		return
	}
	c.JSON(200, gin.H{
		"role":  "user",
		"token": token,
	})
}
