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

get('/games/playgame/:id') do
  id = params[:id].to_i
  result = get_all_from_id('games', id)
  screenshots = get_all_from_where('screenshots','gameId', id)
  comments = get_all_from_where('comments','gameId', id)
  #Inner join här sen för att få namn på users från kommentarer
  slim(:gamepage, locals:{result:result, screenshots:screenshots, comments:comments})
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
  tagline = params[:tagline]
  iframePath = params[:iframePath]
  fullDescription = params[:fullDescription]
  visible = !params[:visible].nil? ? 1 : 0
  thumbnailImage = params[:thumbnailImage]
  bgImage = params[:bgImage]
  bannerImage = params[:bannerImage]
  colorBG1 = params[:colorBG1]
  colorBG2 = params[:colorBG2]
  colorBG3 = params[:colorBG3]
  colorText = params[:colorText]
  colorLink = params[:colorLink]

  update_game(id, title, tagline, iframePath, fullDescription, visible, thumbnailImage, bgImage, bannerImage, colorBG1, colorBG2, colorBG3, colorText, colorLink)
  redirect('/games')
end

post('/games/deletegame') do
  id = params[:id]
  delete_id('games', id)
  redirect('/games')
end

post('/games/createcomment') do
  userId = params[:userId].to_i
  gameId = params[:gameId].to_i
  content = params[:content]

  create_comment(userId, gameId, content)
  redirect "/games/playgame/#{gameId}"
end

post('/games/deletecomment') do
  id = params[:id]
  gameId = params[:gameId]
  delete_id('comments', id)
  redirect("/games/playgame/#{gameId}")
end

get('/games/editcomment') do
  id = params[:id]
  comment = get_all_from_id('comments', id)
  gameId = params[:gameId]
  slim(:editcomment, locals:{comment:comment, gameId:gameId})
end

post('/games/editcomment') do
  id = params[:id].to_i
  gameId = params[:gameId].to_i
  content = params[:content]
  update_value('comments', 'content', content, id)
  redirect("/games/playgame/#{gameId}")
end



get('/debug') do
  slim(:debug)
end

get('/debug/debug') do
  slim(:debug)
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