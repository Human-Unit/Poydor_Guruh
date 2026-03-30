package middleware

import (
	"app/internal/auth"
	"os"
)

func IsAdmin(username, password string) (bool, string) {

	adminPassword := os.Getenv("ADMIN_PASSWORD")
	if adminPassword == "" {
		return false, "Admin password not set"
	}
	if username == "admin" && password == adminPassword {
		token, err := auth.CreateAdminToken("admin")
		if err != nil {
			return false, "Failed to create admin token"
		}
		return true, token
	}
	return false, "Invalid admin credentials"
}
