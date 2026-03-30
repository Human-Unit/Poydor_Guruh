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
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}
	if user.Email == "" || user.PasswordHash == "" {
		c.JSON(400, gin.H{"error": "Email and password are required"})
		return
	}
	user.PasswordHash, _ = auth.HashPassword(user.PasswordHash)
	if err := DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create user"})
		return
	}
	c.JSON(201, gin.H{"status": "User created successfully", "user": user})
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

	isadmin, token := middleware.IsAdmin(req.Username, req.Password)
	if isadmin {
		if token != "" {
			c.JSON(201, gin.H{
				"role":  "admin",
				"token": token,
			})
		}

	}

	var user models.User
	if err := DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(401, gin.H{"error": "Invalid email or password"})
		return
	}
	if !auth.CheckPasswordHash(req.Password, user.Email) {
		c.JSON(401, gin.H{"error": "Invalid email or password"})
		return
	}
	c.JSON(200, gin.H{"status": "Login successful", "user": user})
}
