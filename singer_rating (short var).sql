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

SELECT singer_rating(28); 	-- 4623

-- ===============================
-- 1.

SELECT sum(s.views_number) sum
	FROM singers_songs ss
	JOIN songs s ON s.id = ss.song_id
	GROUP BY ss.singer_id
	HAVING ss.singer_id = 28
	;

	
-- ===============================
-- 2.
SELECT count(*) song_fav
	FROM singers_songs ss
	RIGHT JOIN users_songs_fav us ON us.song_id = ss.song_id
	WHERE ss.singer_id = 28
	GROUP BY ss.singer_id
	;

/*
SELECT count(us.song_id) song_fav
	FROM singers sg
	JOIN singers_songs ss ON ss.singer_id = sg.id
	JOIN songs s ON s.id = ss.song_id    
	RIGHT JOIN users_songs_fav us ON us.song_id = s.id
	GROUP BY sg.id
	HAVING sg.id = 28
	;
*/
-- ===============================
-- 3.
    SELECT count(*) singer_fav
		FROM users_singers_fav usg
		GROUP BY usg.singer_id
		HAVING usg.singer_id = 28
        ;

/*
    SELECT count(usg.singer_id) singer_fav
		FROM singers sg
		RIGHT JOIN users_singers_fav usg ON usg.singer_id = sg.id
		GROUP BY sg.id
		HAVING sg.id = 28
        ;

*/


-- ===============================
-- ИТОГОВЫЙ ЗАПРОС

SELECT 	
	sg.id, sg.singer, 
	singer_rating(sg.id) rating
FROM singers sg
ORDER BY rating DESC
LIMIT 10;