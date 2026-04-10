package migrations

import (
	"app/internal/models"

	"gorm.io/gorm"
)

func MigrateUserTable(db *gorm.DB) error {
	// Check if column exists
	if !db.Migrator().HasColumn(&models.User{}, "name") {

		// 1. Add column as nullable
		if err := db.Exec(`ALTER TABLE users ADD COLUMN name TEXT`).Error; err != nil {
			return err
		}

		// 2. Fill NULL values safely
		if err := db.Exec(`
			UPDATE users
			SET name = 'user_' || id
			WHERE name IS NULL
		`).Error; err != nil {
			return err
		}

		// 3. Set NOT NULL constraint
		if err := db.Exec(`
			ALTER TABLE users
			ALTER COLUMN name SET NOT NULL
		`).Error; err != nil {
			return err
		}
	}

	return nil
}
