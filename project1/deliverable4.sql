/* 
INFO 430: Database Design and Management 
Project Deliverable 4: Data Manipulation and Deriving Useful Information from the Database
Project Topic: Spotify Database
Students: Evonne La & Megan Chiang
Due Date: Friday, May 3, 2024
*/

/*
Write the SQL code to create three (3) stored procedures, one to insert a row of data into a
given table, another for updating data, and the third one for deleting a row of data.
*/

/* Inserting a row of data: */
-- Stored Procedure 1 (Megan): Insert into SongGenreDetails table
GO
CREATE OR ALTER PROCEDURE uspInsertSongGenre(
    @songName VARCHAR(100),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50),
    @genreName VARCHAR(50)
    )
    AS
    BEGIN
        DECLARE @artistID INT, @songID INT, @genreID INT
    
        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @songID = (
            SELECT songID
            FROM Song
            WHERE songName = @songName
                AND artistID = @artistID)

        IF @songID IS NULL
        BEGIN
            RAISERROR ('@songID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @genreID = (
            SELECT genreID
            FROM Genre
            WHERE genreName = @genreName)

        IF @genreID IS NULL
        BEGIN
            RAISERROR ('@genreID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO SongGenreDetails (songID, genreID)
                VALUES (@songID, @genreID)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END

-- test Stored Procedure 1:
EXEC uspInsertSongGenre 'To you', 'SEVENTEEN', NULL, 'K-Pop'
select * from SongGenreDetails

-- Stored Procedure 2 (Evonne): Insert into Artist table
GO
CREATE OR ALTER PROCEDURE uspInsertArtist(
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50),
    @artistDescription VARCHAR(500),
    @artistImageURL VARCHAR(2048) = NULL
    )
    AS
    BEGIN
        DECLARE @artistID INT

        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
        )

        IF @artistID IS NOT NULL
        BEGIN
            RAISERROR ('Artist already exists with the given name; process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO Artist (artistFirstName, artistLastName, artistDescription, artistImageURL)
                VALUES (@artistFirstName, @artistLastName, @artistDescription, @artistImageURL)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END

-- test Stored Procedure 2:
EXEC uspInsertArtist 'Victoria', 'Justice', 'American singer', NULL 
SELECT * FROM Artist -- Victoria Justie is added into the artist table!

/* Updating a row of data: */
-- Stored Procedure 1 (Megan): Update a row of PlanType table
GO
CREATE OR ALTER PROCEDURE uspUpdatePlanType(
    @planTypeName VARCHAR(50),
    @planCost MONEY
    )
    AS
    BEGIN
        DECLARE @planTypeID INT

        SET @planTypeID = (
            SELECT planTypeID
            FROM PlanType
            WHERE planTypeName = @planTypeName
        )

        IF @planTypeID IS NULL
        BEGIN
            RAISERROR ('@planTypeID cannot be NULL; process is terminating', 11,1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                UPDATE PlanType
                SET planCost = @planCost
                WHERE planTypeID = @planTypeID
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH
    END
GO

-- test Stored Procedure 1:
select * from PlanType -- original cost of Premium Individual is 10.99
EXEC uspUpdatePlanType 'Premium Individual', 11.99
select * from PlanType -- cost of Premium Individual is now 11.99

-- Stored Procedure 2 (Evonne): Update a row of SpotifyUser table
GO
CREATE OR ALTER PROCEDURE uspUpdateSpotifyUser(
    @displayName VARCHAR(30),
    @userFirstName VARCHAR(50),
    @userLastName VARCHAR(50),
    @userEmail VARCHAR(320),
    @profilePictureURL VARCHAR(2048),
    @planTypeID INT,
    @dateJoined DATE
    )
    AS
    BEGIN
        DECLARE @userID INT

        SET @userID = (
            SELECT userID
            FROM SpotifyUser
            WHERE displayName = @displayName
        )

        IF @userID IS NULL
        BEGIN
            RAISERROR ('@userID cannot be NULL; process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                UPDATE SpotifyUser
                SET displayName = @displayName,
                    userFirstName = @userFirstName,
                    userLastName = @userLastName,
                    userEmail = @userEmail,
                    profilePictureURL = @profilePictureURL,
                    planTypeID = @planTypeID,
                    dateJoined = @dateJoined
                WHERE userID = @userID
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH
    END
GO

-- test Stored Procedure 1:
SELECT * FROM SpotifyUser -- Evonne's previous email was 'evonnela@gmail.com'
EXEC uspUpdateSpotifyUser 'evonnela', 'Evonne', 'La', 'evonnela@uw.edu', 'https://t3.ftcdn.net/jpg/02/99/23/70/360_F_299237086_LSGXAAWR049NBUct3snKiOKNhRLDKyEW.jpg', 3, '2024-04-28'
SELECT * FROM SpotifyUser -- Evonne's new email is 'evonnela@uw.edu'

/* Deleting a row of data: */
-- Stored Procedure 1 (Megan): Delete a row of PlaylistTrack table
GO
CREATE OR ALTER PROCEDURE uspDeletePlaylistTrack(
    @userDisplayName VARCHAR(30),
    @playlistName VARCHAR(100),
    @songName VARCHAR(100),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50)
    )
    AS
    BEGIN
        DECLARE @userID INT, @playlistID INT, @artistID INT, @songID INT, @playlistTrackID INT

        SET @userID = (
            SELECT userID
            FROM SpotifyUser
            WHERE displayName = @userDisplayName
        )

        IF @userID IS NULL
        BEGIN
            RAISERROR ('@userID cannot be NULL; process is terminating', 11,1)
            RETURN
        END

        SET @playlistID = (
            SELECT playlistID
            FROM Playlist
            WHERE playlistName = @playlistName
                AND userID = @userID
        )
        
        IF @playlistID IS NULL
        BEGIN
            RAISERROR ('@playlistID cannot be NULL; process is terminating', 11,1)
            RETURN
        END

        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @songID = (
            SELECT songID
            FROM Song
            WHERE songName = @songName
                AND artistID = @artistID)

        IF @songID IS NULL
        BEGIN
            RAISERROR ('@songID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @playlistTrackID = (
            SELECT TOP 1 playlistTrackID -- since a playlist can have a song more than once, this procedure only deletes the first instance of the song in the playlist
            FROM PlaylistTrack
            WHERE playlistID = @playlistID
                AND songID = @songID)

        IF @playlistTrackID IS NULL
        BEGIN
            RAISERROR ('@playlistTrackID cannot be NULL; user does not exist so process is terminating', 11, 1)
            RETURN
        END
        
        BEGIN TRY
            BEGIN TRANSACTION T1;
                DELETE FROM PlaylistTrack
                WHERE playlistTrackID = @playlistTrackID
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH 
            ROLLBACK TRANSACTION T1;
        END CATCH 
    END
GO

-- test Stored Procedure 1:
select playlistTrackID, playlistID, Song.songID, songName from PlaylistTrack join Song on PlaylistTrack.songID = Song.songID where playlistID = 7 -- from playlist called 'on repeat'
EXEC uspDeletePlaylistTrack 'meganchiang', 'on repeat', 'Florida!!!', 'Taylor', 'Swift' -- removes the song called 'Florida!!!' from the 'on repeat' playlist
select playlistTrackID, playlistID, Song.songID, songName from PlaylistTrack join Song on PlaylistTrack.songID = Song.songID where playlistID = 7 -- from playlist called 'on repeat'

-- Stored Procedure 2 (Evonne):
GO
CREATE OR ALTER PROCEDURE uspDeleteSongGenre(
    @songName VARCHAR(100),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50),
    @genreName VARCHAR(50)
    )
    AS
    BEGIN
        DECLARE @songID INT, @artistID INT, @genreID INT

        SET @artistID = (
            SELECT artistID
            FROM Artist
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; artist does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @songID = (
            SELECT songID
            FROM Song
            WHERE songName = @songName
                AND artistID = @artistID
        )

        IF @songID IS NULL
        BEGIN
            RAISERROR ('@songID cannot be NULL; song does not exist so process is terminating', 11, 1)
            RETURN
        END

        SET @genreID = (
            SELECT genreID
            FROM Genre
            WHERE genreName = @genreName
        )

        IF @genreID IS NULL
        BEGIN
            RAISERROR ('@genreID cannot be NULL; genre does not exist so process is terminating', 11, 1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                DELETE FROM SongGenreDetails
                WHERE songID = @songID
                AND genreID = @genreID;
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END
GO

-- test Stored Procedure 2:
SELECT * FROM SongGenreDetails WHERE songID = 3 -- selecting the song 'vampire'
EXEC uspDeleteSongGenre @songName = 'vampire', @artistFirstName = 'Olivia', @artistLastName = 'Rodrigo', @genreName = 'Pop';
SELECT * FROM SongGenreDetails WHERE songID = 3 -- deletes the 'Pop' genre from the song 'vampire'

/*
Write the SQL code to create two (2) triggers; one should be an AFTER trigger (either insert, update, or Delete) and the other should be an INSTEAD OF trigger (again, either insert, update, or delete).
The two should use different actions (e.g., if the first one is insert, then the second one should be either update or delete).
*/

/* AFTER Triggers: */
-- AFTER-Delete Trigger 1 (Megan): record Audit information after deleting a row from PlaylistTrack table 
CREATE TABLE PlaylistTrack_LOG
(
    playlistTrackID INT,
    playlistID INT,
    songID INT,
    log_action VARCHAR(100),
    log_timestamp DATETIME
)

GO 
CREATE OR ALTER TRIGGER trigAfterDeletePlaylistTrack ON PlaylistTrack
AFTER DELETE
AS
DECLARE @playlistTrackID INT, @playlistID INT, @songID INT, @audit_action VARCHAR(100)

SELECT @playlistTrackID = d.playlistTrackID, @playlistID = d.playlistID, @songID = d.songID
FROM Deleted d

SET @audit_action='Logs of Deleted Playlist Track --- After Delete Trigger.';

INSERT INTO PlaylistTrack_LOG(playlistTrackID, playlistID, songID, log_action, log_timestamp)
values (@playlistTrackID, @playlistID, @songID, @audit_action, GETDATE());
PRINT 'AFTER DELETE trigger fired successfully.'

-- test the trigger
DELETE PlaylistTrack
WHERE playlistTrackID = 26

-- verify that it worked
select * from PlaylistTrack_LOG

-- AFTER-Update Trigger 2 (Evonne): record Audit information after updating a row from Artist table
CREATE TABLE Artist_LOG (
    artistID INT,
    artistFirstName VARCHAR(50),
    artistLastName VARCHAR(50),
    artistDescription VARCHAR(500),
    artistImageURL VARCHAR(2048),
    log_action VARCHAR(100),
    log_timestamp DATETIME
)

GO
CREATE OR ALTER TRIGGER trigAfterUpdateArtist ON Artist
AFTER UPDATE
AS
BEGIN
    DECLARE @artistID INT, @artistFirstName VARCHAR(50), @artistLastName VARCHAR(50), 
            @artistDescription VARCHAR(500), @artistImageURL VARCHAR(2048), @audit_action VARCHAR(100);

    SELECT @artistID = i.artistID, @artistFirstName = i.artistFirstName, @artistLastName = i.artistLastName,
           @artistDescription = i.artistDescription, @artistImageURL = i.artistImageURL
    FROM Inserted i;

    SET @audit_action = 'Updated Artist -- After Update Trigger.';

    INSERT INTO Artist_LOG(artistID, artistFirstName, artistLastName, artistDescription, artistImageURL, log_action, log_timestamp)
    VALUES (@artistID, @artistFirstName, @artistLastName, @artistDescription, @artistImageURL, @audit_action, GETDATE());

    PRINT 'AFTER UPDATE trigger fired successfully.';
END;

-- test the trigger
UPDATE Artist
SET artistDescription = 'British singer-songwriter'
WHERE artistID = 2; 

-- verify that it worked
SELECT * FROM Artist_LOG;

/* INSTEAD-OF Triggers: */
-- INSTEAD OF-Update Trigger 1 (Megan): update user's display name and/or email, only allow users to change to a display name and/or email that doesn't exist in database
CREATE TABLE SpotifyUser_LOG
(
    userID INT,
    displayName VARCHAR(30),
    userFirstName VARCHAR(50),
    userLastName VARCHAR(50),
    userEmail VARCHAR(320),
    profilePictureURL VARCHAR(2048),
    planTypeID INT,
    dateJoined DATE,
    userDuration INT,
    log_action VARCHAR(100),
    log_timestamp DATETIME
)

GO
CREATE OR ALTER TRIGGER trgInsteadOfUpdateUserInfo ON SpotifyUser
INSTEAD OF UPDATE
AS
DECLARE @userID INT, @displayName VARCHAR(30), @userFirstName VARCHAR(50), @userLastName VARCHAR(50), @userEmail VARCHAR(320), @profilePictureURL VARCHAR(2048),
@planTypeID INT, @dateJoined DATE, @userDuration INT, @audit_action VARCHAR(100);

SELECT @userID = i.userID, @displayName = i.displayName, @userFirstName = i.userFirstName, @userLastName = i.userLastName, @userEmail = i.userEmail,
@profilePictureURL = i.profilePictureURL, @planTypeID = i.planTypeID, @dateJoined = i.dateJoined, @userDuration = i.userDuration
FROM Inserted i;

SET @audit_action='Updated User''s Display Name -- Instead Of Update Trigger.';

BEGIN 
 BEGIN TRAN
    IF EXISTS (SELECT 1 FROM SpotifyUser WHERE displayName = @displayName AND userID <> @userID)
        BEGIN
            THROW 50062, 'This username is already taken', 1;
            ROLLBACK; 
        END

    IF EXISTS (SELECT 1 FROM SpotifyUser WHERE userEmail = @userEmail AND userID <> @userID)
        BEGIN
            THROW 50063, 'This email is already taken', 1;
            ROLLBACK; 
        END

	ELSE
		BEGIN
			IF UPDATE(displayName)
                UPDATE SpotifyUser
                SET displayName = @displayName
                WHERE userID = @userID
            
            IF UPDATE(userEmail)
                UPDATE SpotifyUser
                SET userEmail = @userEmail
                WHERE userID = @userID

			INSERT INTO SpotifyUser_LOG(userID, displayName, userFirstName, userLastName, userEmail, profilePictureURL, planTypeID, dateJoined, userDuration, log_action, log_timestamp)
				VALUES (@userID, @displayName, @userFirstName, @userLastName, @userEmail, @profilePictureURL, @planTypeID, @dateJoined, @userDuration, @audit_action, GETDATE());
				COMMIT;
				PRINT (CONCAT('The account information for user with id of ', @userID, ' had been updated successfully'))
				PRINT 'INSTEAD OF trigger fired successfully.'
		END
    END
GO

-- test the trigger
-- this is guaranteed to fail because a user with display name 'meganchiang' already exists
UPDATE SpotifyUser
SET displayName = 'meganchiang'
WHERE userID = 1

-- this is guaranteed to succeed
UPDATE SpotifyUser
SET displayName = 'SHernandez'
WHERE userID = 18

-- verify that it worked
select * from SpotifyUser_LOG
select * from SpotifyUser where userID = 18 -- should now be 'SHernandez'

-- INSTEAD OF-Delete Trigger 2 (Evonne): prevents duplicate playlist names
GO
CREATE OR ALTER TRIGGER trgInsteadOfInsertPlaylistName
ON Playlist
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Playlist p ON i.playlistName = p.playlistName AND i.userID = p.userID
    )

    BEGIN
        PRINT 'Duplicate playlist name detected for the same user. Insert operation prevented.';
    END

    ELSE
        BEGIN
            INSERT INTO Playlist (playlistName, userID, playlistDateCreated, playlistDescription, playlistImageURL)
            SELECT playlistName, userID, playlistDateCreated, playlistDescription, playlistImageURL
            FROM Inserted;
            PRINT 'Playlist inserted successfully.';
        END
    END;

-- test the trigger
-- guaranteed to fail because user already has playlist with this name
GO
INSERT INTO Playlist (playlistName, userID, playlistDateCreated, playlistDescription, playlistImageURL)
VALUES ('evonne''s playlist', 8, GETDATE(), 'favorite songs', NULL)

/* Write the SQL code to create one (1) computed column */
-- Note: For Deliverable 3, we had made 2 computed columns each, so we are using some of the columns we have already made
-- Computed Column 1 (Megan):
ALTER TABLE Song
ADD songTotalSeconds AS (songMinutes * 60) + songSeconds; -- this column already exists in the Song table (from Deliverable 3)

-- Computed Column 2 (Evonne):
ALTER TABLE SpotifyUser
ADD userDuration AS DATEDIFF(day, dateJoined, GETDATE()); -- this column already exists in the SpotifyUser table (from Deliverable 3)

/* Write the SQL code to create two (2) different complex queries. One of these queries should use a stored procedure that takes given inputs and returns the expected output. */
-- Complex Query 1 (Megan): Given a year and number of results, what are the most listened-to songs?
GO
CREATE OR ALTER PROCEDURE uspSelectPopularSongs(
    @year INT,
    @numRows INT
    )
    AS
    BEGIN
        IF @year < 0 OR @year > YEAR(GETDATE())
        BEGIN
            RAISERROR ('Invalid year; process is terminating', 11, 1)
            RETURN
        END

        IF @numRows <= 0
        BEGIN
            RAISERROR ('Invalid number of results; process is terminating', 11, 1)
            RETURN
        END

        SELECT TOP (@numRows) s.songName, (ar.artistFirstName + ' ' + ISNULL(ar.artistLastName, '')) AS artistName, al.albumName, COUNT(*) AS num_plays
        FROM ListenHistory l
        JOIN Song s 
            ON l.songID = s.songID
        JOIN Artist ar 
            ON s.artistID = ar.artistID
        JOIN Album al
            ON s.albumID = al.albumID
        WHERE YEAR(l.timeListened) = @year
        GROUP BY l.songID, s.songName, ar.artistFirstName, ar.artistLastName, al.albumName
        ORDER BY num_plays DESC;
        RETURN;
    END

-- test stored procedure:
-- guaranteed to work
EXEC uspSelectPopularSongs 2024, 2

-- guaranteed to fail (invalid year)
EXEC uspSelectPopularSongs 2025, 2

-- -- guaranteed to fail (invalid number of rows)
EXEC uspSelectPopularSongs 2023, -1

GO

-- Complex Query 2 (Megan): For each year, what was the most frequently listened-to genre?
WITH genre_plays AS (
    SELECT YEAR(timeListened) AS year_played, g.genreName, COUNT(*) as num_plays
    FROM ListenHistory l 
    JOIN SongGenreDetails sg
        ON l.songID = sg.songID
    JOIN Genre g 
        ON sg.genreID = g.genreID
    GROUP BY YEAR(timeListened), g.genreName
),
max_play_counts AS (
    SELECT year_played, MAX(num_plays) AS max_plays 
    FROM genre_plays
    GROUP BY year_played
)
SELECT g.year_played, g.genreName, g.num_plays
FROM genre_plays g 
JOIN max_play_counts m 
    ON g.year_played = m.year_played
        AND g.num_plays = m.max_plays
ORDER BY g.year_played DESC;

-- Complex Query 3 (Evonne): Statistics on the number of listens for each combination of genre and artist.
WITH song_genre_counts AS (
    SELECT sg.genreID, s.artistID, COUNT(*) AS listen_count
    FROM ListenHistory lh
    JOIN Song s ON lh.songID = s.songID
    JOIN SongGenreDetails sg ON s.songID = sg.songID
    GROUP BY sg.genreID, s.artistID
),
max_genre_counts AS (
    SELECT genreID, MAX(listen_count) AS max_listen_count
    FROM song_genre_counts
    GROUP BY genreID
)
SELECT 
    g.genreName, CONCAT(ar.artistFirstName + ' ' + ar.artistLastName, '') AS artistName, sgc.listen_count
FROM song_genre_counts sgc
JOIN max_genre_counts mgc ON sgc.genreID = mgc.genreID AND sgc.listen_count = mgc.max_listen_count
JOIN Genre g ON sgc.genreID = g.genreID
JOIN Artist ar ON sgc.artistID = ar.artistID
ORDER BY sgc.listen_count DESC;

-- Complex Query 4 (Evonne): Given a SpotifyUser's display name, return the top 5 most listened-to genres in their playlists
GO
CREATE OR ALTER PROCEDURE uspTopGenresByUser(
    @displayName VARCHAR(30)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM SpotifyUser WHERE displayName = @displayName)
    BEGIN
        RAISERROR ('User with provided display name does not exist', 16, 1)
        RETURN
    END

    SELECT TOP 5 g.genreName, COUNT(*) AS num_listens
    FROM ListenHistory lh
    JOIN PlaylistTrack pt ON lh.songID = pt.songID
    JOIN Playlist p ON pt.playlistID = p.playlistID
    JOIN SpotifyUser su ON p.userID = su.userID
    JOIN SongGenreDetails sgd ON lh.songID = sgd.songID
    JOIN Genre g ON sgd.genreID = g.genreID
    WHERE su.displayName = @displayName
    GROUP BY g.genreName
    ORDER BY num_listens DESC;
END;
GO

-- test stored procedure:
EXEC uspTopGenresByUser 'evonnela' 