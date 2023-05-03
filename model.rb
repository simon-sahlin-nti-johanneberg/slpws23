# Connects to the database
#
# @param database [String] the path of the database to connect to
def connect_to_db(database)
    db = SQLite3::Database.new(database)
    db.results_as_hash = true
    db.execute("PRAGMA foreign_keys = ON")
    return db
end

########################################################

# Gets all the records from a table
#
# @param table [String] the name of the table to query
def get_all(table)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table}")
    return result
end

# Gets a record from a table by its ID
#
# @param table [String] the name of the table to query
# @param id [Integer] the ID of the record to retrieve
def get_all_from_id(table, id)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table} WHERE id = ?", id).first
    return result
end

# Gets all the records from a table where a specified column matches a given value
#
# @param table [String] the name of the table to query
# @param where [String] the name of the column to match
# @param id [Integer] the value to match against
def get_all_from_where(table, where, id)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table} WHERE #{where} = ?", id)
    return result
end

# Deletes a record from a table by its ID
#
# @param table [String] the name of the table to delete from
def delete_id(table, id)
    db = connect_to_db("db/database.db")
    db.execute("DELETE FROM #{table} WHERE id = ?", id)
end

# Updates a record in a table by its ID
#
# @param table [String] the name of the table to update
# @param name [String] the name of the column to update
# @param value [String] the new value for the column
def update_value(table, name, value, id)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE #{table} SET #{name}=? WHERE id=?", value, id)
end

##########################################################

# Creates a new empty game record in the database
#
def create_game()
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO games (title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", "Game Title", "Tagline", "", "Game Description", 0, "img/thumbnails/thumb-Blinded.jpg", "", "", "#eeeeee", "#ffffff", "#e5e5e5", "#222222", "#fa5c5c")
end

# Updates an existing game record in the database
#
# @param id [Integer] the ID of the game to update
# @param title [String] the new title for the game
# @param tagline [String] the new tagline for the game
# @param iframePath [String] the new iframe path for the game
# @param fullDescription [String] the new full description for the game
# @param visible [Integer] the new visibility status for the game
# @param thumbnailImage [String] the new thumbnail image path for the game
# @param bgImage [String] the new background image path for the game
# @param bannerImage [String] the new banner image path for the game
# @param colorBG1 [String] the new background color for the game
# @param colorBG2 [String] the new background color for the game
# @param colorBG3 [String] the new background color for the game
# @param colorText [String] the new text color for the game
# @param colorLink [String] the new link color for the game
def update_game(id, title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE games SET title=?, tagline=?, iframePath=?, fullDescription=?, visible=?, thumbnailImage=?, bgImage=?, bannerImage=?, colorBG1=?, colorBG2=?, colorBG3=?, colorText=?, colorLink=? WHERE id=?", title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink, id)
end

# Creates a new comment record in the database
#
# @param userId [Integer] the ID of the user who posted the comment
# @param gameId [Integer] the ID of the game the comment is about
# @param content [String] the content of the comment
def create_comment(userId, gameId, content)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO comments (userId, gameId, content, date) VALUES (?,?,?,?)", userId, gameId, content, 0)
end

# Creates a new user record in the database
#
# @param username [String] the username for the new user
# @param passwordDigest [String] the hashed password for the new user
# @param profileImage [String] the path to the user's profile image
def create_user(username, passwordDigest, profileImage)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO users (username, passwordDigest, profileImage) VALUES (?,?,?)", username, passwordDigest, profileImage)
end

# Gets all the comments for a given game
#
# @param gameId [Integer] the ID of the game to retrieve comments for
def get_comments(gameId)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT comments.*, users.username, users.profileImage FROM comments INNER JOIN users ON comments.userId=users.id WHERE gameId = ?", gameId)
    return result
end

# Gets all the games associated with a given genre
#
# @param genreId [Integer] the ID of the genre to retrieve games for
def get_games_by_genre(genreId)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM games_genres_rel INNER JOIN games ON games_genres_rel.gameId = games.id WHERE genreId = ?", genreId)
    return result
end

# Records a login attempt in the database
#
# @param user [String] the username of the user attempting to log in
def login_attempt(user)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO login_attemps (username, time) VALUES (?,?)", user, Time.now.to_i)
    result = db.execute("SELECT * FROM login_attemps WHERE username = ?", user)
    return result
end

########################################################

# Encrypts a given password using BCrypt
#
# @param password [String] the password to be encrypted
def digest_password(password)
    return BCrypt::Password.create(password)
end

# Compares two digested passwords using BCrypt
# 
# @param [String] pass1, the first password string
# @param [String] pass2, the second password string to compare with pass1
def compare_digests(pass1, pass2)
    return BCrypt::Password.new(pass1) == pass2
end
