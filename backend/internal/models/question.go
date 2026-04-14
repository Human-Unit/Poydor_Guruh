package models

import (
)

type Question struct {
	ID        uint     `gorm:"primaryKey" json:"id"`
	LessonID  uint     `json:"lesson_id"`
	Lesson    *Lesson  `json:"lesson,omitempty"`
	Text      string   `gorm:"not null" json:"text"`
	OptionA   string   `gorm:"not null" json:"option_a"`
	OptionB   string   `gorm:"not null" json:"option_b"`
	OptionC   string   `gorm:"not null" json:"option_c"`
	OptionD   string   `gorm:"not null" json:"option_d"`
	Explanation string  `json:"explanation,omitempty"`
	CorrectAnswer int    `gorm:"not null" json:"correct_answer"`
}

type QuizResult struct {
	ID        uint `gorm:"primaryKey" json:"id"`
	UserID    uint `gorm:"not null" json:"user_id"`
	LessonID  uint `gorm:"not null" json:"lesson_id"`
	Score     int  `gorm:"not null" json:"score"`
	Total     int  `gorm:"not null" json:"total"`
}

type Answer struct {
	ID             uint       `gorm:"primaryKey" json:"id"`
	QuizResultID   uint       `json:"quiz_result_id"`
	QuizResult     QuizResult `json:"-"`
	QuestionID     uint       `json:"question_id"`
	Question       Question   `json:"question,omitempty"`
	SelectedAnswer int        `json:"selected_answer"`
	IsCorrect      bool       `json:"is_correct"`
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
