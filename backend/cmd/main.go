package main

import (
	"app/internal/auth"
	"app/internal/db"
	"app/internal/handler"
	migrations "app/internal/migration"
	"app/internal/models"
	"app/internal/routes"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	godoenv "github.com/joho/godotenv"
)

func main() {
	// Load environment
	if err := godoenv.Load(); err != nil {
		log.Printf("Note: .env file not found, using system environment variables")
	}

	// Database connection
	log.Println("Initializing database connection...")
	database, err := db.DBConnect()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto migrate
	if err := migrations.MigrateUserTable(database); err != nil {
		log.Fatal("Migration failed:", err)
	}

	if err := database.AutoMigrate(&models.User{}, &models.Question{},
		&models.Category{}, &models.Lesson{}, &models.QuizResult{}); err != nil {
		log.Fatal("Failed to auto-migrate database:", err)
	}

	// Setup
	handler.SetDB(database)
	auth.SetDB(database)

	r := gin.Default()
	r.Use(gin.Recovery())
	routes.SetupRoutes(r)

	// Start server with configurable port
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
