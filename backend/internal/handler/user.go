package handler

import (
	"app/internal/models"

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
	if err := DB.Create(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create user"})
		return
	}
	c.JSON(201, gin.H{"status": "User created successfully", "user": user})
}
