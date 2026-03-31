package models

import "gorm.io/gorm"

type Category struct {
	ID   uint   `gorm:"primaryKey"`
	Name string `gorm:"unique;not null"`

	Questions []Question
}

type Lesson struct {
	gorm.Model
	topics []Topic
}

type Topic struct {
	gorm.Model
	topicname string
	questions []Question
	videoURL  string
	chapters  []Chapter
}

type Chapter struct {
	gorm.Model
	chaptername string
	videoURL    string
	questions   []Question
}
