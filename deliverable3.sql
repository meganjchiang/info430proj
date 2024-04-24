/* 
INFO 430: Database Design and Management 
Project Deliverable 3: Physical Design and Database Implementation
Project Topic: Spotify Database
Students: Evonne La & Megan Chiang
Due Date: Friday, April 26, 2024
*/

/* Creating the Database and Table Structure */
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
   FOREIGN KEY(planTypeID) REFERENCES PlanType(planTypeID)
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
   FOREIGN KEY(followerID) REFERENCES Follower(followerID),
)

CREATE TABLE Playlist (
   playlistID INT PRIMARY KEY identity(1, 1) NOT NULL,
   playlistName VARCHAR(100) NOT NULL,
   userID VARCHAR(30) NOT NULL,
   playlistDescription VARCHAR(500),
   playlistImageURL VARCHAR(2048),
   CONSTRAINT fk_playlist_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID)
)

CREATE TABLE PlaylistTrack (
   playlistTrackID INT PRIMARY KEY identity(1, 1) NOT NULL,
   playlistID INT NOT NULL,
   songID INT NOT NULL,
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
)

/* Populating the Tables with Data */
BULK INSERT Artist
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Artist.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT Genre
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Genre.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT Album
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Album.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT Song
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Song.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT SongGenreDetails
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\SongGenreDetails.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT SpotifyUser
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\SpotifyUser.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT Follower
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Follower.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT UserFollowerDetails
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\UserFollowerDetails.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT Playlist
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\Playlist.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT PlaylistTrack
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\PlaylistTrack.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

BULK INSERT ListenHistory
FROM 'C:\Users\evonnela\Desktop\INFO430\info430proj\csv_files\ListenHistory.csv'
WITH (
   FIELDTERMINATOR = ',',
   ROWTERMINATOR = '\n',
   FIRSTROW = 2 -- Skip header
)

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