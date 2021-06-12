-- __/\\\\\\\\\\\__/\\\\\_____/\\\___/\\\\\\\\\\\\\\\___/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\__\/\\\///////////__/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\__\/\\\___________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\__\/\\\\\\\\\\\__/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\__\/\\\///////__\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\__\/\\\_________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\__\/\\\__________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\__\/\\\____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////___\///_______________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Hoang Dang
-- Your Student Number: 1080344 
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1


-- Hi tutor/marker, have a nice day :)
-- Algorithms are fun.

SELECT Id AS ForumID, Topic, CreatedBy AS LecturerID
FROM forum
WHERE WhenClosed IS NOT NULL 
	AND CreatedBy = ClosedBy
ORDER BY ForumID;


-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2


SELECT lecturer.Id AS LecturerID, CONCAT(Firstname, ' ', Lastname) AS FullName, COUNT(forum.Id) AS NumForums
FROM lecturer INNER JOIN user ON lecturer.Id = user.Id
	LEFT OUTER JOIN forum ON lecturer.Id = forum.CreatedBy
GROUP BY lecturer.Id
ORDER BY LecturerID;


-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3


SELECT Id AS UserID, Username
FROM user 
WHERE Id NOT IN (SELECT DISTINCT PostedBy FROM post WHERE ParentPost IS NULL)
ORDER BY UserID;


-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4


SELECT Id AS PostID
FROM post
WHERE ParentPost IS NULL
	AND Id NOT IN (SELECT DISTINCT ParentPost FROM post WHERE ParentPost IS NOT NULL)
	AND Id NOT IN (SELECT DISTINCT Post FROM likepost)
ORDER BY PostID;


-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5


SELECT Id AS PostID, content AS Content, COUNT(Post) AS Likes
FROM post INNER JOIN likepost ON post.Id = likepost.Post
GROUP BY Id
HAVING Likes = (SELECT MAX(likes) FROM 
	(SELECT COUNT(post) AS likes FROM likepost GROUP BY post) AS countlikes)
ORDER BY PostID;


-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6


SELECT CHAR_LENGTH(Content) AS PostLength, 
	post.Content, forum.Topic, 
    CONCAT(user.Firstname, ' ', user.Lastname) AS FullName
FROM post INNER JOIN user ON user.Id = post.PostedBy
    INNER JOIN forum ON forum.Id = post.Forum
WHERE ParentPost IS NULL
HAVING PostLength = (SELECT MAX(postlength) FROM 
	(SELECT CHAR_LENGTH(Content) as postlength FROM post WHERE ParentPost IS NULL) AS lengthcount);


-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7


SELECT Student1 AS Student1ID, Student2 AS Student2ID, 
	TIMESTAMPDIFF(DAY, WhenConfirmed, WhenUnfriended) AS FriendDays
FROM friendof
WHERE WhenConfirmed IS NOT NULL AND WhenUnfriended IS NOT NULL
HAVING FriendDays = (SELECT MIN(duration) FROM 
	(SELECT TIMESTAMPDIFF(DAY, WhenConfirmed, WhenUnfriended) AS duration
	FROM friendof
	WHERE WhenConfirmed IS NOT NULL AND WhenUnfriended IS NOT NULL) AS datecount)
ORDER BY Student1ID, Student2ID;


-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8


SELECT a.User AS UserID, COUNT(a.WhenLiked)-1 AS OtherLikes, a.Post AS PostID
FROM likepost a INNER JOIN likepost b ON a.Post = b.Post
GROUP BY a.Post, a.User
ORDER BY PostID, UserID, OtherLikes;


-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9


SELECT Student1ID + Student2ID - PopularID AS UserID FROM 
	-- Find the most popular kid
	(SELECT PostedBy AS PopularId
	FROM likepost INNER JOIN post ON likepost.Post = post.Id
		INNER JOIN student ON post.PostedBy = student.id
	GROUP BY PostedBy 
    ORDER BY COUNT(WhenLiked) DESC 
    LIMIT 1) AS mostplrstudent
    
    -- Find all friendships involving the popular kid
    INNER JOIN friendof
    ON ((friendof.Student1 = mostplrstudent.PopularId) OR (friendof.Student2 = mostplrstudent.PopularId))
		AND WhenConfirmed IS NOT NULL AND WhenUnfriended IS NULL
        
	-- Find all friendships of students doing the same degree
	INNER JOIN
		(SELECT s1.Id AS Student1ID, s2.Id AS Student2ID
		FROM student AS s1, student AS s2
		WHERE s1.Id < s2.Id AND s1.Degree = s2.Degree) AS twinningstudents
	ON (friendof.Student1 = twinningstudents.Student1ID AND friendof.Student2 = twinningstudents.Student2ID)
		OR (friendof.Student1 = twinningstudents.Student2ID AND friendof.Student2 = twinningstudents.Student1ID)
ORDER BY UserID;


-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10


SELECT studentpost.PostID, studentpost.WhenPosted 
FROM 
	(SELECT posts.Id AS PostID, WhenPosted, forum.CreatedBy AS ForumCreatedBy
	FROM forum INNER JOIN 
		(SELECT * FROM post
		WHERE ParentPost IS NULL AND PostedBy NOT IN (SELECT Id FROM lecturer)) AS posts
		ON forum.Id = posts.Forum) AS studentpost
	LEFT OUTER JOIN post AS reply
	ON reply.ParentPost = studentpost.PostID AND reply.PostedBy = studentpost.ForumCreatedBy
WHERE reply.WhenPosted IS NULL 
	OR (SELECT TIMESTAMPDIFF(DAY, studentpost.WhenPosted, reply.WhenPosted) >= 2)
ORDER BY studentpost.PostID;


-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line