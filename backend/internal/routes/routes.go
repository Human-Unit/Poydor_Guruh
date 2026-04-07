package routes

import (
	"app/internal/handler"
	"app/internal/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	// ========================
	// PUBLIC ROUTES
	// ========================
	r.POST("/users/register", handler.CreateUser)
	r.POST("/users/login", handler.LoginUser)

	// ========================
	// USER ROUTES (JWT required)
	// ========================
	user := r.Group("/users")
	user.Use(middleware.AuthMiddleware()) // JWT required
	{
		user.POST("/quiz/submit", handler.SubmitQuiz)

		// Get lessons and questions
		user.GET("/lessons", handler.GetLessons)
		user.GET("/lessons/:lesson_id/questions", handler.GetQuestionsByLessonID)
		user.POST("/quiz/submit", handler.SubmitQuiz)
		user.GET("/me/progress", handler.GetUserProgress)
	}

	// ========================
	// ADMIN ROUTES
	// ========================
	admin := r.Group("/admin")
	admin.Use(middleware.AuthMiddleware())  // JWT auth
	admin.Use(middleware.AdminMiddleware()) // Role check
	{
		// Categories
		admin.POST("/categories", handler.CreateCategory)
		admin.GET("/categories", handler.GetCategories)
		admin.PUT("/categories/:id", handler.UpdateCategory)
		admin.DELETE("/categories/:id", handler.DeleteCategory)

		// Lessons
		admin.POST("/lessons", handler.CreateLesson)
		admin.GET("/lessons", handler.GetLessons) // Can reuse GetLessons
		admin.PUT("/lessons/:id", handler.UpdateLesson)
		admin.DELETE("/lessons/:id", handler.DeleteLesson)

		// Questions
		admin.POST("/questions", handler.CreateQuestion)
		admin.PUT("/questions/:id", handler.UpdateQuestion)
		admin.DELETE("/questions/:id", handler.DeleteQuestion)

		// Users list
		admin.GET("/users", handler.GetUsers)
	}
}
