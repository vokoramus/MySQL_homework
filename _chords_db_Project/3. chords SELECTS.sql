/* 						СОДЕРЖАНИЕ:
	1. список исполнителей по заданной первой букве
	2. список песен исполнителя
	3. вывести статистику по полу пользователей
	4. Выборка всех стран / всех регионов / всех городов пользователей
	5. Выборка пользователей с максимальным рейтингом по заданной стране
	6. Выборка регионов с максимальным кол-вом пользователей по заданной стране
	7. Новые песни (последние 10 шт.)
	8. ТОП-10 исполнителей по расcчитываему рейтингу 
	9. ТОП-10 пользователей по расcчитываему рейтингу
	10. ТОП-10 песен по расcчитываему рейтингу
	11. Популярные песни (по кол-ву просмотров) для конкретного исполнителя
	12. Лучшие 5 песен за последние 30 дней 
	13. Вопросы без ответа
	14. Список игнорируемости пользователей (на чьи вопросы больше всего не отвечают, 
	15. Логирование изменений данных таблицы songs

    FOR DEBUG:
    a0. ЗАГОТОВКА JOIN (список всех песен исполнителя)
	а1. FOR DEBUG: статистика исполнителей по кол-ву песен

*/

USE chords_db;

-- 1. список исполнителей по заданной первой букве
CALL singers_list('G', 10);

-- 2. список песен исполнителя
CALL songs_list('GERTRUDE S.', 10);

-- 3. вывести статистику по полу пользователей
SELECT gender, COUNT(*) `number` FROM profiles GROUP BY gender;

-- 4. Выборка всех стран / всех регионов / всех городов пользователей
SELECT * FROM `all_countries_list`;
SELECT * FROM `all_regions_list`;
SELECT * FROM `all_cities_list`;

-- 5. Выборка пользователей с максимальным рейтингом по заданной стране
CALL max_rating_users('France', 10);
CALL max_rating_users('Germany', 10);

-- 6. Выборка регионов с максимальным кол-вом пользователей по заданной стране
CALL max_users_regions('France', 5);
CALL max_users_regions('Germany', 5);

-- 7. Новые песни (последние 10 шт.)
SELECT s.`name` AS `Song name`, 
		sg.singer AS `Singer`,
		concat(u.first_name, ' ', u.last_name) AS `User`, 
		s.created_at AS `Was uploaded`
    FROM `songs` s
    JOIN `users` u
		ON s.author_id = u.id
    JOIN singers_songs ss
		ON s.id = ss.song_id
    JOIN singers sg
		ON sg.id = ss.singer_id
    ORDER BY s.created_at DESC 
    LIMIT 10;

-- 8. ТОП-10 исполнителей по рейтингу (рейтинг исполнителя = кол-во просмотров его песен 
-- 										+ 10 * кол-во добавлений его песен в избранное)
-- 										+ 50 * кол-во добавлений самого исполнителя в избранное)
-- выполнено посредством созданной функции singer_rating()

    SELECT 	
		sg.id, sg.singer, 
		singer_rating(sg.id) rating
	FROM singers sg
	ORDER BY rating DESC
    LIMIT 10;

-- 9. ТОП-10 пользователей по рейтингу (рейтинг пользователя = 
-- 										 10 * кол-во выложенных им песен 
-- 										+ 5 * если ему лайк
-- 										+ 3 * если задал вопрос на форуме
-- 										+ 2 * если ответил на вопрос на форуме
-- 										+ 1 за каждый лайк (другого юзера, песни или исполнителя))
-- выполнено посредством созданной функции user_rating()
    SELECT u.id, 
		concat(u.first_name, ' ', u.last_name) AS `User`,
		user_rating(u.id) rating
	FROM users u
	ORDER BY rating DESC
    LIMIT 10;

		-- user_id 141,142,146,200 получат рейтинг по всем категориям 
		-- поиск данных наиболее активных пользователей приведен в '(test) user max activity search.sql'
		-- 		Проверить рейтинг конкретного юзера:
		-- SELECT user_rating(141);


-- 10. ТОП-10 песен по рейтингу (рейтинг песни = кол-во просмотров + 50 * кол-во добавлений в избранное)
SELECT 
	 s.id, 
     s.`name`
	, s.views_number
    , count(us.song_id) favorites
    , (s.views_number + 50 * count(us.song_id)) AS rating
	FROM songs s
    RIGHT JOIN users_songs_fav us
		ON us.song_id = s.id
	GROUP BY us.song_id
    ORDER BY rating DESC
	LIMIT 10
    ;

-- 11. Популярные песни (по кол-ву просмотров) для конкретного исполнителя
CALL singer_popular_songs('EPHRAYIM M.', 5);
CALL singer_popular_songs('GERTRUDE S.', 5);

-- 12. Лучшие 5 песен за последние 30 дней 
SELECT 
        s.`name` AS `Song name`, 
        sg.singer AS `Singer`,
        s.views_number AS `Song rating`,
        timestampdiff(DAY,s.created_at,now()) AS `days_ago`,
		concat(u.first_name, ' ', u.last_name) AS `User`
	FROM songs s
    JOIN singers_songs ss
		ON ss.song_id = s.id
    JOIN singers sg
		ON sg.id = ss.singer_id
    JOIN `users` u
		ON u.id = s.author_id
	HAVING `days_ago` <= 30
    ORDER BY `Song rating` DESC
    LIMIT 5
    ;


-- 13. Вопросы без ответа
SELECT q.`text` AS 'Question', 
		concat(u.first_name, ' ', u.last_name) AS `User who ask`,
        qc.`name` AS `Category`,
        timestampdiff(DAY,q.created_at,now()) AS `days ago`
	FROM questions q
	LEFT JOIN answers a
		ON a.question_id = q.id
	JOIN `questions_categories` AS qc
		ON qc.id = q.category_id
	JOIN `users` u
		ON u.id = q.user_id
	WHERE a.question_id IS NULL
    ORDER BY `days ago` DESC
    ;

-- 14. Список игнорируемости пользователей (на чьи вопросы больше всего не отвечают, 
-- при равенстве учитывается время отсутствия ответа)
-- (используется вложенный запрос)
SELECT 
		super_table.`User who ask`, 
        count(super_table.`Question`) AS `Questions number`,
        super_table.`days ago`
	FROM (
		SELECT q.`text` AS 'Question', 
				concat(u.first_name, ' ', u.last_name) AS `User who ask`,
				qc.`name` AS `Category`,
				timestampdiff(DAY,q.created_at,now()) AS `days ago`
			FROM questions q
			LEFT JOIN answers a
				ON a.question_id = q.id
			JOIN `questions_categories` AS qc
				ON qc.id = q.category_id
			JOIN `users` u
				ON u.id = q.user_id
			WHERE a.question_id IS NULL
		) AS super_table
	GROUP BY super_table.`User who ask`
    ORDER BY `Questions number` DESC, `days ago` DESC
;

-- 15. Логирование изменений данных таблицы songs
-- выполнить обновление данных и проверить работу триггера logging_update просмотром таблицы logs
UPDATE `chords_db`.`songs` SET `author_comments` = 'comment' WHERE (`id` = '39');
UPDATE `chords_db`.`songs` SET `author_comments` = 'comment' WHERE (`id` = '50');
UPDATE `chords_db`.`songs` SET `author_comments` = 'comment' WHERE (`id` = '70');
SELECT * FROM `logs`;


-- a0. ЗАГОТОВКА JOIN (список всех песен исполнителя)
/*
SELECT 
        sg.id,
        sg.singer,
		s.id,
		s.`name`, 
		s.author_id,
        s.views_number
	FROM songs s
    JOIN singers_songs ss
		ON ss.song_id = s.id
    JOIN singers sg
		ON sg.id = ss.singer_id
	HAVING sg.singer = 'WAT Z.'
    ORDER BY s.views_number DESC
    -- LIMIT 5
    ;
*/

-- а1. FOR DEBUG: статистика исполнителей по кол-ву песен
-- SELECT author_id, count(*) c FROM chords_db.songs GROUP BY author_id ORDER BY c DESC;
