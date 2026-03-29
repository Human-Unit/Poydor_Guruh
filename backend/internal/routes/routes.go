package routes

import (
	"app/internal/handler"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	r.POST("/users", handler.CreateUser)
}
