
def connect_to_db(database)
    db = SQLite3::Database.new(database)
    db.results_as_hash = true
    return db
end

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

def delete_id(table, id)
    db = connect_to_db("db/database.db")
    db.execute("DELETE FROM #{table} WHERE id = ?", id)
end


##########################################################

def create_game()
    db = connect_to_db("db/database.db")
    db.execute("INSERT INTO games (title, tagline, thumbnailImage, visible) VALUES (?,?,?,?)", "Game Title", "Game Description", "img/thumbnails/thumb-Blinded.jpg", 0)
end

def update_game(id, title, desc, imgPath, visible)
    db = connect_to_db("db/database.db")
    db.execute("UPDATE games SET title=?, tagline=?, thumbnailImage=?, visible=? WHERE id=?", title, desc, imgPath, visible, id)
end