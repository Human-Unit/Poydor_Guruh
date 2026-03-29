package models

import (
	"gorm.io/gorm"
)

type Question struct {
	ID   uint   `gorm:"primaryKey"`
	Text string `gorm:"not null"`

	OptionA string
	OptionB string
	OptionC string
	OptionD string

	CorrectAnswer int // 0,1,2,3

	CategoryID uint
	Category   Category
	gorm.Model
}
