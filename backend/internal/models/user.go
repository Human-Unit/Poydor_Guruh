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
	Email        string `gorm:"unique;not null"`
	PasswordHash string `gorm:"not null"`
	Role         Role   `gorm:"type:varchar(10);default:'user'"`
	gorm.Model
}
