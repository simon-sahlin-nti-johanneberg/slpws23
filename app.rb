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

get('/games/addgame') do
  slim(:addgame)
end

post('/games/addgame') do
  title = params[:title]
  desc = params[:description]
  imgPath = params[:imagePath]
  show = !params[:display].nil? ? 1 : 0
  p "hello #{show}"
  db = SQLite3::Database.new("db/database.db")
  db.execute("INSERT INTO games (name, description, imagePath, showInList) VALUES (?,?,?,?)", title, desc, imgPath, show)
  redirect('/games/addgame')
end