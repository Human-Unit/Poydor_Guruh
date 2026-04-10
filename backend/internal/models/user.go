package models

import (
	"gorm.io/gorm"
)

type Role string

const (
	RoleUser  Role = "user"
	RoleAdmin Role = "admin"
)

type User struct {
	Name         string `gorm:"default:'unknown';not null" json:"name"`
	Username     string `gorm:"unique;not null" json:"username"`
	Email        string `gorm:"unique;not null" json:"email"`
	PasswordHash string `gorm:"not null" json:"password"` // Mapped from 'password' in JSON
	Role         Role   `gorm:"type:varchar(10);default:'user'" json:"role"`
	gorm.Model
}
