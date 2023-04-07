
def connect_to_db(database)
    db = SQLite3::Database.new(database)
    db.results_as_hash = true
    return db
end

#kan man lägga en before här?

########################################################

def get_all(table)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table}")
    return result
end

def get_all_from_id(table, id)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table} WHERE id = ?", id).first
    return result
end

def get_all_from_where(table, where, id)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM #{table} WHERE #{where} = ?", id)
    return result
end

def delete_id(table, id)
    db = connect_to_db("db/database.db")
    db.execute("DELETE FROM #{table} WHERE id = ?", id)
end

def update_value(table, name, value, id)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE #{table} SET #{name}=? WHERE id=?", value, id)
end

##########################################################

def create_game()
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO games (title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", "Game Title", "Tagline", "", "Game Description", 0, "img/thumbnails/thumb-Blinded.jpg", "", "", "#eeeeee", "#ffffff", "#e5e5e5", "#222222", "#fa5c5c")
end

def update_game(id, title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE games SET title=?, tagline=?, iframePath=?, fullDescription=?, visible=?, thumbnailImage=?, bgImage=?, bannerImage=?, colorBG1=?, colorBG2=?, colorBG3=?, colorText=?, colorLink=? WHERE id=?", title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink, id)
end

def create_comment(userId, gameId, content)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO comments (userId, gameId, content, date) VALUES (?,?,?,?)", userId, gameId, content, 0)
end

def create_user(username, passwordDigest, profileImage)
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO users (username, passwordDigest, profileImage) VALUES (?,?,?)", username, passwordDigest, profileImage)
end

def get_comments(gameId)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT comments.*, users.username, users.profileImage FROM comments INNER JOIN users ON comments.userId=users.id WHERE gameId = ?", gameId)
    return result
end

def get_games_by_genre(genreId)
    db = connect_to_db("db/database.db")
    result = db.execute("SELECT * FROM games_genres_rel INNER JOIN games ON games_genres_rel.gameId = games.id WHERE genreId = ?", genreId)
    return result
end