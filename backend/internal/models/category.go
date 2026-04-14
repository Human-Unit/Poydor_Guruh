package models



type Category struct {
	ID   uint   `gorm:"primaryKey" json:"id"`
	Name string `gorm:"unique;not null" json:"name"`

	Lessons []Lesson `json:"lessons,omitempty"`
}

type Lesson struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Name      string         `gorm:"not null" json:"name"`
	CategoryID uint           `json:"category_id"`
	Category   Category       `json:"category,omitempty"`
	Questions  []Question     `json:"questions,omitempty"`
	CreatedAt  string         `json:"created_at,omitempty"`
}
type CreateLessonRequest struct {
	Name       string `json:"name" binding:"required"`
	CategoryID uint   `json:"category_id" binding:"required"`
}

type CreateCategoryRequest struct {
	Name string `json:"name" binding:"required"`
}
