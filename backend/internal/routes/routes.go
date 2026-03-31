package routes

import (
	"app/internal/handler"
	"app/internal/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	user := r.Group("/users")
	user.POST("/register", handler.CreateUser)
	user.POST("/login", handler.LoginUser)

	admin := r.Group("/admin")
	admin.Use(middleware.AdminMiddleware())
}
