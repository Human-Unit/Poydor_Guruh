package handler

import (
	"app/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Middleware helper: check if user is admin
func isAdmin(c *gin.Context) bool {
	userRole, exists := c.Get("userRole") // assuming JWT middleware sets this
	if !exists || userRole != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Admin access required"})
		return false
	}
	return true
}

///////////////////////////////
// CATEGORY HANDLERS
///////////////////////////////

func CreateCategory(c *gin.Context) {
	if !isAdmin(c) {
		return
	}

	var req models.CreateCategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	category := models.Category{Name: req.Name}
	if err := DB.Create(&category).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create category"})
		return
	}

	c.JSON(http.StatusCreated, category)
}

func GetCategories(c *gin.Context) {
	var categories []models.Category
	if err := DB.Find(&categories).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get categories"})
		return
	}
	c.JSON(http.StatusOK, categories)
}

func UpdateCategory(c *gin.Context) {
	if !isAdmin(c) {
		return
	}

	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid category ID"})
		return
	}

	var req models.CreateCategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var category models.Category
	if err := DB.First(&category, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Category not found"})
		return
	}

	category.Name = req.Name
	if err := DB.Save(&category).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update category"})
		return
	}

	c.JSON(http.StatusOK, category)
}

func DeleteCategory(c *gin.Context) {
	if !isAdmin(c) {
		return
	}

	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid category ID"})
		return
	}

	// Optional: check if lessons exist
	var count int64
	DB.Model(&models.Lesson{}).Where("category_id = ?", id).Count(&count)
	if count > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot delete category with lessons"})
		return
	}

	if err := DB.Delete(&models.Category{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete category"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Category deleted successfully"})
}

///////////////////////////////
// LESSON HANDLERS
///////////////////////////////

func GetLessons(c *gin.Context) {
	var lessons []models.Lesson
	if err := DB.Preload("Category").Find(&lessons).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get lessons"})
		return
	}
	c.JSON(http.StatusOK, lessons)
}

func UpdateLesson(c *gin.Context) {
	if !isAdmin(c) {
		return
	}

	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid lesson ID"})
		return
	}

	var req models.CreateLessonRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var lesson models.Lesson
	if err := DB.First(&lesson, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Lesson not found"})
		return
	}

	// Check category exists
	var category models.Category
	if err := DB.First(&category, req.CategoryID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Category not found"})
		return
	}

	lesson.Name = req.Name
	lesson.CategoryID = req.CategoryID

	if err := DB.Save(&lesson).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update lesson"})
		return
	}

	c.JSON(http.StatusOK, lesson)
}

func DeleteLesson(c *gin.Context) {
	if !isAdmin(c) {
		return
	}

	idParam := c.Param("id")
	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid lesson ID"})
		return
	}

	// Optional: cascade delete questions
	if err := DB.Where("lesson_id = ?", id).Delete(&models.Question{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete questions"})
		return
	}

	if err := DB.Delete(&models.Lesson{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete lesson"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Lesson deleted successfully"})
}
