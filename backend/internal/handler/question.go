package handler

import (
	"app/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// CreateQuestion creates a new question for a lesson
func CreateQuestion(c *gin.Context) {
	var req models.CreateQuestionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check lesson exists
	var lesson models.Lesson
	if err := DB.First(&lesson, req.LessonID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Lesson not found"})
		return
	}

	// Create question safely
	question := models.Question{
		LessonID:      req.LessonID,
		Text:          req.Text,
		OptionA:       req.OptionA,
		OptionB:       req.OptionB,
		OptionC:       req.OptionC,
		OptionD:       req.OptionD,
		CorrectAnswer: req.CorrectAnswer,
	}

	if err := DB.Create(&question).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create question"})
		return
	}

	// Return clean response
	c.JSON(http.StatusCreated, gin.H{
		"id":             question.ID,
		"lesson_id":      question.LessonID,
		"text":           question.Text,
		"option_a":       question.OptionA,
		"option_b":       question.OptionB,
		"option_c":       question.OptionC,
		"option_d":       question.OptionD,
		"correct_answer": question.CorrectAnswer,
	})
}

// GetQuestionsByLessonID returns all questions of a lesson
func GetQuestionsByLessonID(c *gin.Context) {
	lessonIDParam := c.Param("lesson_id")
	lessonID, err := strconv.ParseUint(lessonIDParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid lesson ID"})
		return
	}

	// Optional: check lesson exists
	var lesson models.Lesson
	if err := DB.First(&lesson, lessonID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Lesson not found"})
		return
	}

	var questions []models.Question
	if err := DB.Where("lesson_id = ?", lessonID).Find(&questions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve questions"})
		return
	}

	c.JSON(http.StatusOK, questions)
}

// GetQuestions returns all questions (admin)
func GetQuestions(c *gin.Context) {
	var questions []models.Question
	if err := DB.Preload("Lesson").Find(&questions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve questions"})
		return
	}

	c.JSON(http.StatusOK, questions)
}

// DeleteQuestion deletes a question by ID
func DeleteQuestion(c *gin.Context) {
	questionIDParam := c.Param("id")
	questionID, err := strconv.ParseUint(questionIDParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid question ID"})
		return
	}

	result := DB.Delete(&models.Question{}, questionID)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete question"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Question not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Question deleted successfully"})
}

// UpdateQuestion updates an existing question
func UpdateQuestion(c *gin.Context) {
	questionIDParam := c.Param("id")
	questionID, err := strconv.ParseUint(questionIDParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid question ID"})
		return
	}

	var req models.CreateQuestionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var question models.Question
	if err := DB.First(&question, questionID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Question not found"})
		return
	}

	// Update fields
	question.LessonID = req.LessonID
	question.Text = req.Text
	question.OptionA = req.OptionA
	question.OptionB = req.OptionB
	question.OptionC = req.OptionC
	question.OptionD = req.OptionD
	question.CorrectAnswer = req.CorrectAnswer

	if err := DB.Save(&question).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update question"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"id":             question.ID,
		"lesson_id":      question.LessonID,
		"text":           question.Text,
		"option_a":       question.OptionA,
		"option_b":       question.OptionB,
		"option_c":       question.OptionC,
		"option_d":       question.OptionD,
		"correct_answer": question.CorrectAnswer,
	})
}

// SubmitQuiz evaluates a submitted quiz (minimal working logic)
