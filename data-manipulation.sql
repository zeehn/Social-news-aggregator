--- 1. List all users who haven’t created any post.
SELECT username, p.title, p.text, p.url 
FROM users u 
LEFT JOIN posts p 
ON p.user_id = u.id 
WHERE p.user_id IS NULL; 

--- 2. Find a user by their username.
SELECT * 
FROM users 
WHERE username = 'Rickie0';

--- 3. List all topics that don’t have any posts.
SELECT name, COUNT(*) 
FROM topics t 
JOIN posts p 
ON p.topic_id = t.id 
GROUP BY 1
HAVING COUNT(*) < 1;

--- 4. Find a topic by its name.
SELECT * 
FROM topics t
WHERE t.name = 'Car';

--- 5. List the latest 20 posts for a given topic.
SELECT *  
FROM posts p 
WHERE p.topic_id = (  
  SELECT id 
  FROM topics t 
  WHERE t.name = 'Car' 
)
LIMIT 20;


--- 6. List the latest 20 posts made by a given user.
SELECT *  
FROM posts p 
WHERE p.user_id = (  
  SELECT id 
  FROM users u  
  WHERE u.username = 'Keagan_Howell' 
)
ORDER BY p.created_at DESC
LIMIT 20;


