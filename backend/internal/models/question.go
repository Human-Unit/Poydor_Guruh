package models

import (
	"gorm.io/gorm"
)

type Question struct {
	gorm.Model

	LessonID uint
	Lesson   Lesson

	Text string `gorm:"not null"`

	OptionA string `gorm:"not null"`
	OptionB string `gorm:"not null"`
	OptionC string `gorm:"not null"`
	OptionD string `gorm:"not null"`

	Explanation string

	CorrectAnswer int `gorm:"not null"` // 0,1,2,3
}

type QuizResult struct {
	gorm.Model

	UserID   uint `gorm:"not null"`
	LessonID uint `gorm:"not null"`
	Score    int  `gorm:"not null"` // e.g., 7 out of 10
	Total    int  `gorm:"not null"` // total questions in quiz
}

type Answer struct {
	gorm.Model

	QuizResultID uint
	QuizResult   QuizResult

	QuestionID uint
	Question   Question

	SelectedAnswer int
	IsCorrect      bool
}

type CreateQuestionRequest struct {
	LessonID uint   `json:"lesson_id" binding:"required"`
	Text     string `json:"text" binding:"required"`

	OptionA string `json:"option_a" binding:"required"`
	OptionB string `json:"option_b" binding:"required"`
	OptionC string `json:"option_c" binding:"required"`
	OptionD string `json:"option_d" binding:"required"`

	CorrectAnswer int `json:"correct_answer" binding:"required,min=0,max=3"`
}

type SubmitQuizRequest struct {
	Answers []struct {
		QuestionID     uint `json:"question_id"`
		SelectedAnswer int  `json:"selected_answer"`
	} `json:"answers"`
}
