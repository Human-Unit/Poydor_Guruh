package handler

import (
	"app/internal/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Request payload from frontend
type SubmitQuizRequest struct {
	LessonID    uint   `json:"lesson_id" binding:"required"`
	Answers     []int  `json:"answers" binding:"required"` // index of selected options
	QuestionIDs []uint `json:"question_ids" binding:"required"`
}

// Submit quiz and store result
func SubmitQuiz(c *gin.Context) {
	var req SubmitQuizRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID := c.GetUint("userID") // set by AuthMiddleware

	// Fetch questions
	var questions []models.Question
	if err := DB.Where("id IN ?", req.QuestionIDs).Find(&questions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch questions"})
		return
	}

	// Calculate score
	correct := 0
	for i, q := range questions {
		if len(req.Answers) > i && req.Answers[i] == q.CorrectAnswer {
			correct++
		}
	}

	// Save result
	result := models.QuizResult{
		UserID:   userID,
		LessonID: req.LessonID,
		Score:    correct,
		Total:    len(questions),
	}
	if err := DB.Create(&result).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save quiz result"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"score":   correct,
		"total":   len(questions),
		"message": "Quiz submitted successfully",
	})
}

// Get user progress
func GetUserProgress(c *gin.Context) {
	userID := c.GetUint("userID") // set by AuthMiddleware

	type LessonStats struct {
		LessonID     uint
		TotalQuizzes int64
		AverageScore float64
		BestScore    int
	}

	var stats []LessonStats
	DB.Model(&models.QuizResult{}).
		Select("lesson_id, COUNT(*) as total_quizzes, AVG(score) as average_score, MAX(score) as best_score").
		Where("user_id = ?", userID).
		Group("lesson_id").
		Scan(&stats)

	c.JSON(http.StatusOK, stats)
}
