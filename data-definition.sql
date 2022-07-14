
-- 1. Users Table 
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(25) NOT NULL, 
  "last_session" TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  CONSTRAINT "unique_username" UNIQUE ("username"), 
  CONSTRAINT "username_must_exist" CHECK(LENGTH(TRIM("username")) > 0)
);


--- 2. Topics Table 
CREATE TABLE "topics" (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "name" VARCHAR(30) NOT NULL, 
  "description" VARCHAR(500),
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "user_id" INT,
  CONSTRAINT "topic_name_must_be_unique" UNIQUE ("name"),
  CONSTRAINT "topic_name_must_exist" CHECK(LENGTH(TRIM("name")) > 0),
  CONSTRAINT "fk_user" FOREIGN KEY("user_id") REFERENCES "users" ("id") ON DELETE SET NULL
);


--- 3. Posts Table 
CREATE TABLE "posts" (
  "id" SERIAL PRIMARY KEY NOT NULL, 
  "title" VARCHAR(100) NOT NULL,
  "url" VARCHAR(500),
  "text" TEXT,
  "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "topic_id" INT,
  "user_id" INT,
  CONSTRAINT "title_must_exist" CHECK(LENGTH(TRIM("title")) > 0),
  CONSTRAINT "url_or_text" CHECK(("text" IS NOT NULL AND "url" IS NULL) OR ("url" IS NOT NULL AND "text" IS NULL)),
  CONSTRAINT "fk_topic" FOREIGN KEY("topic_id") REFERENCES "topics" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_user" FOREIGN KEY("user_id") REFERENCES "users" ("id") ON DELETE SET NULL
);

--- Post table's index on title 
CREATE INDEX "idx_post_title" ON "posts" ("title");


--- 4. Comments Table 
CREATE TABLE "comments" (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "content" TEXT NOT NULL,
  "posted_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "user_id" INT,
  "post_id" INT,
  "p_comment_id" INT,
  CONSTRAINT "comment_must_exist" CHECK (LENGTH(TRIM("content")) > 0),
  CONSTRAINT "fk_user" FOREIGN KEY("user_id") REFERENCES "users" ("id") ON DELETE SET NULL, 
  CONSTRAINT "fk_post" FOREIGN KEY("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE,
  CONSTRAINT "fk_comment" FOREIGN KEY("p_comment_id") REFERENCES "comments" ("id") ON DELETE CASCADE
);

--- Comments table's index on parent id (p_comment_id)
CREATE INDEX "idx_parent_comment" ON "comments" ("p_comment_id");

--- 5. Votes Table
CREATE TABLE "votes" (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "value" SMALLINT NOT NULL,
  "user_id" INT, 
  "post_id" INT,
  CONSTRAINT "value_can_be_1_or_minus1" CHECK(value in (1, -1)),
  CONSTRAINT "user_can_like_post_once" UNIQUE ("user_id", "post_id"),
  CONSTRAINT "fk_user" FOREIGN KEY("user_id") REFERENCES "users" ("id") ON DELETE SET NULL,
  CONSTRAINT "fk_post" FOREIGN KEY("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE
);

--- Votes table's index on "value" column to calculate scores 
CREATE INDEX "idx_vote_value" ON "votes" ("value");
