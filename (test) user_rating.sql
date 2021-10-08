-- ТОП-10 пользователей по рейтингу (рейтинг пользователя = 
-- 										 10 * кол-во выложенных им песен 
-- 										+ 5 * если ему лайк
-- 										+ 3 * если задал вопрос на форуме
-- 										+ 2 * если ответил на вопрос на форуме
-- 										+ 1 за каждый лайк (другого юзера, песни или исполнителя))
-- выполнено посредством созданной функции user_rating()

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


-- user_id 141,142,146,200 получат рейтинг по всем категориям 
-- поиск данных наиболее активных пользователей приведен в '(test) user max activity search.sql'
SELECT user_rating(141);

/*
-- результ.таблица
    SELECT
		u.id, 
		concat(u.first_name, ' ', u.last_name) AS `User`,
		user_rating(u.id) rating
	FROM users u
	ORDER BY rating DESC
    LIMIT 10;
