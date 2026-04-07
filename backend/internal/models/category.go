package models

import "gorm.io/gorm"

type Category struct {
	ID   uint   `gorm:"primaryKey"`
	Name string `gorm:"unique;not null"`

	Lessons []Lesson
}

type Lesson struct {
	gorm.Model

	Name string `gorm:"not null"`

	CategoryID uint
	Category   Category

	Questions []Question
}
type CreateLessonRequest struct {
	Name       string `json:"name" binding:"required"`
	CategoryID uint   `json:"category_id" binding:"required"`
}

type CreateCategoryRequest struct {
	Name string `json:"name" binding:"required"`
}
