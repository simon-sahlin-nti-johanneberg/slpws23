require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'



get('/')  do
  slim(:index)
end 

get('/games')  do
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM games")
  slim(:games, locals:{games:result})
end 

get('/licensing') do
  slim(:licensing)
end

get('/about') do
  slim(:about)
end

get('/games/gamebruh') do
  slim(:playgame)
end

get('/games/gamebruhs') do
  slim(:gamepage)
end

get('/games/addgame') do
  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO games (name, description, imagePath, showInList) VALUES (?,?,?,?)", "Game Title", "Game Description", "img/thumbnails/thumb-Blinded.jpg", 0)
  redirect('/games')
end

get('/games/editgame/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/database.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM games WHERE id = ?", id).first
  slim(:addgame, locals:{result:result})
end

=begin
post('/games/addgame') do
  title = params[:title]
  desc = params[:description]
  imgPath = params[:imagePath]
  show = !params[:display].nil? ? 1 : 0

  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO games (name, description, imagePath, showInList) VALUES (?,?,?,?)", title, desc, imgPath, show)
  redirect('/games')
=end

post('/games/editgame') do
  id = params[:id]
  title = params[:title]
  desc = params[:description]
  imgPath = params[:imagePath]
  show = !params[:display].nil? ? 1 : 0

  db = SQLite3::Database.new("db/database.db")
  db.execute("UPDATE games SET name=?, description=?, imagePath=?, showInList=? WHERE id=?", title, desc, imgPath, show, id)
  redirect('/games')
end

post('/games/deletegame') do
  id = params[:id]
  db = SQLite3::Database.new("db/database.db")
  db.execute("DELETE FROM games WHERE id = ?", id)
  redirect('/games')
end