-- список id юзеров с хотя бы 1 questions
SELECT group_concat(z.id) FROM (
	SELECT u.id, count(q.user_id) c
		FROM questions q
		RIGHT JOIN users u ON q.user_id=u.id
		GROUP BY q.user_id
		HAVING c > 0
		ORDER BY c DESC
) z;

-- список id юзеров с хотя бы 1 answer из тех, у кого хотя бы 1 question
SELECT group_concat(z.user_id) FROM (
SELECT user_id, count(*) c FROM chords_db.answers WHERE user_id IN (
192,232,5,112,60,95,123,256,278,216,255,64,76,196,153,166,259,68,63,137,184,11,33,189,30,188,219,271,284,24,23,297,291,80,213,155,254,286,299,105,116,77,35,42,206,247,21,39,274,69,238,75,190,72,171,146,114,163,142,4,222,141,209,289,200,160,207,181,55,205
) GROUP BY user_id HAVING c >= 2
) z ORDER BY z.c DESC; 
-- рез-т 2: 	116,141,80,200,137,4,142,146,274


-- фильтруем список id юзеров с хотя бы 1 answer И 1 question по наличии в users_singers_fav 
SELECT group_concat(z.user_id) FROM (
SELECT user_id, count(*) 
FROM chords_db.users_singers_fav
 WHERE user_id IN (
	116,141,80,200,137,4,142,146,274
) GROUP BY user_id
) z;
-- рез-т 3: 4,116,137,141,142,146,200,274


-- фильтруем список id юзеров с хотя бы 1 answer И 1 question по наличии в users_songs_fav 
SELECT group_concat(z.user_id) FROM (
SELECT user_id, count(*) 
FROM chords_db.users_songs_fav
 WHERE user_id IN (
	116,141,80,200,137,4,142,146,274
) GROUP BY user_id
) z;
-- рез-т 4: 4,80,116,137,141,142,146,200,274


-- фильтруем список id юзеров с хотя бы 1 answer И 1 question 
-- по наличию в users_users_fav (КОТОРЫЕ сами добавляли других юзеров в избранное) 
SELECT group_concat(z.user_id) FROM (
SELECT user_id, count(*) 
FROM chords_db.users_users_fav
 WHERE user_id IN (
	116,141,80,200,137,4,142,146,274
) GROUP BY user_id
) z;
-- рез-т 5: 80,116,137,141,142,146,200

-- фильтруем список id юзеров с хотя бы 1 answer И 1 question 
-- по наличию в users_users_fav (КОТОРЫХ добавляли другие юзеры в избранное) 
SELECT group_concat(z.user_fav_id) FROM (
SELECT user_fav_id, count(*) 
FROM chords_db.users_users_fav
 WHERE user_fav_id IN (
	116,141,80,200,137,4,142,146,274
) GROUP BY user_fav_id
) z;
-- рез-т 6: 4,80,137,141,142,146,200,274


-- рез-т 3: 4,116,137,141,142,146,200,274
-- рез-т 4: 4,80,116,137,141,142,146,200,274
-- рез-т 5: 80,116,137,141,142,146,200
-- рез-т 6: 4,80,137,141,142,146,200,274
	-- Итог: user_id 141,142,146,200 получат рейтинг по всем категориям

/*
SELECT count(*) FROM questions WHERE user_id = 116;

SELECT count(*) FROM answers WHERE user_id = 116;
*/