/* 
INFO 430: Database Design and Management 
Project Deliverable 3: Physical Design and Database Implementation
Project Topic: Spotify Database
Students: Evonne La & Megan Chiang
Due Date: Friday, April 26, 2024
*/

/* Creating the Database and Table Structure */
CREATE DATABASE spotify_db
GO

CREATE TABLE Artist (
   artistID INT PRIMARY KEY identity(1, 1) NOT NULL,
   artistFirstName VARCHAR(50) NOT NULL,
   artistLastName VARCHAR(50),
   artistDescription VARCHAR(500),
   artistImageURL VARCHAR(2048)
)

CREATE TABLE Genre (
   genreID INT PRIMARY KEY identity(1, 1) NOT NULL,
   genreName VARCHAR(50) NOT NULL
)

CREATE TABLE PlanType (
   planTypeID INT PRIMARY KEY identity(1, 1) NOT NULL,
   planTypeName VARCHAR(50) NOT NULL,
   planCost MONEY NOT NULL,
   CONSTRAINT check_plan_type -- check constraint (Megan)
   CHECK(planCost >= 0)
)

CREATE TABLE Album (
   albumID INT PRIMARY KEY identity(1, 1) NOT NULL,
   albumName VARCHAR(50) NOT NULL,
   artistID INT NOT NULL,
   releaseDate DATE,
   albumImageURL VARCHAR(2048),
   albumHours INT NOT NULL,
   albumMinutes INT NOT NULL,
   albumTotalMinutes AS (albumHours * 60) + albumMinutes, -- computed column (Megan)
   CONSTRAINT fk_album_artist
   FOREIGN KEY(artistID) REFERENCES Artist(ArtistID),
   CONSTRAINT check_minutes -- check constraint (Megan)
   CHECK(albumMinutes BETWEEN 0 AND 59)
)

CREATE TABLE Song (
   songID INT PRIMARY KEY identity(1, 1) NOT NULL,
   songName VARCHAR(100) NOT NULL,
   artistID INT NOT NULL,
   albumID INT NOT NULL,
   songMinutes INT NOT NULL,
   songSeconds INT NOT NULL,
   songTotalSeconds AS (songMinutes * 60) + songSeconds, -- computed column (Megan)
   CONSTRAINT fk_song_artist
   FOREIGN KEY(artistID) REFERENCES Artist(artistID),
   CONSTRAINT fk_song_album
   FOREIGN KEY(albumID) REFERENCES Album(albumID),
   CONSTRAINT check_seconds -- check constraint (Megan)
   CHECK(songSeconds BETWEEN 0 AND 59)
)

CREATE TABLE SongGenreDetails (
   songGenreID INT PRIMARY KEY identity(1, 1) NOT NULL,
   songID INT NOT NULL,
   genreID INT NOT NULL,
   CONSTRAINT fk_song
   FOREIGN KEY(songID) REFERENCES Song(songID),
   CONSTRAINT fk_genre
   FOREIGN KEY(genreID) REFERENCES Genre(genreID)
)

CREATE TABLE SpotifyUser (
   userID INT PRIMARY KEY identity(1, 1) NOT NULL,
   displayName VARCHAR(30) NOT NULL,
   userFirstName VARCHAR(50) NOT NULL,
   userLastName VARCHAR(50) NOT NULL,
   userEmail VARCHAR(320) NOT NULL,
   profilePictureURL VARCHAR(2048),
   planTypeID INT NOT NULL,
   dateJoined DATE NOT NULL,
   CONSTRAINT fk_user_plan_type
   FOREIGN KEY(planTypeID) REFERENCES PlanType(planTypeID), 
   CONSTRAINT check_user_email_format
   CHECK (userEmail LIKE '%_@_%._%') -- check constraint (Evonne)
)

CREATE TABLE Follower (
   followerID INT PRIMARY KEY identity(1, 1) NOT NULL,
   userID INT NOT NULL,
   CONSTRAINT fk_follower_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID)
)

CREATE TABLE UserFollowerDetails (
   followRelationshipID INT PRIMARY KEY identity(1, 1) NOT NULL,
   userID INT NOT NULL,
   followerID INT NOT NULL,
   dateFollowed DATE NOT NULL,
   CONSTRAINT fk_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID),
   CONSTRAINT fk_follower
   FOREIGN KEY(followerID) REFERENCES Follower(followerID)
)

CREATE TABLE Playlist (
   playlistID INT PRIMARY KEY identity(1, 1) NOT NULL,
   playlistName VARCHAR(100) NOT NULL,
   userID INT NOT NULL,
   playlistDescription VARCHAR(500),
   playlistImageURL VARCHAR(2048),
   playlistDuration AS (
      SELECT SUM(songMinutes * 60 + songSeconds) 
      FROM PlaylistTrack 
      JOIN Song ON PlaylistTrack.songID = Song.songID 
      WHERE PlaylistTrack.playlistID = Playlist.playlistID
   ), -- computed column (Evonne)
   CONSTRAINT fk_playlist_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID)
)

CREATE TABLE PlaylistTrack (
   playlistTrackID INT PRIMARY KEY identity(1, 1) NOT NULL,
   playlistID INT NOT NULL,
   songID INT NOT NULL,
   trackDuration AS (
      SELECT songMinutes * 60 + songSeconds 
      FROM Song 
      WHERE Song.songID = PlaylistTrack.songID
   ), -- computed column (Evonne)
   CONSTRAINT fk_track_playlist
   FOREIGN KEY(playlistID) REFERENCES Playlist(playlistID),
   CONSTRAINT fk_track_song
   FOREIGN KEY(songID) REFERENCES Song(songID)
)

CREATE TABLE ListenHistory (
   listenID INT PRIMARY KEY identity(1, 1) NOT NULL,
   userID INT NOT NULL,
   songID INT NOT NULL,
   timeListened DATETIME NOT NULL,
   CONSTRAINT fk_listen_history_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID),
   CONSTRAINT fk_listen_history_song
   FOREIGN KEY(songID) REFERENCES Song(songID),
   CONSTRAINT check_time_listened_validity
   CHECK (timeListened <= GETDATE()), -- check constraint (Evonne)
   CONSTRAINT check_listen_history_validity
   CHECK (
       timeListened >= (
           SELECT MIN(releaseDate)
           FROM Album
           JOIN Song ON ListenHistory.songID = Song.songID
           WHERE Album.albumID = Song.albumID
       )
   ) -- check constraint (Evonne)
)

/* Populating the Tables with Data */
INSERT INTO Album (albumID, albumName, artistID, releaseDate, albumImageURL, albumHours, albumMinutes)
VALUES
    (1, "THE TORTURED POETS DEPARTMENT", 1, '2024-04-19', 'https://static01.nyt.com/images/2024/04/19/multimedia/19swift-arrival-qfgw/19swift-arrival-qfgw-articleLarge.jpg?quality=75&auto=webp&disable=upscale', 1, 5),
    (2, "folklore", 1, '2020-07-24', 'https://upload.wikimedia.org/wikipedia/en/f/f8/Taylor_Swift_-_Folklore.png', 1, 3),
    (3, "Harry's House", 2, '2022-05-20', 'https://media.architecturaldigest.com/photos/623e05e0b06d6c32457e4358/master/w_1600%2Cc_limit/FINAL%2520%2520PFHH-notextwlogo.jpg', 0, 41),
    (4, "GUTS", 3, '2023-09-08', 'https://upload.wikimedia.org/wikipedia/en/0/03/Olivia_Rodrigo_-_Guts.png', 0, 39),
    (5, "RENAISSANCE", 4, '2022-07-29', 'https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Renaissance_LP_Cover_Art.png/220px-Renaissance_LP_Cover_Art.png', 2, 48),
    (6, "Hollywood's Bleeding", 5, '2019-09-06', 'https://upload.wikimedia.org/wikipedia/en/5/58/Post_Malone_-_Hollywood%27s_Bleeding.png', 0, 51),
    (7, "emails i can't send fwd:", 6, '2022-07-15', 'https://upload.wikimedia.org/wikipedia/en/thumb/7/78/Sabrina_Carpenter_-_Emails_I_Can%27t_Send.png/220px-Sabrina_Carpenter_-_Emails_I_Can%27t_Send.png', 0, 39)

INSERT INTO Artist (artistID, artistFirstName, artistLastName, artistDescription, artistImageURL)
VALUES 
    (1, 'Taylor', 'Swift', 'American singer-songwriter', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Taylor_Swift_at_the_2023_MTV_Video_Music_Awards_%283%29.png/1200px-Taylor_Swift_at_the_2023_MTV_Video_Music_Awards_%283%29.png'),
    (2, 'Harry', 'Styles', 'English singer-songwriter', 'https://variety.com/wp-content/uploads/2022/11/Harry-Styles.jpg?w=1000'),
    (3, 'Olivia', 'Rodrigo', 'American singer-songwriter', 'https://www.billboard.com/wp-content/uploads/2023/08/olivia-rodrigo-press-cr-Zamar-Velez-2023-billboard-1548.jpg?w=942&h=623&crop=1'),
    (4, 'Beyonce', NULL, 'American singer-songwriter', 'https://assets.bwbx.io/images/users/iqjWHBFdfxIU/i5_V6LnkPnR0/v1/-1x-1.jpg'),
    (5, 'Post', 'Malone', 'American singer-songwriter', 'https://www.billboard.com/wp-content/uploads/2023/04/02-post-malone-press-2023-cr-Emma-Louise-Swanson-billboard-1548.jpg'),
    (6, 'Sabrina', 'Carpenter', 'American singer-songwriter', 'https://assets.teenvogue.com/photos/65c24d26781384320621e8f8/2:3/w_1590,h_2385,c_limit/1984755401')

INSERT INTO Follower (followerID, userID)
VALUES 
    (1, 2), 
    (2, 3),
    (3, 4),
    (4, 5),
    (5, 6),
    (6, 1)

INSERT INTO Genre (genreID, genreName)
VALUES  
    (1, "Pop"),
    (2, "Rock"),
    (3, "Indie"),
    (4, "R&B"),
    (5, "Rap"),
    (6, "Electronic")

INSERT INTO ListenHistory (listenID, userID, songID, timeListened)
VALUES 
    (1, 1, 1, '2024-04-30 08:30:00'),
    (2, 2, 2, '2023-02-15 12:45:00'),
    (3, 3, 3, '2024-03-20 17:20:00'),
    (4, 4, 4, '2023-04-10 10:10:00'),
    (5, 5, 5, '2023-05-05 14:30:00'),
    (6, 6, 6, '2023-06-20 20:00:00')

INSERT INTO PlanType (planTypeName, planCost)
VALUES
    ('Free', 0),
    ('Premium Individual', 10.99),
    ('Premium Student', 5.99),
    ('Premium Duo', 14.99),
    ('Premium Family', 16.99),
    ('Premium Trial', 0)

INSERT INTO Playlist (playlistID, playlistName, userID, playlistDescription, playlistImageURL)
VALUES
    (1, 'Top Hits', 1, 'Collection of top songs', 'https://c8.alamy.com/comp/2DAD7D2/top-hits-stamp-top-hits-sign-round-grunge-label-2DAD7D2.jpg'),
    (2, 'Chill Vibes', 2, 'Relaxing music for any mood', 'https://c8.alamy.com/zooms/9/fea52cd0567241618d28f3bbbe97e1aa/2h31w35.jpg'),
    (3, 'Study Jams', 3, 'Concentration music for studying', 'https://lbhspawprint.com/wp-content/uploads/2021/05/studying-and-music-2-28xswo9.jpg'),
    (4, 'Workout Mix', 4, 'Energetic tracks for workouts', 'https://i0.wp.com/post.healthline.com/wp-content/uploads/2023/02/female-dumbbells-1296x728-header-1296x729.jpg?w=1155&h=2268'),
    (5, 'Road Trip Tunes', 5, 'Songs for a perfect road trip', 'https://www.wandering-bird.com/wp-content/uploads/2018/07/songs2-768x512.jpg'),
    (6, 'Late Night Melodies', 6, 'Songs for winding down', 'https://i.pinimg.com/736x/de/35/98/de359848fb0d981c2b22f14e9fa4de00.jpg')

INSERT INTO PlaylistTrack (playlistTrackID, playlistID, songID)
VALUES
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5),
    (6, 6, 6)

INSERT INTO SpotifyUser (userID, displayName, userFirstName, userLastName, userEmail, profilePictureURL, planTypeID, dateJoined)
VALUES
    (1, 'JohnDoe', 'John', 'Doe', 'john@example.com', 'https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg?crop=0.752xw:1.00xh;0.175xw,0&resize=1200:*', 2, '2023-01-01'),
    (2, 'JaneSmith', 'Jane', 'Smith', 'jane@example.com', 'https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg', 3, '2023-02-15'),
    (3, 'AliceJohnson', 'Alice', 'Johnson', 'alice@example.com', 'https://www.princeton.edu/sites/default/files/styles/1x_full_2x_half_crop/public/images/2022/02/KOA_Nassau_2697x1517.jpg?itok=Bg2K7j7J', 2, '2023-03-20'),
    (4, 'BobWilliams', 'Bob', 'Williams', 'bob@example.com', 'https://www.akc.org/wp-content/uploads/2017/11/Golden-Retriever-Puppy.jpg', 5, '2023-04-10'),
    (5, 'EmilyBrown', 'Emily', 'Brown', 'emily@example.com', 'https://us.yumove.com/cdn/shop/articles/Dog_ageing_puppy.jpg?v=1582123836', 4, '2023-05-05'),
    (6, 'MichaelTaylor', 'Michael', 'Taylor', 'michael@example.com', 'https://www.southernliving.com/thmb/a4b73J7C4S4wgSmymmEgXRCmACA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-185743593-2000-507c6c8883a44851885ea4fbc10a2c9e.jpg', 2, '2023-06-20')

INSERT INTO Song (songID, songName, artistID, albumID, songMinutes, songSeconds)
VALUES
    (1, 'Florida!!!', 1, 1, 3, 35),
    (2, 'As It Was', 2, 3, 2, 47),
    (3, 'vampire', 3, 4, 3, 40),
    (4, 'COZY', 4, 5, 3, 30),
    (5, 'Circle', 5, 6, 3, 37),
    (6, 'Nonsense', 6, 7, 2, 43)

INSERT INTO SongGenreDetails (songGenreID, songID, genreID)
VALUES
    (1, 1, 1),
    (2, 2, 1),
    (3, 3, 3),
    (4, 4, 1),
    (5, 5, 2),
    (6, 6, 1)

INSERT INTO UserFollowerDetails (followRelationshipID, userID, followerID, dateFollowed)
VALUES
    (1, 1, 2, '2023-01-01'),
    (2, 2, 3, '2023-02-15'),
    (3, 3, 4, '2023-03-20'),
    (4, 4, 5, '2023-04-10'),
    (5, 5, 6, '2023-05-05'),
    (6, 6, 1, '2023-06-20')

-- for the rest of the tables: just insert manually?? we can use CSV to SQL convertor to get INSERT statements

/* Coding Database Objects */
-- Stored Procedure 1 (Megan): Insert into User table
GO
CREATE OR ALTER PROCEDURE uspInsertUser(
    @displayName VARCHAR(30),
    @firstName VARCHAR(50),
    @lastName VARCHAR(50),
    @email VARCHAR(320),
    @profilePictureURL VARCHAR(2048),
    @planTypeName VARCHAR(20),
    @dateJoined DATE
    )
    AS
    BEGIN
        DECLARE @planTypeID INT

        SET @planTypeID = (
            SELECT planTypeID
            FROM PlanType
            WHERE planTypename = @planTypeName)

        IF @planTypeID IS NULL
        BEGIN
            RAISERROR ('@planTypeID cannot be NULL; process is terminating', 11,1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO SpotifyUser (displayName, userFirstName, userLastName, userEmail, profilePictureURL, planTypeID, dateJoined)
                VALUES (@displayName, @firstName, @lastName, @email, @profilePictureURL, @planTypeID, @dateJoined)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END

-- Stored Procedure 2 (Megan): Insert into Playlist table
GO
CREATE OR ALTER PROCEDURE uspInsertPlaylist(
    @playlistName VARCHAR(100),
    @userDisplayName VARCHAR(30),
    @playlistDescription VARCHAR(500),
    @playlistImageURL VARCHAR(2048)
    )
    AS
    BEGIN
        DECLARE @userID INT

 	    SET @userID = (
            SELECT userID
            FROM SpotifyUser
            WHERE displayName = @userDisplayName)

        IF @userID IS NULL
        BEGIN
            RAISERROR ('@userID cannot be NULL; process is terminating', 11,1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO Playlist (playlistName, userID, playlistDescription, playlistImageURL)
                VALUES (@playlistName, @userID, @playlistDescription, @playlistImageURL)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END

-- Stored Procedure 3 (Evonne): Insert into Song table
GO
CREATE OR ALTER PROCEDURE uspInsertSong(
    @songName VARCHAR(100),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50),
    @albumName VARCHAR(50),
    @releaseDate DATE,
    @songMinutes INT,
    @songSeconds INT
    )
    AS
    BEGIN
        DECLARE @artistID INT
        DECLARE @albumID INT

        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName AND artistLastName = @artistLastName
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; process is terminating', 11, 1)
            RETURN
        END

        SET @albumID = (
            SELECT albumID
            FROM Album
            WHERE albumName = @albumName
        )

        IF @albumID IS NULL
        BEGIN
            RAISERROR ('@albumID cannot be NULL; process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO Song (songName, artistID, albumID, songMinutes, songSeconds)
                VALUES (@songName, @artistID, @albumID, @songMinutes, @songSeconds)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH
    END

-- Stored Procedure 4 (Evonne): Insert into Artist table
GO
CREATE OR ALTER PROCEDURE uspInsertAlbum(
    @albumName VARCHAR(50),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50),
    @releaseDate DATE,
    @albumImageURL VARCHAR(2048),
    @albumHours INT,
    @albumMinutes INT
    )
    AS
    BEGIN
        DECLARE @artistID INT

        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName AND artistLastName = @artistLastName
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO Album (albumName, artistID, releaseDate, albumImageURL, albumHours, albumMinutes)
                VALUES (@albumName, @artistID, @releaseDate, @albumImageURL, @albumHours, @albumMinutes)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH
    END

-- View 1 (Megan): Top 10 Most-Listened Songs in 2024
GO
CREATE VIEW top_10_listened_songs_2024 AS
    SELECT TOP 10 s.songName, COUNT(*) AS num_plays
    FROM ListenHistory l
    JOIN Song s 
        ON l.songID = s.songID
    WHERE YEAR(l.timeListened) = 2024
    GROUP BY l.songID, s.songName
    ORDER BY num_plays DESC;

-- View 2 (Megan): Users' Top Genre Based on Their Listening History
-- referenced https://learnsql.com/blog/sql-rank-over-partition/
GO
CREATE VIEW user_top_genre AS
    WITH user_genre_counts AS (
        SELECT
            u.userID,
            g.genreName,
            COUNT(l.listenID) as listenCount,
            RANK() OVER (PARTITION BY u.userID ORDER BY COUNT(l.listenID) DESC) AS genre_rank
        FROM ListenHistory l
        JOIN SongGenreDetails s 
            ON l.songID = s.songID
        JOIN Genre g 
            ON s.genreID = g.genreID
        JOIN SpotifyUser u 
            ON l.userID = u.userID 
        GROUP BY u.userID, g.genreName
    )
    SELECT userID, genreName
    FROM user_genre_counts
    WHERE genre_rank = 1;

-- View 3 (Evonne): Top 10 Users with the Most Followers
GO
CREATE VIEW top_10_users_with_most_followers AS
    SELECT TOP 10
        u.displayName,
        COUNT(f.followerID) AS numFollowers
    FROM SpotifyUser u
    JOIN Follower f 
        ON u.userID = f.userID
    GROUP BY u.userID, u.displayName
    ORDER BY numFollowers DESC;

-- View 4 (Evonne): Top 3 Most Popular Plans
GO
CREATE VIEW top_3_most_popular_plans AS
    SELECT TOP 3
        pt.planTypeName,
        COUNT(u.userID) AS numSubscribers
    FROM PlanType pt
    JOIN SpotifyUser u 
        ON pt.planTypeID = u.planTypeID
    GROUP BY pt.planTypeName
    ORDER BY numSubscribers DESC;