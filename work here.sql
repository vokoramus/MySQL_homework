-- таблица типа Archive для логов изменений песен
DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs` (
	`datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `song_id` VARCHAR(255) NOT NULL,
    `user_id` VARCHAR(255) NOT NULL
    ) ENGINE=Archive;

-- триггер логирования при внесении изменений в подбор (песню)
DROP TRIGGER IF EXISTS logging_update;
DELIMITER //
CREATE TRIGGER logging_update AFTER UPDATE ON songs
FOR EACH ROW
	BEGIN
		INSERT INTO `logs` VALUES 
			(now(), NEW.id, NEW.author_id);
	END//
DELIMITER ;

