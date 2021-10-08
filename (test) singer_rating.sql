
DROP FUNCTION IF EXISTS singer_rating;

DELIMITER //
CREATE FUNCTION singer_rating(for_singer BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE views_number_rating INT;
	DECLARE songs_rating INT;
	DECLARE singers_fav_rating INT;
	
	-- посчитаем views_number_rating через SET
	SET views_number_rating = (SELECT sum(s.views_number) sum
								FROM singers sg
								JOIN singers_songs ss ON ss.singer_id = sg.id
								JOIN songs s ON s.id = ss.song_id
								GROUP BY sg.id
								HAVING sg.id = for_singer
								);
    
	-- посчитаем songs_rating через SET
	SET songs_rating = (SELECT count(us.song_id) song_fav
						FROM singers sg
						JOIN singers_songs ss ON ss.singer_id = sg.id
						JOIN songs s ON s.id = ss.song_id    
						RIGHT JOIN users_songs_fav us ON us.song_id = s.id
						GROUP BY sg.id
						HAVING sg.id = for_singer
                        );

	-- посчитаем singers_fav через SELECT INTO
    SELECT count(usg.singer_id) singer_fav INTO singers_fav_rating 
		FROM singers sg
		RIGHT JOIN users_singers_fav usg ON usg.singer_id = sg.id
		GROUP BY sg.id
		HAVING sg.id = for_singer;

	RETURN views_number_rating + (songs_rating * 10) + (singers_fav_rating * 50);
END//
DELIMITER ;

-- SELECT singer_popularity(34); 	-- 318

-- результ.таблица
    SELECT 	
		sg.id, sg.singer, 
		singer_rating(sg.id) rating
	FROM singers sg
	ORDER BY rating DESC
    LIMIT 10;


/*
-- ==========================
-- запрос 1 (songs views_number) 
-- посчитаем views_number_rating через SET
    SELECT 	
-- 		sg.id, sg.singer, 
		sum(s.views_number) sum
	FROM singers sg
	JOIN singers_songs ss ON ss.singer_id = sg.id
	JOIN songs s ON s.id = ss.song_id
	GROUP BY sg.id
	HAVING sg.id = 34;


-- запрос 2 (songs favorites)
-- посчитаем songs_rating через SET
SELECT 	
-- 	sg.id, sg.singer, 
    count(us.song_id) song_fav
	FROM singers sg
	JOIN singers_songs ss ON ss.singer_id = sg.id
	JOIN songs s ON s.id = ss.song_id    
	RIGHT JOIN users_songs_fav us ON us.song_id = s.id
	GROUP BY sg.id
    HAVING sg.id = 34;

-- Проверка: вывод всех лайков для песен исполнителя с id=34
-- SELECT * FROM chords_db.users_songs_fav WHERE song_id IN (450, 1049, 1787);


-- запрос 3
-- посчитаем singers_fav через SELECT INTO
SELECT 	
-- 	sg.id, sg.singer, 
    count(usg.singer_id) singer_fav
	FROM singers sg
	RIGHT JOIN users_singers_fav usg ON usg.singer_id = sg.id
	GROUP BY sg.id
    HAVING sg.id = 34;

-- Проверка кол-ва лайков у исполнителя с id = 34
-- SELECT * FROM chords_db.users_singers_fav WHERE singer_id = 34;

/*
-- список песен певца
SELECT 	sg.id, sg.singer, s.id 'song_id', s.views_number 'song views_number'
	FROM singers sg
	JOIN singers_songs ss ON ss.singer_id = sg.id
	JOIN songs s ON s.id = ss.song_id
	WHERE sg.id = 34;
*/




