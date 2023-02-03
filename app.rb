require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require_relative './model.rb'



get('/')  do
  slim(:index)
end 

get('/games')  do
  result = get_all('games')
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
  create_game()
  redirect('/games')
end

get('/games/editgame/:id') do
  id = params[:id].to_i
  result = get_all_from_id('games', id)
  slim(:addgame, locals:{result:result})
end

post('/games/editgame') do
  id = params[:id]
  title = params[:title]
  desc = params[:description]
  imgPath = params[:imagePath]
  show = !params[:display].nil? ? 1 : 0

  update_game(id, title, desc, imgPath, show)
  redirect('/games')
end

post('/games/deletegame') do
  id = params[:id]
  delete_id('games', id)
  redirect('/games')
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