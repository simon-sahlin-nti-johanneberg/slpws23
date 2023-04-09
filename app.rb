# -------------------------------------------------------------------------- #
#                                    Setup                                   #
# -------------------------------------------------------------------------- #
require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require_relative './model.rb'
require 'sinatra/flash'
require 'BCrypt'

enable :sessions

# -------------------------------------------------------------------------- #
#                               General Routes                               #
# -------------------------------------------------------------------------- #

get('/')  do
  slim(:index)
end 

get('/licensing') do
  slim(:"general/licensing")
end

get('/about') do
  slim(:"general/about")
end

# -------------------------------------------------------------------------- #
#                                 Game Routes                                #
# -------------------------------------------------------------------------- #

get('/games') do
  genre = params[:gameFilter].to_i
  if (genre != 0)
    result = get_games_by_genre(genre)
  else
    result = get_all("games")
  end
  genres = get_all("genres")
  slim(:"games/index", locals:{games:result, genres:genres, selectedGenre:genre})
end 

get('/games/create') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  create_game()
  redirect('/games')
end

get('/games/:id') do
  id = params[:id].to_i
  result = get_all_from_id('games', id)
  screenshots = get_all_from_where('screenshots','gameId', id)
  comments = get_comments(id)

  #Authorization
  if (result["visible"] == 0 && !IsAdmin(session[:userId]))
    redirect('/')
  end

  slim(:"games/show", locals:{result:result, screenshots:screenshots, comments:comments})
end

get('/games/:id/edit') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  id = params[:id].to_i
  result = get_all_from_id('games', id)
  slim(:"games/edit", locals:{result:result})
end

post('/games/:id/update') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  id = params[:id].to_i
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

post('/games/:id/delete') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  id = params[:id]
  delete_id('games', id)
  redirect('/games')
end

# -------------------------------------------------------------------------- #
#                               Comment Routes                               #
# -------------------------------------------------------------------------- #

post('/games/:id/comments/create') do
  userId = params[:userId].to_i
  gameId = params[:id].to_i
  content = params[:content]

  create_comment(userId, gameId, content)
  redirect "/games/#{gameId}"
end

post('/games/comments/:id/delete') do
  id = params[:id].to_i
  comment = get_all_from_id('comments', id)
  gameId = params[:gameId]

  #Authorization
  if (session[:userId] != comment["userId"] && !IsAdmin(session[:userId]))
    redirect('/')
  end

  delete_id('comments', id)
  redirect("/games/#{gameId}")
end

get('/games/comments/:id/edit') do
  id = params[:id].to_i
  comment = get_all_from_id('comments', id)
  gameId = params[:gameId]

  #Authorization
  if (session[:userId] != comment["userId"] && !IsAdmin(session[:userId]))
    redirect('/')
  end

  slim(:"comments/edit", locals:{comment:comment, gameId:gameId})
end

post('/games/comments/:id/update') do
  id = params[:id].to_i
  gameId = params[:gameId].to_i
  content = params[:content]
  comment = get_all_from_id('comments', id)

  #Authorization 
  if (session[:userId] != comment["userId"] && !IsAdmin(session[:userId]))
    redirect('/')
  end

  update_value('comments', 'content', content, id)
  redirect("/games/#{gameId}")
end

# -------------------------------------------------------------------------- #
#                                 User Routes                                #
# -------------------------------------------------------------------------- #

get('/user/new') do
  slim(:"user/new")
end

post('/user/create') do
  username = params[:username]
  pass1 = params[:password1]
  pass2 = params[:password2]
  image = params[:profileImage]

  #Validation
  usernameValidation = ValidateUsername(username)
  if usernameValidation != nil
    p usernameValidation
    flash[:notice] = usernameValidation
    redirect('/user/new')
  end

  passwordValidation = ValidatePassword(pass1, pass2)
  if passwordValidation != nil
    p passwordValidation
    flash[:notice] = passwordValidation
    redirect('/user/new')
  end


  passDigest = BCrypt::Password.create(pass1)
  create_user(username, passDigest, image)
  p "Registered successfully!"
  flash[:notice] = "Registered successfully!"

  redirect('/user/login')
end

get('/user/login') do
  slim(:"user/login")
end

post('/user/login') do
  username = params[:username]
  password = params[:password]

  login_attemps = login_attempt(username)
  if (login_attemps.length > 5 && Time.now.to_i - login_attemps.reverse[5]["time"] < 10)
    flash[:notice] = "Too many login attempts, wait for 10 seconds"
    redirect('/user/login')
  end

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

get('/user/:id/edit') do
  id = params[:id].to_i
  #Authorization 
  if (session[:userId] != id)
    redirect('/')
  end
  
  flash[:notice] = ""
  user = get_all_from_id("users", id)
  slim(:"user/edit", locals:{user:user})
end

post('/user/:id/update') do
  userId = params[:id].to_i

  #Authorization 
  if (session[:userId] != userId)
    redirect('/')
  end

  newUsername = params[:username]
  oldPassword = params[:password1]
  newPassword = params[:password2]
  newPasswordC = params[:password3]
  newImage = params[:profileImage]

  user = get_all_from_id("users", userId)

  flash[:notice] = "Changes made successfully"

  passwordAuthentication = AuthenticatePassword(user, oldPassword)
  if passwordAuthentication != nil
    p passwordAuthentication
    flash[:notice] = "Incorrect password"
    redirect("/user/#{userId}/edit")
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

  redirect("/user/#{userId}/edit")
end

post('/user/logout') do
  session.destroy
  redirect('/')
end

# -------------------------------------------------------------------------- #
#                                  Functions                                 #
# -------------------------------------------------------------------------- #

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



helpers do
  def IsAdmin(userId)
    user = get_all_from_id("users", userId)
    if user == nil
      return false
    end
    return user["isAdmin"] == 1
  end
end

before do
  if (session[:userId] != nil)
    userData = get_all_from_id("users", session[:userId])
    @userId = session[:userId]
    @username = userData["username"]
    @profileImage = userData["profileImage"]
  end
end