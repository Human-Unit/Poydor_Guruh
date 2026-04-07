package handler

import (
	"app/internal/middleware"
	"app/internal/models"

	"app/internal/auth"

	"strconv"

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
	if valid, errData := auth.CredentialCheck(user, c); !valid {
		c.JSON(400, errData)
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
	token, err := auth.CreateToken(user.ID, user.Username, "user")
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to generate token"})
		return
	}
	c.JSON(201, gin.H{
		"role":  "user",
		"token": token,
	})
}

func ListLessons(c *gin.Context) {
	var lessons []models.Lesson
	if err := DB.Preload("Category").Find(&lessons).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to retrieve lessons"})
		return
	}
	c.JSON(200, lessons)
}

func ListQuestions(c *gin.Context) {
	lessonIDParam := c.Param("lesson_id")
	lessonID, err := strconv.ParseUint(lessonIDParam, 10, 64)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid lesson ID"})
		return
	}
	var questions []models.Question
	if err := DB.Where("lesson_id = ?", lessonID).Find(&questions).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to retrieve questions"})
		return
	}
	c.JSON(200, questions)
}
