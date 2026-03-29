package main

import (
	"app/internal/db"
	"app/internal/handler"
	"app/internal/models"
	"app/internal/routes"
	"log"

	"github.com/gin-gonic/gin"
	godoenv "github.com/joho/godotenv"
)

func main() {
	err := godoenv.Load()
	if err != nil {
		log.Printf("Note: .env file not found, using system environment variables")
	}
	log.Println("Initializing database connection...")
	db, err := db.DBConnect()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	if err := db.AutoMigrate(&models.User{}, &models.Question{}, &models.Category{}); err != nil {
		log.Fatal("Failed to auto-migrate database:", err)
	}
	handler.SetDB(db)
	r := gin.Default()
	r.Use(gin.Recovery())
	routes.SetupRoutes(r)
	// Define your routes and handlers here
	r.Run() // listen and serve on
}
