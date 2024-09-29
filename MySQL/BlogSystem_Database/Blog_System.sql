drop database if exists Blog_System;
CREATE database Blog_System;
use Blog_System;
CREATE TABLE users (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(20),
    PRIMARY KEY (user_id)
);
drop table posts;
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT,
    title VARCHAR(100),
    content VARCHAR(100),
    PRIMARY KEY (post_id),
    user_id INT,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);

CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    comment_text VARCHAR(50),
    PRIMARY KEY (comment_id),
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id),
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);    
            
insert into users (username, email,password) values
			('admin', 'password123','admin@example.com'),
			('user1', 'password123','user1@example.com'),
			('user2' ,'password123','user2@example.com');
insert into posts (title, content,user_id) values
			('Hello World!', 'This is my first post.',1),
			('My Second Post', 'This is my second post.',1),
			('User1\'s Post' ,'This is user1\'s post.',2);
insert into comments (post_id, user_id, comment_text) values
			(1,1,"Nice post!"),
			(1,2, "I agree!"),
            (2,1, "Good job!"),
			(3,2, "Thanks!");
		##to show all data 
select * from users ;
select * from posts ;
select * from comments ;

			##1- Find the titles and contents of all posts?
SELECT 
    title, content
FROM
    posts;
    
			##2- Retrieve all posts by a specific user.
SELECT DISTINCT
    un.username, pt.title, pt.content
FROM
    users AS un
        INNER JOIN
    posts AS pt ON un.user_id = pt.user_id;
    
			##3- Retrieve all comments for a specific post.
SELECT DISTINCT
    pt.post_id , ct.comment_text
FROM
    posts AS pt
        INNER JOIN
    comments AS ct ON pt.post_id = ct.post_id;
    
			##4- Retrieve the username of the user who made a specific comment.
select 
    us.username , ct.comment_text
FROM
    users AS us
        INNER JOIN
    comments AS ct ON us.user_id = ct.user_id;
    
			##5-Retrieve the count of comments for each post.
SELECT 
    pt.post_id , count(ct.comment_id) as number_of_comments
FROM
    posts AS pt
        INNER JOIN
    comments AS ct ON pt.post_id = ct.post_id group by  pt.post_id;
    
			##6- Retrieve the top 5 most commented posts.
SELECT 
    pt.post_id, 
    ct.comment_text
FROM
    posts AS pt
    INNER JOIN
    comments AS ct ON pt.post_id = ct.post_id
ORDER BY 
    ct.comment_id DESC
LIMIT 5;

			##7- Retrieve all users who have commented on a specific post.
select 
    us.username 
FROM
    users AS us
        INNER JOIN
    comments AS cs ON us.user_id = cs.user_id;

			##8- Find the titles and usernames of all posts.
select 
    us.username , pd.title as post_title
FROM
    users AS us
        INNER JOIN
    posts AS pd ON us.user_id = pd.user_id;
    
			##9- Find the titles and number of comments for all posts.
SELECT 
    pd.title AS post_title,
    COUNT(cs.comment_id) AS number_of_comment
FROM
    posts AS pd
        INNER JOIN
    comments AS cs ON pd.post_id = cs.post_id
GROUP BY post_title;

			##10- Find the usernames and number of posts for each user, with a "Post Count" column that displays "Many" for users 
            ##with more than 5 posts, "Few" for users with 2 to 5 posts, and "None" for users with no posts.
SELECT 
    us.username,
    COUNT(pd.post_id) AS number_of_posts,
    CASE
        WHEN COUNT(pd.post_id) > 5 THEN 'Many'
        WHEN COUNT(pd.post_id) BETWEEN 1 AND 5 THEN 'Few'
        WHEN COUNT(pd.post_id) <= 0 THEN 'None'
    END AS Post_count
FROM
    users AS us
        left JOIN
    posts AS pd ON us.user_id = pd.user_id
GROUP BY us.username;

			##11-Find the usernames and number of comments for each user, with a "Comment Count" column that displays "Active" 
            ##for users with more than 10 comments, "Moderate" for users with 5 to 10 comments, 
            ##and "Inactive" for users with fewer than 5 comments.
SELECT 
    us.username,
    COUNT(ct.comment_id) AS number_of_comments,
    CASE
        WHEN COUNT(ct.comment_id) > 10 THEN 'Active'
        WHEN COUNT(ct.comment_id) BETWEEN 5 AND 10 THEN 'Moderate'
        WHEN COUNT(ct.comment_id) < 5 THEN 'Inactive'
    END AS Comment_count
FROM
    users AS us
        LEFT JOIN
    comments AS ct ON us.user_id = ct.user_id
GROUP BY us.username;

			##12- Find the number of posts for each user, excluding posts with no comments.
SELECT 
    us.username, COUNT(DISTINCT pd.post_id) AS number_of_posts
FROM
    users AS us
        INNER JOIN
    posts AS pd ON us.user_id = pd.user_id
        INNER JOIN
    comments AS cs ON pd.post_id = cs.post_id
GROUP BY us.username;

			##13- Find the usernames and number of posts and comments for each user, 
            ##sorted by the total number of posts and comments in descending order.
SELECT 
    us.username,
    COUNT(DISTINCT pd.post_id) AS Number_of_posts,
    COUNT(DISTINCT ct.comment_id) AS number_of_comments
FROM
    users AS us
        LEFT JOIN
    posts AS pd ON us.user_id = pd.user_id
        LEFT JOIN
    comments AS ct ON ct.post_id = pd.post_id
GROUP BY us.username
ORDER BY Number_of_posts DESC , number_of_comments DESC;

			##14- Create a stored procedure for any two query of the above.(ON 8 & 9 Questions)
DELIMITER $$
CREATE PROCEDURE Blog_System()
BEGIN
	select 
    us.username , pd.title as post_title
FROM
    users AS us
        INNER JOIN
    posts AS pd ON us.user_id = pd.user_id;
	SELECT 
    pd.title AS post_title,
    COUNT(cs.comment_id) AS number_of_comment
FROM
    posts AS pd
        INNER JOIN
    comments AS cs ON pd.post_id = cs.post_id
GROUP BY post_title;
END $$
DELIMITER ;
CALL Blog_System();		


			##15- Save any Query in views.  (on question 11)
create view each_user as 
SELECT 
    us.username,
    COUNT(ct.comment_id) AS number_of_comments,
    CASE
        WHEN COUNT(ct.comment_id) > 10 THEN 'Active'
        WHEN COUNT(ct.comment_id) BETWEEN 5 AND 10 THEN 'Moderate'
        WHEN COUNT(ct.comment_id) < 5 THEN 'Inactive'
    END AS Comment_count
FROM
    users AS us
        LEFT JOIN
    comments AS ct ON us.user_id = ct.user_id
GROUP BY us.username;

select * from each_user;
            
            