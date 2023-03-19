require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require_relative './model.rb'
require 'sinatra/flash'
require 'BCrypt'

enable :sessions

before do
  if (session[:userId] != nil)
    userData = get_all_from_id("users", session[:userId])
    @userId = session[:userId]
    @username = userData["username"]
    @profileImage = userData["profileImage"]
  end
end

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
  comments = get_comments(id)
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

get('/user/register') do
  slim(:register)
end

post('/user/register') do
  username = params[:username]
  pass1 = params[:password1]
  pass2 = params[:password2]
  image = params[:profileImage]

  flash[:notice] = "Test message"

  #Validation
  usernameValidation = ValidateUsername(username)
  if usernameValidation != nil
    p usernameValidation
    flash[:notice] = usernameValidation
    redirect('/user/register')
  end

  passwordValidation = ValidatePassword(pass1, pass2)
  if passwordValidation != nil
    p passwordValidation
    flash[:notice] = passwordValidation
    redirect('/user/register')
  end


  passDigest = BCrypt::Password.create(pass1)
  create_user(username, passDigest, image)
  p "Registered successfully!"
  flash[:notice] = "Registered successfully!"

  redirect('/user/login')
end

get('/user/login') do
  slim(:login)
end

post('/user/login') do
  username = params[:username]
  password = params[:password]

  user = get_all_from_where("users", "username", username).first

  #Authentication
  passwordAuthentication = AuthenticatePassword(user, password)
  if passwordAuthentication != nil
    p passwordAuthentication
    flash[:notice] = passwordAuthentication
    redirect('/user/login')
  end

  p "Logged in successfully! #{user["id"]}"
  session[:userId] = user["id"]
  redirect('/')
end

get('/user/edit') do
  user = get_all_from_id("users", session[:userId])
  slim(:userprofile, locals:{user:user})
end

post('/user/edit') do
  userId = params[:userId].to_i
  newUsername = params[:username]
  oldPassword = params[:password1]
  newPassword = params[:password2]
  newPasswordC = params[:password3]
  newImage = params[:profileImage]

  user = get_all_from_id("users", userId)
  p "va"
  p user
  p userId

  flash[:notice] = "Changes made successfully"

  passwordAuthentication = AuthenticatePassword(user, oldPassword)
  if passwordAuthentication != nil
    p passwordAuthentication
    flash[:notice] = "Incorrect password"
    redirect('/user/edit')
  end

  #Validation
  if newUsername != user["username"]
    usernameValidation = ValidateUsername(newUsername)
    if usernameValidation != nil
      p usernameValidation
      flash[:notice] = "\n #{usernameValidation}"
    else
      update_value("users", "username", newUsername, userId)
    end
  end

  if newPassword.length > 0 && newPasswordC.length > 0
    passwordValidation = ValidatePassword(newPassword, newPasswordC)
    if passwordValidation != nil
      p passwordValidation
      flash[:notice] = "\n #{passwordValidation}"
    else
      passDigest = BCrypt::Password.create(newPassword)
      update_value("users", "passwordDigest", passDigest, userId)
    end
  end

  if newImage != user["profileImage"]
    update_value("users", "profileImage", newImage, userId)
  end

  redirect('/user/edit')
end

post('/user/logout') do
  session.destroy
  redirect('/')
end


def ValidateUsername(username)
  if get_all_from_where("users", "username", username).length > 0
    p "Error: Username taken"
    return "Error: Username taken"
  end

  if username.length > 20
    p "Error: Username too long"
    return "Error: Username too long"
  end

  if username.length < 5
    p "Error: Username too short"
    return "Error: Username too short"
  end

  return nil
end

def ValidatePassword(pass1, pass2)
  if pass1 != pass2
    p "Error: Password do not match!"
    return "Error: Password do not match!"
  end

  if pass1.length < 5
    p "Error: Password too short"
    return "Error: Password too short"
  end

  return nil
end

def AuthenticatePassword(user, password)
  #Authentication
  if user != nil && BCrypt::Password.new(user['passwordDigest']) == password
    p "Logged in successfully! #{user["id"]}"
    return nil
  end

  p "LOGIN FAILED, Username or password was incorrect"
  return "Login failed, Username or password was incorrect"
end


get('/debug') do
  slim(:debug)
end

get('/debug/debug') do
  slim(:debug)
end

helpers do
  def IsAdmin(userId)
    user = get_all_from_id("users", userId)
    if user == nil
      return false
    end
    return user["isAdmin"] == 1
  end
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