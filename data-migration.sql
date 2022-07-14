WITH "users_collection" AS (
    SELECT "username" 
    FROM "bad_posts"
    UNION 
    SELECT "username"
    FROM "bad_comments" 
    UNION 
    SELECT regexp_split_to_table("upvotes", ',') AS "username"
    FROM "bad_posts"
    UNION 
    SELECT regexp_split_to_table("downvotes", ',') AS "username"
    FROM "bad_posts"
)
    INSERT INTO "users" ("username") SELECT DISTINCT "username" FROM "users_collection";


INSERT INTO "topics" ("name", "user_id") (
    SELECT DISTINCT ON (b.topic) b.topic AS "name", u.id AS "user_id"
    FROM bad_posts b
    JOIN users u 
    ON u.username = b.username
);

INSERT INTO "posts" ("title", "url", "text", "topic_id", "user_id") (
    SELECT b.title, b.url, b.text_content AS text, t.id AS topic_id, u.id AS user_id 
    FROM bad_posts b 
    JOIN users u 
    ON b.username = u.username AND LENGTH(TRIM(b.title)) <= 100
    JOIN topics t 
    ON b.topic = t.name
);

INSERT INTO "comments" ("content", "user_id", "post_id") (
    SELECT b.text_content, u.id AS user_id, p.id AS post_id 
    FROM bad_comments b 
    JOIN users u 
    ON u.username = b.username 
    JOIN bad_posts bp 
    ON b.post_id = bp.id  
    JOIN posts p 
    ON p.title = bp.title 
);


INSERT INTO "votes" ("value", "user_id", "post_id")(
    WITH upvotes AS (  
      SELECT DISTINCT ON(username) title, regexp_split_to_table("upvotes", ',') AS username
      FROM bad_posts 
    ),
    downvotes AS (
      SELECT DISTINCT ON (username) title, regexp_split_to_table("downvotes", ',') AS username
      FROM bad_posts 
    )(
      SELECT 1 AS value, u.id AS user_id, p.id AS post_id  
      FROM upvotes uv 
      JOIN users u 
      ON u.username = uv.username 
      JOIN posts p 
      ON p.title = uv.title 
    )
    UNION ALL 
    (
      SELECT -1 AS value, u.id AS user_id, p.id AS post_id  
      FROM downvotes dv 
      JOIN users u 
      ON u.username = dv.username 
      JOIN posts p 
      ON p.title = dv.title
    )
); 



