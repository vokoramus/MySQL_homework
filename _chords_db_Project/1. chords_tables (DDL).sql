/*
БД задумана как предполагаемый аналог БД сайта AmDm.ru 

    Основной функционал сайта AmDm.ru:
Содержит базу текстов песен с аккордами.

Есть раздел "Вопросы & Ответы" - Все пользователи могут просматривать все сообщения (вопросы, ответы), 
зарегистрированные пользователи могут писать сообщения (вопросы, ответы).

Пользователи могут просматривать, добавлять новые тексты песен.
Пользователи могут добавлять в избранное: песни, исполнителей, других пользователей, 
подписываться на сообщения в разделе Вопросы & Ответы

Каждая песня может содержать ссылку на видео / mp3 авторского исполнения данной песни

    Описание БД:
Разрабатываемая БД содержит таблицы, хранящие:
    - информацию о пользователях и их профилях
    - информацию об исполнителях
    - тексты песен
    - гитарные аппликатуры аккордов - для автоматической генерации используемых в песне аккордов 
    и отображения их гитарных аппликатур на странице песни
    - вопросы раздела "Вопросы & Ответы"
    - ответы на вопросы раздела "Вопросы & Ответы"
    - новости 

	Перечень таблиц:

Основные:
    - users (Пользователи)
    - users_resources (Ресурсы пользователей - сайты, соцсети)
    - profiles (Профили пользователей)
    - singers (Исполнители)
    - songs (Песни)

    - resources (Виды ресурсов пользователя)

    - chords (Аккорды)

    - questions (вопросы раздела "Вопросы & Ответы")
    - answers (ответы на вопросы раздела "Вопросы & Ответы")
    - news (новости)

таблицы для обеспечения связи многие-со-многими:
    - singers_songs (соответствие песен и исполнителей)
    - questions_categories (категории вопросов раздела "Вопросы & Ответы")
    - video_songs (соответствие ссылок на видео конкретным песням)
    - mp3_songs (соответствие ссылок на mp3 конкретным песням)

Медиа файлы, ссылки:
    - avatars
    - mp3
    - photo
    - video

Избранное/подписки:
    - user_questions_sign (Подписка пользователей на вопросы раздела "Вопросы & Ответы")
    - users_singers_fav (избранные исполнители пользователей)
    - users_songs_fav (избранные песни пользователей)
    - users_users_fav (избранные пользователи пользователей) 

Представления:
    - all_countries_list	(список всех стран пользователей)
    - all_regions_list		(список всех регионов пользователей)
    - all_cities_list 		(список всех городов пользователей)
*/


DROP DATABASE IF EXISTS chords_db;
CREATE DATABASE `chords_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE chords_db;


CREATE TABLE `mp3`(
 	id SERIAL,
	file_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE `video`(
 	id SERIAL,
	video_url VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `photo`(
 	id SERIAL,
	file_name VARCHAR(255) NOT NULL
);				

CREATE TABLE `avatars`(
 	id SERIAL,
	file_name VARCHAR(255) NOT NULL
);

-- SERIAL - псевдоним для BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE.
CREATE TABLE `singers` (
	id SERIAL,
	singer VARCHAR(50) NOT NULL UNIQUE,
    biography LONGTEXT,
    photo_id BIGINT UNSIGNED NOT NULL,
    first_letter CHAR(1) AS (SUBSTRING(singer, 1, 1)), 
	CONSTRAINT fk_singers_photo_id FOREIGN KEY(photo_id) REFERENCES photo(id),
    INDEX (singer)
);

CREATE TABLE `users`(
	id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	pseudo VARCHAR(50) NOT NULL UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL UNIQUE,
	password_hash CHAR(65) DEFAULT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	INDEX (pseudo),
	INDEX (email),
    CONSTRAINT email_check CHECK (email LIKE '%@%\\.%$')
);
-- ALTER TABLE `users` ADD CONSTRAINT email_check CHECK (email LIKE '%@%\\.%$');

CREATE TABLE `songs` (
	id SERIAL,
	`name` VARCHAR(50) NOT NULL,
    author_id BIGINT UNSIGNED NOT NULL,
    views_number BIGINT NOT NULL DEFAULT 0,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`text` LONGTEXT NOT NULL,
    author_comments TEXT,
	CONSTRAINT fk_songs_author FOREIGN KEY(author_id) REFERENCES users(id),
    INDEX (`name`)
--    INDEX (`text`) /* если нужен поиск по тексту песен */
);


CREATE TABLE `profiles`(
	user_id BIGINT UNSIGNED NOT NULL UNIQUE ,
	gender ENUM('f', 'm', 'x') NOT NULL,
	birthday DATE NOT NULL,
	avatar_id BIGINT UNSIGNED,
	country VARCHAR(50),
    region VARCHAR(50),
    city VARCHAR(50),
	about TEXT,
	send_daily BOOL DEFAULT 0, 
	send_weekly BOOL DEFAULT 0,
	dont_send BOOL DEFAULT 0,
	CONSTRAINT fk_profiles_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_profiles_avatar_id FOREIGN KEY(avatar_id) REFERENCES avatars(id)
);

CREATE TABLE `chords`(
	chord VARCHAR(15) NOT NULL UNIQUE,
	barre TINYINT(2),
	string_6 TINYINT(2),
	string_5 TINYINT(2),
	string_4 TINYINT(2),
	string_3 TINYINT(2),
	string_2 TINYINT(2),
	string_1 TINYINT(2),
	INDEX(chord)
);


CREATE TABLE `resources`(
	id SERIAL,
	resource_name VARCHAR(30) NOT NULL UNIQUE
);


CREATE TABLE `news`(
 	header TEXT NOT NULL,
	`date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `text` LONGTEXT NOT NULL,
    short_text_lenght INT NOT NULL,  -- (кол-во символов, отображаемых в краткой версии новости)
	short_text TEXT AS (concat(substring(`text`, 1, short_text_lenght), '...')),
	views_number BIGINT UNSIGNED NOT NULL DEFAULT 0
);
/* автостолбец short_text добавляю, чтобы при каждом запросе страницы с новостями БД 
не вытаскивала часть текста из `text`, а выдавала сразу готовое значение. Это увеличит размер БД, 
но новости появляются относительно редко и их суммарный размер гораздо меньше суммарного размера 
всех песен в БД */
-- ALTER TABLE `news` ADD COLUMN views_number BIGINT UNSIGNED NOT NULL DEFAULT 0;
-- ALTER TABLE `news` MODIFY COLUMN header TEXT NOT NULL;



CREATE TABLE `questions_categories`(
 	id SERIAL,
	`name` VARCHAR(50) NOT NULL UNIQUE,
    INDEX(`name`)
);


CREATE TABLE `questions`(
 	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	category_id BIGINT UNSIGNED NOT NULL,
    `text` LONGTEXT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	views_number BIGINT UNSIGNED NOT NULL DEFAULT 0,
	CONSTRAINT fk_questions_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_questions_questions_categories FOREIGN KEY(category_id) REFERENCES questions_categories(id)
);

CREATE TABLE `answers`(
 	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	question_id BIGINT UNSIGNED NOT NULL,
    `text` LONGTEXT NOT NULL,
	rating BIGINT UNSIGNED NOT NULL DEFAULT 0,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_answers_users FOREIGN KEY(user_id) REFERENCES users(id),
    CONSTRAINT fk_answers_questions FOREIGN KEY(question_id) REFERENCES questions(id)
);

-- связь многие-со-многими, т.к. одна песня может исполняться совместно несколькими исполнителями
CREATE TABLE `singers_songs`(
	singer_id BIGINT UNSIGNED NOT NULL,
	song_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_singers_songs_singers FOREIGN KEY(singer_id) REFERENCES singers(id),
	CONSTRAINT fk_singers_songs_songs FOREIGN KEY(song_id) REFERENCES songs(id),
	PRIMARY KEY(singer_id,song_id)
);


CREATE TABLE `users_resources`(
	user_id BIGINT UNSIGNED NOT NULL,
	resource_id BIGINT UNSIGNED NOT NULL,
	`name` VARCHAR(150) NOT NULL,
	CONSTRAINT fk_user_resources_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_user_resources_resources FOREIGN KEY(resource_id) REFERENCES resources(id)
);
-- alter table users_resources change column `name` `name` VARCHAR(150) NOT NULL;

CREATE TABLE `users_songs_fav`(
 	user_id BIGINT UNSIGNED NOT NULL,
	song_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_users_songs_fav_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_users_songs_fav_songs FOREIGN KEY(song_id) REFERENCES songs(id),
	PRIMARY KEY(user_id,song_id)
);

CREATE TABLE `users_singers_fav`(
 	user_id BIGINT UNSIGNED NOT NULL,
	singer_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_users_singers_fav_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_users_singers_fav_singers FOREIGN KEY(singer_id) REFERENCES singers(id),
	PRIMARY KEY(user_id,singer_id)
);
			
CREATE TABLE `users_users_fav`(
 	user_id BIGINT UNSIGNED NOT NULL,
	user_fav_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY(user_id,user_fav_id),
    CONSTRAINT fk_users_users_fav_users FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_users_users_fav_user_fav FOREIGN KEY(user_fav_id) REFERENCES users(id),
	CONSTRAINT users_not_self_fav CHECK(user_id != user_fav_id)
);					
	
CREATE TABLE `user_questions_sign`(
 	question_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_user_questions_sign_questions FOREIGN KEY(question_id) REFERENCES questions(id),
	CONSTRAINT fk_user_questions_sign_users FOREIGN KEY(user_id) REFERENCES users(id),
	PRIMARY KEY(question_id,user_id)
);


CREATE TABLE `mp3_songs`(
 	song_id BIGINT UNSIGNED NOT NULL,
	mp3_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_mp3_songs_song FOREIGN KEY(song_id) REFERENCES songs(id),
   	CONSTRAINT fk_mp3_songs_mp3 FOREIGN KEY(mp3_id) REFERENCES mp3(id),
	PRIMARY KEY(song_id,mp3_id)
);

CREATE TABLE `video_songs`(
 	song_id BIGINT UNSIGNED NOT NULL,
	video_id BIGINT UNSIGNED NOT NULL,
	CONSTRAINT fk_video_songs_song FOREIGN KEY(song_id) REFERENCES songs(id),
   	CONSTRAINT fk_video_songs_audio FOREIGN KEY(video_id) REFERENCES video(id),
    PRIMARY KEY(song_id,video_id)
);

-- таблица типа Archive для логов изменений песен 
-- (для записи служит триггер logging_update - см.ниже)
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

-- ============= ФУНКЦИИ =============

-- ФУНКЦИЯ ТОП-10 исполнителей по рейтингу
DROP FUNCTION IF EXISTS singer_rating;

DELIMITER //
CREATE FUNCTION singer_rating(for_singer BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE views_number_rating INT;
	DECLARE songs_rating INT;
	DECLARE singers_fav_rating INT;
	
	-- посчитаем views_number_rating через SET
	SET views_number_rating = (
		SELECT sum(s.views_number) sum
			FROM singers_songs ss
			JOIN songs s ON s.id = ss.song_id
			GROUP BY ss.singer_id
			HAVING ss.singer_id = for_singer
		);

	-- посчитаем songs_rating через SET
	SET songs_rating = (
		SELECT count(*) song_fav
			FROM singers_songs ss
			RIGHT JOIN users_songs_fav us ON us.song_id = ss.song_id
			WHERE ss.singer_id = for_singer
			GROUP BY ss.singer_id
		);

	-- посчитаем singers_fav через SELECT INTO
    SELECT count(*) singer_fav INTO singers_fav_rating 
		FROM users_singers_fav usg
		GROUP BY usg.singer_id
		HAVING usg.singer_id = for_singer
        ;

	RETURN views_number_rating + (songs_rating * 10) + (singers_fav_rating * 50);
END//
DELIMITER ;

-- ТОП-10 пользователей по рейтингу

DROP FUNCTION IF EXISTS user_rating;

DELIMITER //
CREATE FUNCTION user_rating(for_user BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA
BEGIN

	DECLARE songs_ INT;				/* 1. кол-во выложенных им песен  */
	DECLARE users_fav_self_ INT;	/* 2. если ему лайк */
	DECLARE questions_ INT;			/* 3. если задал вопрос на форуме */
	DECLARE answers_ INT;			/* 4. если ответил на вопрос на форуме */
	DECLARE users_fav_others_ INT;	/* 5. за каждый лайк другого юзера */
	DECLARE songs_fav_ INT;			/* 6. за каждый лайк песни */
	DECLARE singers_fav_ INT;		/* 7. за каждый лайк исполнителя */
    
	SET songs_ = 			(SELECT count(*) FROM songs WHERE author_id = for_user);
	SET users_fav_self_ = 	(SELECT count(*) FROM users_users_fav WHERE user_fav_id = for_user);
    SET questions_ = 		(SELECT count(*) FROM questions WHERE user_id = for_user);
    SET answers_ = 			(SELECT count(*) FROM answers WHERE user_id = for_user);
    SET users_fav_others_ = (SELECT count(*) FROM users_users_fav WHERE user_id = for_user);
    SET songs_fav_ = 		(SELECT count(*) FROM users_songs_fav WHERE user_id = for_user);
    SET singers_fav_ = 		(SELECT count(*) FROM users_singers_fav WHERE user_id = for_user);

	RETURN 
		(songs_ * 10) + 
        (users_fav_self_ * 5) +
		(questions_ * 3) + 
        (answers_ * 2) +
		(users_fav_others_ * 1) + 
        (songs_fav_ * 1) +
		(singers_fav_ * 1)
        ;
END//
DELIMITER ;


-- ============= ПРЕДСТАВЛЕНИЯ =============
CREATE OR REPLACE VIEW `all_countries_list` (countries_list) AS
	SELECT DISTINCT country 
		FROM `profiles` 
        WHERE country IS NOT NULL 
        ORDER BY country
;

CREATE OR REPLACE VIEW `all_regions_list` AS
	SELECT DISTINCT concat(region, ' (', country, ')') region
		FROM profiles 
        WHERE region IS NOT NULL 
        ORDER BY region
;

CREATE OR REPLACE VIEW `all_cities_list` AS
	SELECT DISTINCT concat(city, ' (', region, ', ', country, ')') city
		FROM profiles 
        WHERE city IS NOT NULL 
        ORDER BY city
;


-- ============= ПРОЦЕДУРЫ =============

-- список исполнителей по заданной первой букве (+ инфо: кол-во подборов (песен), всего просмотров песен
-- для каждого исполнителя)
DROP PROCEDURE IF EXISTS singers_list;
DELIMITER //
CREATE PROCEDURE singers_list(`char` CHAR(1), max_rows_ INT)
BEGIN
	SELECT * FROM (
		SELECT 
			s.singer 
--             , sn.`name`
--             , sn.views_number
           , count(sn.`name`) 'songs total' 
           , sum(sn.views_number) 'views number'
			FROM singers s
	-- всего подборов
			JOIN singers_songs ss
				ON s.id = ss.singer_id
			RIGHT JOIN songs sn
				ON sn.id = ss.song_id
	-- всего просмотров
		
			WHERE `first_letter` = `char`
 			GROUP BY s.singer	
			ORDER BY s.singer ASC
		) dummy
		LIMIT max_rows_;

END //
DELIMITER ;


-- список песен исполнителя (+ инфо: дата создания, есть ли видео, кол-во просмотров)
DROP PROCEDURE IF EXISTS songs_list;
DELIMITER //
CREATE PROCEDURE songs_list(singer_ VARCHAR(50), max_rows_ INT)
BEGIN
	SELECT sn.`name` 'song'
			, sn.created_at
			, (vs.video_id IS NOT NULL) 'has video'
			, sn.views_number
		FROM songs sn
		JOIN singers_songs ss
			ON sn.id = ss.song_id
		JOIN singers s
			ON s.id = ss.singer_id
		LEFT JOIN video_songs vs
			ON vs.song_id = sn.id
		WHERE s.singer = singer_
		ORDER BY sn.`name` ASC
		LIMIT max_rows_
		;
END //
DELIMITER ;

-- Популярные песни (по рейтингу песни) для конкретного исполнителя (для отображения на странице конкретной песни)
DROP PROCEDURE IF EXISTS singer_popular_songs;
DELIMITER //
CREATE PROCEDURE singer_popular_songs(singer VARCHAR(50), max_rows_ INT)
BEGIN
	SET @row_number = 0;
	SELECT (@row_number := @row_number + 1) AS `No`,
			`inner`.singer,
			`inner`.`name`,
			`inner`.views_number
	FROM (
		SELECT 
				sg.singer,
				s.`name`, 
				s.views_number
			FROM songs s
			JOIN singers_songs ss
				ON ss.song_id = s.id
			JOIN singers sg
				ON sg.id = ss.singer_id
			HAVING sg.singer = singer
			ORDER BY s.views_number DESC
			LIMIT max_rows_
		) AS `inner`;
END //
DELIMITER ;


-- Выборка регионов с максимальным кол-вом пользователей по заданной стране
DROP PROCEDURE IF EXISTS max_users_regions;
DELIMITER //
CREATE PROCEDURE max_users_regions(country_var VARCHAR(50), max_rows_ INT)
BEGIN
	SET @row_number = 0;
	SELECT (@row_number := @row_number + 1) AS `No`,
		`inner`.country,
		`inner`.region,
        `inner`.`users_numbers`
        FROM (
			SELECT region, 
					country,
					count(*) AS `users_numbers` 
				FROM chords_db.`profiles`
				GROUP BY region 
				HAVING country = country_var AND region IS NOT NULL 
				ORDER BY `users_numbers` DESC 
				LIMIT max_rows_
        ) AS `inner`;
END //
DELIMITER ;


-- Выборка пользователей с максимальным рейтингом по заданной стране
DROP PROCEDURE IF EXISTS max_rating_users;
DELIMITER //
CREATE PROCEDURE max_rating_users(country VARCHAR(50), max_rows_ INT)
BEGIN
	SET @row_number = 0;
    SELECT (@row_number := @row_number + 1) AS 'No', z.`User`, z.`Rating` FROM (
		SELECT concat(u.first_name, ' ', u.last_name) AS 'User', 
				user_rating(u.id) AS 'Rating'
			FROM users u
			JOIN profiles p
				ON p.user_id = u.id
			WHERE p.country = country
		) z 
		ORDER BY z.`Rating` DESC
		LIMIT max_rows_
		;

END //
DELIMITER ;


SELECT 'Done!';