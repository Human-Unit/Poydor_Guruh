package handler

import (
	"app/internal/models"

	"github.com/gin-gonic/gin"
)

func GetUsers(c *gin.Context) {
	var users []models.User
	if err := DB.Find(&users).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to retrieve users"})
		return
	}
	c.JSON(200, users)
}

func CreateLesson(c *gin.Context) {
	var req models.CreateLessonRequest

	// 1. Bind + validate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// 2. Check category exists
	var category models.Category
	if err := DB.First(&category, req.CategoryID).Error; err != nil {
		c.JSON(404, gin.H{"error": "Category not found"})
		return
	}

	// 3. Create lesson safely
	lesson := models.Lesson{
		Name:       req.Name,
		CategoryID: req.CategoryID,
	}

	if err := DB.Create(&lesson).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create lesson"})
		return
	}

	// 4. Return clean response
	c.JSON(201, gin.H{
		"id":          lesson.ID,
		"name":        lesson.Name,
		"category_id": lesson.CategoryID,
	})
}
