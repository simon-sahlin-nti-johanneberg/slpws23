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


# Display Landing Page
#
get('/')  do
  slim(:index)
end 

# Display Licensing Page
#
get('/licensing') do
  slim(:"general/licensing")
end

# Display About Page
#
get('/about') do
  slim(:"general/about")
end

# -------------------------------------------------------------------------- #
#                                 Game Routes                                #
# -------------------------------------------------------------------------- #

# Displays all games based based on genre parameter
#
# @param [Integer] genre, The id of the genre selected by user, set to 0 to show all games
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

# Creates a new empty game and redirects to '/games'
# 
get('/games/create') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  create_game()
  redirect('/games')
end

# Displays a single Game and its comments
#
# @param [Integer] :id, the ID of the game
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

# Displays a edit game form
#
# @param [Integer] :id, the ID of the game
get('/games/:id/edit') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/')
  end

  id = params[:id].to_i
  result = get_all_from_id('games', id)
  slim(:"games/edit", locals:{result:result})
end

# Updates a game with provided parameters and redirects to '/games'
#
# @param [Integer] :id, the ID of the game
# @param [String] :title, the title of the game
# @param [String] :tagline, the tagline of the game
# @param [String] :iframePath, the path of the iframe containing the game
# @param [String] :fullDescription, the full description of the game
# @param [Integer] :visible, determines if the game is visible to non-admin users or not
# @param [String] :thumbnailImage, the path of the thumbnail image of the game
# @param [String] :bgImage, the path of the background image of the game
# @param [String] :bannerImage, the path of the banner image of the game
# @param [String] :colorBG1, the primary background color of the game
# @param [String] :colorBG2, the secondary background color of the game
# @param [String] :colorBG3, the tertiary background color of the game
# @param [String] :colorText, the text color of the game
# @param [String] :colorLink, the link color of the game
post('/games/:id/update') do
  #Authorization
  if (!IsAdmin(session[:userId]))
    redirect('/games')
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

# Deletes a game and redirects to '/games'
#
# @param [Integer] :id, the ID of the game to be deleted
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

# Creates a new comment for a game and redirects to the game's page
#
# @param [Integer] :id, the ID of the game
# @param [Integer] :userId, the ID of the user who posted the comment
# @param [String] :content, the content of the comment
post('/games/:id/comments/create') do
  userId = params[:userId].to_i
  gameId = params[:id].to_i
  content = params[:content]

  create_comment(userId, gameId, content)
  redirect "/games/#{gameId}"
end

# Deletes a comment for a game and redirects to the game's page
#
# @param [Integer] :id, the ID of the comment to be deleted
# @param [Integer] :gameId, the ID of the game where the comment was posted
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

# Displays an edit comment form
#
# @param [Integer] :id, the ID of the comment to be edited
# @param [Integer] :gameId, the ID of the game where the comment was posted
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

# Updates a comment for a game and redirects to the game's page
#
# @param [Integer] :id, the ID of the comment to be updated
# @param [Integer] :gameId, the ID of the game where the comment was posted
# @param [String] :content, the updated content of the comment
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

# Displays the user registration form
#
get('/user/new') do
  slim(:"user/new")
end

# Creates a new user account and redirects to the login page if successful, otherwise redirects back to the register page with an error message
#
# @param [String] :username, the desired username for the new account
# @param [String] :password1, the desired password for the new account
# @param [String] :password2, confirmation of the desired password for the new account
# @param [String] :profileImage, the URL of the profile image for the new account
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


  passDigest = digest_password(pass1)
  create_user(username, passDigest, image)
  p "Registered successfully!"
  flash[:notice] = "Registered successfully!"

  redirect('/user/login')
end

# Displays the user login form
#
get('/user/login') do
  slim(:"user/login")
end

# Processes user login and redirects to home page if successful, otherwise redirects back to the login page with an error message
#
# @param [String] :username, the username of the account attempting to log in
# @param [String] :password, the password of the account attempting to log in
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

# Displays the user edit form
#
# @param [Integer] :id, the ID of the user account being edited
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

# Updates the user account and redirects to the edit page
#
# @param [Integer] :id, the ID of the user account being edited
# @param [String] :username, the new username for the account
# @param [String] :password1, the current password for the account
# @param [String] :password2, the new password for the account
# @param [String] :password3, confirmation of the new password for the account
# @param [String] :profileImage, the new URL for the profile image of the account
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
      passDigest = digest_password(newPassword)
      update_value("users", "passwordDigest", passDigest, userId)
    end
  end

  if newImage != user["profileImage"] 
    update_value("users", "profileImage", newImage, userId)
  end

  redirect("/user/#{userId}/edit")
end

# Logs the user out and redirects to the home page
#
post('/user/logout') do
  session.destroy
  redirect('/')
end

# -------------------------------------------------------------------------- #
#                                  Functions                                 #
# -------------------------------------------------------------------------- #

# Validates a username string and returns an error message if invalid
#
# @param [String] username, the username to be validated
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

# Validates a password string and returns an error message if invalid
#
# @param [String] pass1, the first password string
# @param [String] pass2, the second password string to compare with pass1
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

# Authenticates a password for a given user account and returns an error message if invalid
#
# @param [Hash] user, the user account to authenticate against
# @param [String] password, the password to authenticate with
def AuthenticatePassword(user, password)
  #Authentication
  if user != nil && compare_digests(user['passwordDigest'], password)
    p "Logged in successfully! #{user["id"]}"
    return nil
  end

  p "LOGIN FAILED, Username or password was incorrect"
  return "Login failed, Username or password was incorrect"
end


# A helper function to check if a given user is an admin
helpers do
  def IsAdmin(userId)
    user = get_all_from_id("users", userId)
    if user == nil
      return false
    end
    return user["isAdmin"] == 1
  end
end

# A fucntion that runs before each route, if the user is logged in, it sets the @userId, @username, and @profileImage variables for each view
before do
  if (session[:userId] != nil)
    userData = get_all_from_id("users", session[:userId])
    @userId = session[:userId]
    @username = userData["username"]
    @profileImage = userData["profileImage"]
  end
end