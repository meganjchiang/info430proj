/* 
INFO 430: Database Design and Management 
Project Deliverable 3: Physical Design and Database Implementation
Project Topic: Spotify Database
Students: Evonne La & Megan Chiang
Due Date: Sunday, April 28, 2024
*/

/* Creating the Database and Table Structure */
-- CREATE DATABASE spotify_db_el_mc
GO

-- Drop tables if they exist
IF OBJECT_ID('ListenHistory', 'U') IS NOT NULL
    DROP TABLE ListenHistory;
IF OBJECT_ID('PlaylistTrack', 'U') IS NOT NULL
    DROP TABLE PlaylistTrack;
IF OBJECT_ID('Playlist', 'U') IS NOT NULL
    DROP TABLE Playlist;
IF OBJECT_ID('UserFollowerDetails', 'U') IS NOT NULL
    DROP TABLE UserFollowerDetails;
IF OBJECT_ID('Follower', 'U') IS NOT NULL
    DROP TABLE Follower;
IF OBJECT_ID('SpotifyUser', 'U') IS NOT NULL
    DROP TABLE SpotifyUser;
IF OBJECT_ID('SongGenreDetails', 'U') IS NOT NULL
    DROP TABLE SongGenreDetails;
IF OBJECT_ID('Song', 'U') IS NOT NULL
    DROP TABLE Song;
IF OBJECT_ID('Album', 'U') IS NOT NULL
    DROP TABLE Album;
IF OBJECT_ID('PlanType', 'U') IS NOT NULL
    DROP TABLE PlanType;
IF OBJECT_ID('Genre', 'U') IS NOT NULL
    DROP TABLE Genre;
IF OBJECT_ID('Artist', 'U') IS NOT NULL
    DROP TABLE Artist;

CREATE TABLE Artist (
   artistID INT PRIMARY KEY identity(1, 1) NOT NULL,
   artistFirstName VARCHAR(50) NOT NULL,
   artistLastName VARCHAR(50),
   artistDescription VARCHAR(500) NOT NULL,
   artistImageURL VARCHAR(2048),
   CONSTRAINT check_unique_artist
   UNIQUE(artistFirstName, artistLastName)
)

CREATE TABLE Genre (
   genreID INT PRIMARY KEY identity(1, 1) NOT NULL,
   genreName VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE PlanType (
   planTypeID INT PRIMARY KEY identity(1, 1) NOT NULL,
   planTypeName VARCHAR(50) UNIQUE NOT NULL,
   planCost MONEY NOT NULL,
   CONSTRAINT check_plan_type -- check constraint (Megan)
   CHECK(planCost >= 0)
)

CREATE TABLE Album (
   albumID INT PRIMARY KEY identity(1, 1) NOT NULL,
   albumName VARCHAR(50) NOT NULL,
   artistID INT NOT NULL,
   releaseDate DATE NOT NULL,
   albumImageURL VARCHAR(2048) NOT NULL,
   albumHours INT NOT NULL,
   albumMinutes INT NOT NULL,
   albumTotalMinutes AS (albumHours * 60) + albumMinutes, -- computed column (Megan)
   CONSTRAINT fk_album_artist
   FOREIGN KEY(artistID) REFERENCES Artist(ArtistID),
   CONSTRAINT check_minutes -- check constraint (Megan)
   CHECK(albumMinutes BETWEEN 0 AND 59),
   CONSTRAINT check_unique_album_artist
   UNIQUE(albumName, artistID)
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
   CHECK(songSeconds BETWEEN 0 AND 59),
   CONSTRAINT check_unique_song_artist
   UNIQUE(songName, artistID)
)

CREATE TABLE SongGenreDetails (
   songGenreID INT PRIMARY KEY identity(1, 1) NOT NULL,
   songID INT NOT NULL,
   genreID INT NOT NULL,
   CONSTRAINT fk_song
   FOREIGN KEY(songID) REFERENCES Song(songID),
   CONSTRAINT fk_genre
   FOREIGN KEY(genreID) REFERENCES Genre(genreID),
   CONSTRAINT check_unique_song_genre
   UNIQUE(songID, genreID)
)

CREATE TABLE SpotifyUser (
   userID INT PRIMARY KEY identity(1, 1) NOT NULL,
   displayName VARCHAR(30) UNIQUE NOT NULL,
   userFirstName VARCHAR(50) NOT NULL,
   userLastName VARCHAR(50) NOT NULL,
   userEmail VARCHAR(320) UNIQUE NOT NULL,
   profilePictureURL VARCHAR(2048),
   planTypeID INT NOT NULL,
   dateJoined DATE NOT NULL,
   userDuration AS DATEDIFF(day, dateJoined, GETDATE()), -- computed column (Evonne)
   CONSTRAINT fk_user_plan_type
   FOREIGN KEY(planTypeID) REFERENCES PlanType(planTypeID), 
   CONSTRAINT check_user_email_format -- check constraint (Evonne)
   CHECK (userEmail LIKE '%_@_%._%') 
)

CREATE TABLE Follower (
   followerID INT PRIMARY KEY identity(1, 1) NOT NULL,
   userID INT UNIQUE NOT NULL,
   CONSTRAINT fk_follower_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID)
)

CREATE TABLE UserFollowerDetails (
   followRelationshipID INT PRIMARY KEY identity(1, 1) NOT NULL,
   userID INT NOT NULL,
   followerID INT NOT NULL,
   dateFollowed DATE NOT NULL,
   followDuration AS DATEDIFF(day, dateFollowed, GETDATE()), -- computed column (Evonne)
   CONSTRAINT fk_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID),
   CONSTRAINT fk_follower
   FOREIGN KEY(followerID) REFERENCES Follower(followerID),
   CONSTRAINT check_unique_user_follower
   UNIQUE(userID, followerID)
)

CREATE TABLE Playlist (
   playlistID INT PRIMARY KEY identity(1, 1) NOT NULL,
   playlistName VARCHAR(100) NOT NULL,
   userID INT NOT NULL,
   playlistDateCreated DATE NOT NULL,
   playlistDescription VARCHAR(500),
   playlistImageURL VARCHAR(2048),
   CONSTRAINT fk_playlist_user
   FOREIGN KEY(userID) REFERENCES SpotifyUser(userID),
   CONSTRAINT check_unique_playlist
   UNIQUE(playlistName, userID, playlistDateCreated)
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
   CONSTRAINT check_time_listened_validity -- check constraint (Evonne)
   CHECK (timeListened <= GETDATE()),
   CONSTRAINT check_unique_user_song_listen_time
   UNIQUE(userID, songID, timeListened)
)

/* Populating the Tables with Data */
INSERT INTO Artist (artistFirstName, artistLastName, artistDescription, artistImageURL)
VALUES 
    ('Taylor', 'Swift', 'American singer-songwriter', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Taylor_Swift_at_the_2023_MTV_Video_Music_Awards_%283%29.png/1200px-Taylor_Swift_at_the_2023_MTV_Video_Music_Awards_%283%29.png'),
    ('Harry', 'Styles', 'English singer-songwriter', 'https://variety.com/wp-content/uploads/2022/11/Harry-Styles.jpg?w=1000'),
    ('Olivia', 'Rodrigo', 'American singer-songwriter', 'https://www.billboard.com/wp-content/uploads/2023/08/olivia-rodrigo-press-cr-Zamar-Velez-2023-billboard-1548.jpg?w=942&h=623&crop=1'),
    ('Beyonce', NULL, 'American singer-songwriter', 'https://assets.bwbx.io/images/users/iqjWHBFdfxIU/i5_V6LnkPnR0/v1/-1x-1.jpg'),
    ('Post', 'Malone', 'American singer-songwriter', 'https://www.billboard.com/wp-content/uploads/2023/04/02-post-malone-press-2023-cr-Emma-Louise-Swanson-billboard-1548.jpg'),
    ('Sabrina', 'Carpenter', 'American singer-songwriter', 'https://assets.teenvogue.com/photos/65c24d26781384320621e8f8/2:3/w_1590,h_2385,c_limit/1984755401'),
    ('Laufey', NULL, 'Icelandic-Chinese singer-songwriter', 'https://images.squarespace-cdn.com/content/v1/60300340d27ffb2c6946ccbe/3fff0229-0816-4d9e-9367-159f92059501/Goddess-WebsiteBackground-1500px.png'),
    ('SEVENTEEN', NULL, 'South Korean boy band', 'https://images.squarespace-cdn.com/content/v1/62e0a51c3280db7edc1448d5/1a88f88b-47aa-4b78-8641-1b2911e2331f/Seventeen.jpg'),
    ('Shania', 'Twain', 'Candadian singer-songwriter', 'https://s.abcnews.com/images/GMA/shania-twain-file-gty-220727_1658928618217_hpMain.jpg'),
    ('Andrea', 'Bocelli', 'Italian tenor', 'https://upload.wikimedia.org/wikipedia/commons/3/35/Andrea_Bocelli_20190511_017-2_%28cropped%29.jpg'),
    ('Nubya', 'Garcia', 'English jazz musician and saxophonist', 'https://images.squarespace-cdn.com/content/v1/5b23cda7e2ccd13a109a4f8b/1618326247593-MTEWHCE6AYF57ZOFJ50R/shot_01_nubya_garcia_076_r1_srgb.jpg'),
    ('Metallica', NULL, 'American metal band', 'https://www.udiscovermusic.com/wp-content/uploads/2020/11/Metallica-GettyImages-531257207-1000x600.jpg'),
    ('The Smiths', NULL, 'English rock band', 'https://media.npr.org/assets/img/2012/01/23/smiths-wrightphoto.co_.uk__0_wide-b866127b40d968ebf7502f5e7e7a5585d1ea8d04-s1400-c100.jpg'),
    ('Lorde', NULL, 'New Zealand singer-songwriter', 'https://media.vanityfair.com/photos/593183cbec96261e360c6947/master/pass/hot-tracks-lorde-06-17.jpg'),
    ('One Direction', NULL, 'English-Irish boy band', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSOmDwMYlY9I_3Ph5eM_Dl6cUmLy3rW_QgFKrVC8qJLqDc1rsT6'),
    ('Nicki', 'Minaj', 'Trinidadian rapper and singer', 'https://ca-times.brightspotcdn.com/dims4/default/b86f013/2147483647/strip/true/crop/4176x2784+0+0/resize/1200x800!/quality/75/?url=https%3A%2F%2Fcalifornia-times-brightspot.s3.amazonaws.com%2F2a%2F99%2F0509b7c34a068062d9024f1d456e%2Fla-ca-nicki-minaj-110.JPG'),
    ('Aphex', 'Twin', 'British musician and composer', 'https://res.cloudinary.com/electronic-beats/c_fit,q_auto,f_auto,w_1920/stage/uploads/2013/08/aphex-twin-electronic-beats.jpg'),
    ('Kendrick', 'Lamar', 'American rapper and singer-songwriter', 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQpXGKZgni7hwvYnFUen08LQP43RoFAhJc_p6XQ1yL3uDne6GjX'),
    ('Pearl Jam', NULL, 'American rock band', 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQ8XDZna5SZwxVTg6YL8cddRaKOFF0WcJHKy0EjMZ4Vz8i6jbQE'),
    ('Stevie', 'Wonder', 'American singer-songwriter and musician', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTBPG8lmZR5oWGGKgKL8nscPJEFfPxpDel1CPMHAUKHcnhDl3M8')

INSERT INTO Genre (genreName)
VALUES  
    ('Pop'),
    ('Rock'),
    ('Indie'),
    ('R&B'),
    ('Rap'),
    ('Electronic'),
    ('Country'),
    ('Alternative'),
    ('Metal'),
    ('Hip Hop'),
    ('Classical'),
    ('Jazz'),
    ('K-Pop')    

INSERT INTO PlanType (planTypeName, planCost)
VALUES
    ('Free', 0),
    ('Premium Individual', 10.99),
    ('Premium Student', 5.99),
    ('Premium Duo', 14.99),
    ('Premium Family', 16.99),
    ('Premium Trial', 0)

INSERT INTO Album (albumName, artistID, releaseDate, albumImageURL, albumHours, albumMinutes)
VALUES
    ('THE TORTURED POETS DEPARTMENT', 1, '2024-04-19', 'https://static01.nyt.com/images/2024/04/19/multimedia/19swift-arrival-qfgw/19swift-arrival-qfgw-articleLarge.jpg?quality=75&auto=webp&disable=upscale', 1, 5),
    ('folklore', 1, '2020-07-24', 'https://upload.wikimedia.org/wikipedia/en/f/f8/Taylor_Swift_-_Folklore.png', 1, 3),
    ('Harry''s House', 2, '2022-05-20', 'https://media.architecturaldigest.com/photos/623e05e0b06d6c32457e4358/master/w_1600%2Cc_limit/FINAL%2520%2520PFHH-notextwlogo.jpg', 0, 41),
    ('GUTS', 3, '2023-09-08', 'https://upload.wikimedia.org/wikipedia/en/0/03/Olivia_Rodrigo_-_Guts.png', 0, 39),
    ('RENAISSANCE', 4, '2022-07-29', 'https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Renaissance_LP_Cover_Art.png/220px-Renaissance_LP_Cover_Art.png', 2, 48),
    ('Hollywood''s Bleeding', 5, '2019-09-06', 'https://upload.wikimedia.org/wikipedia/en/5/58/Post_Malone_-_Hollywood%27s_Bleeding.png', 0, 51),
    ('emails i can''t send fwd:', 6, '2022-07-15', 'https://upload.wikimedia.org/wikipedia/en/thumb/7/78/Sabrina_Carpenter_-_Emails_I_Can%27t_Send.png/220px-Sabrina_Carpenter_-_Emails_I_Can%27t_Send.png', 0, 39),
    ('Bewitched', 7, '2023-09-08', 'https://m.media-amazon.com/images/I/81m3iTR5bjL._UF1000,1000_QL80_.jpg', 0, 48),
    ('SOUR', 3, '2021-05-21', 'https://m.media-amazon.com/images/I/71Te1V90YDL._UF1000,1000_QL80_.jpg', 0, 34),
    ('Speak Now (Taylor''s Version)', 1, '2023-07-07', 'https://m.media-amazon.com/images/I/71QgmF3cnEL._UF1000,1000_QL80_.jpg', 1, 44),
    ('Attaca', 8, '2021-10-22', 'https://upload.wikimedia.org/wikipedia/en/7/75/Seventeen_-_Attacca.png', 0, 22),
    ('FOUR', 15, '2014-11-17', 'https://upload.wikimedia.org/wikipedia/en/e/e8/One_Direction_-_Four.png', 0, 43),
    ('The Woman in Me', 9, '1995-02-07', 'https://upload.wikimedia.org/wikipedia/en/d/d2/Shania_Twain_-_The_Woman_in_Me.png', 0, 48),
    ('Love In Portofino', 10, '2013-10-21', 'https://m.media-amazon.com/images/I/915VcxVNdOL._UF1000,1000_QL80_.jpg', 0, 36),
    ('Source', 11, '2020-08-21', 'https://upload.wikimedia.org/wikipedia/en/d/d0/Nubya_Garcia_-_Source_%28Album_Cover%29.jpg', 1, 0),
    ('Ride the Lightning', 12, '1984-07-27', 'https://upload.wikimedia.org/wikipedia/en/f/f4/Ridetl.png', 0, 47),
    ('The Queen Is Dead', 13, '1986-06-16', 'https://upload.wikimedia.org/wikipedia/en/e/ed/The-Queen-is-Dead-cover.png', 0, 36),
    ('Melodrama', 14, '2017-06-16', 'https://upload.wikimedia.org/wikipedia/en/b/b2/Lorde_-_Melodrama.png', 0, 40),
    ('Pink Friday', 16, '2010-11-22', 'https://upload.wikimedia.org/wikipedia/en/f/f1/Pink_Friday_album_cover.jpg', 0, 50),
    ('Selected Ambient Works 85-92', 17, '1992-11-09', 'https://upload.wikimedia.org/wikipedia/en/8/82/Selected_Ambient_Works_85-92.png', 1, 14),
    ('DAMN.', 18, '2017-04-14', 'https://upload.wikimedia.org/wikipedia/en/5/51/Kendrick_Lamar_-_Damn.png', 0, 54),
    ('Ten', 19, '1991-08-27', 'https://upload.wikimedia.org/wikipedia/en/2/2d/PearlJam-Ten2.jpg', 0, 53),
    ('Songs in the Key of Life', 20, '1976-09-28', 'https://upload.wikimedia.org/wikipedia/en/e/e2/Songs_in_the_key_of_life.jpg', 0, 21)

INSERT INTO Song (songName, artistID, albumID, songMinutes, songSeconds)
VALUES
    ('Florida!!!', 1, 1, 3, 35),
    ('As It Was', 2, 3, 2, 47),
    ('vampire', 3, 4, 3, 40),
    ('COZY', 4, 5, 3, 30),
    ('Circle', 5, 6, 3, 37),
    ('Nonsense', 6, 7, 2, 43),
    ('From the Start', 7, 8, 2, 49), 
    ('love is embarrassing', 3, 4, 2, 34),
    ('AMERICA HAS A PROBLEM', 4, 5, 3, 18),
    ('18', 15, 12, 4, 8),
    ('Any Man of Mine', 9, 13, 4, 7),
    ('Love In Portofino', 10, 14, 2, 59),
    ('Pace', 11, 15, 7, 53),
    ('Fight Fire With Fire', 12, 16, 4, 45),
    ('The Queen Is Dead', 13, 17, 6, 24),
    ('The Louvre', 14, 18, 3, 55),
    ('Super Bass', 16, 19, 3, 20),
    ('ELEMENT.', 18, 21, 1, 58),
    ('Oceans', 19, 22, 2, 42),
    ('Sir Duke', 20, 23, 3, 54), 
    ('betty', 1, 2, 4, 54), 
    ('traitor', 3, 9, 3, 49),
    ('Mine (Taylor''s Version)', 1, 10, 3, 51)

INSERT INTO SongGenreDetails (songID, genreID)
VALUES
    (1, 1),
    (1, 2),
    (2, 1), 
    (3, 1), 
    (3, 2), 
    (4, 1), 
    (5, 1), 
    (6, 1), 
    (7, 1), 
    (7, 12), 
    (8, 3), 
    (8, 8), 
    (9, 4), 
    (9, 10), 
    (10, 1), 
    (11, 7), 
    (12, 11), 
    (13, 12), 
    (14, 9), 
    (15, 1), 
    (15, 3), 
    (16, 1), 
    (16, 8), 
    (17, 1), 
    (17, 5), 
    (18, 5),
    (18, 10),
    (19, 2),
    (20, 4),
    (21, 1),
    (21, 7), 
    (22, 1), 
    (22, 3),
    (23, 1)

INSERT INTO SpotifyUser (displayName, userFirstName, userLastName, userEmail, profilePictureURL, planTypeID, dateJoined)
VALUES
    ('JohnDoe', 'John', 'Doe', 'john@example.com', 'https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg?crop=0.752xw:1.00xh;0.175xw,0&resize=1200:*', 2, '2023-01-01'),
    ('JaneSmith', 'Jane', 'Smith', 'jane@example.com', 'https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg', 3, '2023-02-15'),
    ('AliceJohnson', 'Alice', 'Johnson', 'alice@example.com', 'https://www.princeton.edu/sites/default/files/styles/1x_full_2x_half_crop/public/images/2022/02/KOA_Nassau_2697x1517.jpg?itok=Bg2K7j7J', 2, '2023-03-20'),
    ('BobWilliams', 'Bob', 'Williams', 'bob@example.com', 'https://www.akc.org/wp-content/uploads/2017/11/Golden-Retriever-Puppy.jpg', 5, '2023-04-10'),
    ('EmilyBrown', 'Emily', 'Brown', 'emily@example.com', 'https://us.yumove.com/cdn/shop/articles/Dog_ageing_puppy.jpg?v=1582123836', 4, '2023-05-05'),
    ('MichaelTaylor', 'Michael', 'Taylor', 'michael@example.com', 'https://www.southernliving.com/thmb/a4b73J7C4S4wgSmymmEgXRCmACA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-185743593-2000-507c6c8883a44851885ea4fbc10a2c9e.jpg', 2, '2023-06-20'),
    ('meganchiang', 'Megan', 'Chiang', 'mjchiang@uw.edu', 'https://favim.com/pd/p/orig/2018/09/22/buttercup-sleep-ppg-Favim.com-6357107.jpg', 3, '2024-04-27'), 
    ('evonnela', 'Evonne', 'La', 'evonnela@uw.edu', 'https://t3.ftcdn.net/jpg/02/99/23/70/360_F_299237086_LSGXAAWR049NBUct3snKiOKNhRLDKyEW.jpg', 3, '2024-04-28'),
    ('AndrewClark', 'Andrew', 'Clark', 'andrew@example.com', 'https://media-be.chewy.com/wp-content/uploads/2022/09/27095535/cute-dogs-pembroke-welsh-corgi.jpg', 4, '2024-05-20'),
    ('OliviaMartinez', 'Olivia', 'Martinez', 'olivia@example.com', 'https://paradepets.com/.image/ar_4:3%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MTkxMzY1Nzg4NjczMzIwNTQ2/cutest-dog-breeds-jpg.jpg', 2, '2024-06-01'),
    ('DanielGarcia', 'Daniel', 'Garcia', 'daniel@example.com', 'https://hips.hearstapps.com/hmg-prod/images/cutest-dog-breed-bernese-64356a43dbcc5.jpg', 3, '2024-06-15'),
    ('SophiaHernandez', 'Sophia', 'Hernandez', 'sophia@example.com', 'https://i.pinimg.com/236x/84/98/7e/84987ef2b2982b032a83417db2d2a2d2.jpg', 1, '2024-07-01'),
    ('MatthewYoung', 'Matthew', 'Young', 'matthew@example.com', 'https://images.unsplash.com/photo-1615751072497-5f5169febe17?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y3V0ZSUyMGRvZ3xlbnwwfHwwfHx8MA%3D%3D', 5, '2024-07-10'),
    ('AvaLee', 'Ava', 'Lee', 'ava@example.com', 'https://www.thesprucepets.com/thmb/aakdWmF36D3RYti507u94vWSwy0=/3600x0/filters:no_upscale():strip_icc()/cute-dog-breeds-we-can-t-get-enough-of-4589340-14-4cdb2f10e1654a468f13cd95ff880834.jpg', 2, '2024-07-20'),
    ('ChristopherRodriguez', 'Christopher', 'Rodriguez', 'christopher@example.com', 'https://hips.hearstapps.com/hmg-prod/images/funny-dog-captions-1563456605.jpg?crop=0.748xw:1.00xh;0.0897xw,0&resize=1200:*', 3, '2024-08-05'),
    ('MiaGonzalez', 'Mia', 'Gonzalez', 'mia@example.com', 'https://hips.hearstapps.com/wdy.h-cdn.co/assets/17/39/1600x1066/gallery-1506709524-cola-0247.jpg?resize=640:*', 4, '2024-08-15'),
    ('WilliamMartinez', 'William', 'Martinez', 'william@example.com', 'https://images.pexels.com/photos/2607544/pexels-photo-2607544.jpeg?cs=srgb&dl=pexels-simonakidric-2607544.jpg&fm=jpg', 2, '2024-09-01'),
    ('SofiaHernandez', 'Sofia', 'Hernandez', 'sofia@example.com', 'https://paradepets.com/.image/t_share/MTkxMzY1Nzg4NDA4ODgyNzg2/bichon-frise-dog.jpg', 3, '2024-09-10')

INSERT INTO Follower (userID)
VALUES 
    (2), 
    (3),
    (4),
    (5),
    (6),
    (1),
    (7), 
    (8), 
    (9),
    (10),
    (11),
    (12),
    (13),
    (14),
    (15),
    (16),
    (17),
    (18)

INSERT INTO UserFollowerDetails (userID, followerID, dateFollowed)
VALUES
    (1, 2, '2023-01-01'),
    (2, 3, '2023-02-15'),
    (3, 4, '2023-03-20'),
    (4, 5, '2023-04-10'),
    (5, 6, '2023-05-05'),
    (6, 1, '2023-06-20'),
    (2, 1, '2023-02-14'),
    (7, 1, '2023-04-28'), 
    (8, 3, '2023-04-21'),
    (9, 4, '2023-04-22'),
    (10, 5, '2023-04-23'),
    (11, 6, '2023-04-24'),
    (12, 1, '2023-04-25'),
    (13, 2, '2023-04-26'),
    (14, 3, '2023-04-27'),
    (15, 4, '2023-04-28'),
    (16, 5, '2023-04-29'),
    (17, 6, '2023-04-30'),
    (18, 1, '2023-05-01')

INSERT INTO Playlist (playlistName, userID, playlistDateCreated, playlistDescription, playlistImageURL)
VALUES
    ('Top Hits', 1, '2020-01-01', 'Collection of top songs', 'https://c8.alamy.com/comp/2DAD7D2/top-hits-stamp-top-hits-sign-round-grunge-label-2DAD7D2.jpg'),
    ('Chill Vibes', 2, '2020-11-05', 'Relaxing music for any mood', 'https://c8.alamy.com/zooms/9/fea52cd0567241618d28f3bbbe97e1aa/2h31w35.jpg'),
    ('Study Jams', 3, '2023-07-07', 'Concentration music for studying', 'https://lbhspawprint.com/wp-content/uploads/2021/05/studying-and-music-2-28xswo9.jpg'),
    ('Workout Mix', 4, '2024-04-03', 'Energetic tracks for workouts', 'https://i0.wp.com/post.healthline.com/wp-content/uploads/2023/02/female-dumbbells-1296x728-header-1296x729.jpg?w=1155&h=2268'),
    ('Road Trip Tunes', 5, '2021-12-13', 'Songs for a perfect road trip', 'https://www.wandering-bird.com/wp-content/uploads/2018/07/songs2-768x512.jpg'),
    ('Late Night Melodies', 6, '2024-01-01', 'Songs for winding down', 'https://i.pinimg.com/736x/de/35/98/de359848fb0d981c2b22f14e9fa4de00.jpg'),
    ('on repeat', 7, '2024-04-26', 'my favorite songs at the moment!', NULL), 
    ('spring songs', 8, '2024-04-28', 'songs that remind of me spring', NULL)

INSERT INTO PlaylistTrack (playlistID, songID)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (1, 3),
    (1, 6),
    (7, 3),
    (7, 6),
    (7, 7),
    (7, 10),
    (7, 11), 
    (8, 1), 
    (8, 2), 
    (8, 3), 
    (8, 5), 
    (8, 8), 
    (8, 10), 
    (8, 21), 
    (8, 22), 
    (8, 23)

INSERT INTO ListenHistory (userID, songID, timeListened)
VALUES 
    (1, 1, '2022-04-30 08:30:00'),
    (2, 2, '2023-02-15 12:45:00'),
    (3, 3, '2024-03-20 17:20:00'),
    (4, 4, '2023-04-10 10:10:00'),
    (5, 5, '2023-05-05 14:30:00'),
    (6, 6, '2023-06-20 20:00:00'),
    (7, 10, '2024-01-05 12:35:20'),
    (7, 10, '2024-02-14 11:30:0'),
    (7, 8, '2024-04-27 22:10:59'), 
    (8, 1, '2024-04-20 12:35:20'),
    (8, 2, '2022-05-21 11:30:0'),
    (8, 21, '2024-04-10 22:10:59')

/* Coding Database Objects */
-- Stored Procedure 1 (Megan): Insert into User table
GO
CREATE OR ALTER PROCEDURE uspInsertUser(
    @displayName VARCHAR(30),
    @firstName VARCHAR(50),
    @lastName VARCHAR(50),
    @email VARCHAR(320),
    @profilePictureURL VARCHAR(2048) = NULL,
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
            RAISERROR ('@planTypeID is NULL; plan type does not exist so process is terminating', 11,1)
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

/* examples
EXEC uspInsertUser 'meganchiang', 'Megan', 'Chiang', 'mjchiang@uw.edu', 'https://favim.com/pd/p/orig/2018/09/22/buttercup-sleep-ppg-Favim.com-6357107.jpg', 'Premium Student', '2024-04-27'
*/

-- Stored Procedure 2 (Megan): Insert into Playlist table
GO
CREATE OR ALTER PROCEDURE uspInsertPlaylist(
    @playlistName VARCHAR(100),
    @userDisplayName VARCHAR(30),
    @playlistDateCreated DATE,
    @playlistDescription VARCHAR(500) = NULL,
    @playlistImageURL VARCHAR(2048) = NULL
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
            RAISERROR ('@userID cannot be NULL; user does not exist so process is terminating', 11,1)
            RETURN
        END

        BEGIN TRY
            BEGIN TRANSACTION T1;
                INSERT INTO Playlist (playlistName, userID, playlistDateCreated, playlistDescription, playlistImageURL)
                VALUES (@playlistName, @userID, @playlistDateCreated, @playlistDescription, @playlistImageURL)
            COMMIT TRANSACTION T1;
        END TRY

        BEGIN CATCH
            ROLLBACK TRANSACTION T1;
        END CATCH  
    END

/* example
uspInsertPlaylist 'favorites', 'meganchiang', '2024-04-26'
*/

-- Stored Procedure 3 (Evonne): Insert into Song table
GO
CREATE OR ALTER PROCEDURE uspInsertSong(
    @songName VARCHAR(100),
    @artistFirstName VARCHAR(50),
    @artistLastName VARCHAR(50) = NULL,
    @albumName VARCHAR(50),
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
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
        )

        IF @artistID IS NULL
        BEGIN
            RAISERROR ('@artistID cannot be NULL; process is terminating', 11, 1)
            RETURN
        END

        SET @albumID = (
            SELECT albumID
            FROM Album
            WHERE albumName = @albumName AND artistID = @artistID
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

/* examples
EXEC uspInsertSong 'love is embarrassing', 'Olivia', 'Rodrigo', 'GUTS', 2, 34
EXEC uspInsertSong 'AMERICA HAS A PROBLEM', 'Beyonce', NULL, 'RENAISSANCE', 3, 18
EXEC uspInsertSong 'To you', 'SEVENTEEN', NULL, 'Attaca', 3, 45
*/

-- Stored Procedure 4 (Evonne): Insert into Album table
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
            WHERE artistFirstName = @artistFirstName 
                AND (artistLastName = @artistLastName 
                    OR (artistLastName IS NULL AND @artistLastName IS NULL))
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

/* examples
EXEC uspInsertAlbum 'SOUR', 'Olivia', 'Rodrigo', '2021-05-21', 'https://m.media-amazon.com/images/I/71Te1V90YDL._UF1000,1000_QL80_.jpg', 0, 34
EXEC uspInsertAlbum 'Speak Now (Taylor''s Version)', 'Taylor', 'Swift', '2023-07-07', 'https://m.media-amazon.com/images/I/71QgmF3cnEL._UF1000,1000_QL80_.jpg', 1, 44
EXEC uspInsertAlbum 'Attaca', 'SEVENTEEN', NULL, '2021-10-22', 'https://upload.wikimedia.org/wikipedia/en/7/75/Seventeen_-_Attacca.png', 0, 22
*/

/* Views (no longer required for assignment) */
-- Drop views if they exist
GO
IF OBJECT_ID('top_10_listened_songs_2024', 'V') IS NOT NULL
    DROP VIEW top_10_listened_songs_2024;
IF OBJECT_ID('user_top_genre', 'V') IS NOT NULL
    DROP VIEW user_top_genre;
IF OBJECT_ID('top_10_users_with_most_followers', 'V') IS NOT NULL
    DROP VIEW top_10_users_with_most_followers;
IF OBJECT_ID('top_3_most_popular_plans', 'V') IS NOT NULL
    DROP VIEW top_3_most_popular_plans;

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
            u.displayName,
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
        GROUP BY u.userID, u.displayName, g.genreName
    )
    SELECT userID, displayName, genreName
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
