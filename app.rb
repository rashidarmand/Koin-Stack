require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"
require 'uri'
require 'net/http'

enable :sessions
set :sessions, true

# set :database, "sqlite3:stonr.db"

# this will ensure this will only be used locally
configure :development do
  set :database, "sqlite3:stonr.db"
end
# this will ensure this will only be used on production
configure :production do
  # this environment variable is auto generated/set by heroku
  #   check Settings > Reveal Config Vars on your heroku app admin panel
  set :database, ENV["DATABASE_URL"]
end

require 'pry'

get "/" do
  # If the user is signed in, show them the signed in homepage otherwise show them the signed out homepage
  if session[:user_id]
    @user = User.find(session[:user_id])
    erb :signed_in_homepage
  else
    erb :signed_out_homepage
  end
end


get "/sign-in" do
  # Show interface for signing in
  erb :sign_in
end


post "/sign-in" do
  # Sign user in if their username/password is correct or tell them that they entered something incorrectly
  @user = User.find_by(username: params[:username])
  if @user && @user.password == params[:password]
    session[:user_id] = @user.id
    flash[:info] = "You have been signed in"
    redirect "/"
  else
    flash[:warning] = "Your username or password is incorrect"
    redirect "/sign-in"
  end
end


get "/sign-up" do
  # Show interface for signing up for an account
  erb :sign_up
end


post "/sign-up" do
  # Create a user and profile for the new user, log them in, and redirect them to the homepage
  @user = User.create(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    birthday: params[:birthday],
    username: params[:username],
    password: params[:password]
  )
  Profile.create(
    display_name: params[:display_name],
    user_id: @user.id
  )
  session[:user_id] = @user.id
  flash[:info] = "Thank you for signing up"
  redirect "/"
end


post "/make-post" do
  # Allow user to make a post and redirect them back to their profile
  @user = User.find(session[:user_id]) 
  @post = Post.create(
    title: params[:title],
    content: params[:content],
    image: params[:image],
    profile_id: @user.id
  )
  # Look for hashtags in the title & content fields and make tags/post_tags for them if they exist
  if !params[:title].scan(/#\w+{2,50}|@\w+{2,50}/).empty?
    params[:title].scan(/#\w+{1,50}|@\w+{1,50}/).each do |tag|
      @tag = Tag.create(
        tag: tag
      )
      PostTag.create(
        post_id: @post.id,
        tag_id: @tag.id
      )
    end
  end
  if !params[:content].scan(/#\w+{2,50}|@\w+{2,50}/).empty?
    params[:content].scan(/#\w+{2,50}|@\w+{2,50}/).each do |tag|
      @tag = Tag.create(
        tag: tag
      )
      PostTag.create(
        post_id: @post.id,
        tag_id: @tag.id
      )
    end
  end 
  redirect "/profile/#{@user.profile.display_name}"
end


post "/deletePostf/:id" do
  # Allow user to delete an indvidual post and redirect them back to the feed
  Post.destroy(params[:id])
  flash[:info] = "Post Deleted"
  redirect "/feed"
end


post "/deletePostp/:id" do
  # Allow user to delete an indvidual post and redirect them back to their profile
  user = User.find(session[:user_id])
  Post.destroy(params[:id])
  flash[:info] = "Post Deleted"
  redirect "/profile/#{user.profile.display_name}"
end


get "/edit_post/:id" do
  # If you're logged in and it's your post, show interface to edit the post. Otherwise give feedback and redirect to homepage
  if session[:user_id] && Post.find(params[:id]).profile.user.id == session[:user_id]
    @post = Post.find(params[:id])
    erb :edit_post
  elsif session[:user_id] && Post.find(params[:id]).profile.user.id != session[:user_id]
    flash[:warning] = "Hmmm...that's not your post! 👀 "
    redirect "/"
  else
    flash[:warning] = "Please Sign In"
    redirect "/"
  end
end


post "/edit_post/:id" do
  # Allow user to edit an indvidual post
  user = User.find(session[:user_id])
  this_post = Post.find_by(id: params[:id])
  @post = this_post.update(
    title: params[:title],
    content: params[:content],
    image: params[:image],
    profile_id: user.id
  )
  # Delete current tags and make new ones if they exist in the title or content
  this_post.tags.delete_all
  this_post.post_tags.delete_all
  params[:title].scan(/#\w+{2,50}|@\w+{2,50}/).uniq.each do |tag|
    @tag = Tag.create(
      tag: tag
    )
    PostTag.create(
      post_id: this_post.id,
      tag_id: @tag.id
    )
  end
  params[:content].scan(/#\w+{2,50}|@\w+{2,50}/).uniq.each do |tag|
    @tag = Tag.create(
      tag: tag
    )
    PostTag.create(
      post_id: this_post.id,
      tag_id: @tag.id
    )
  end
  # Let user know the post was updated successfully and take them back to their profile page
  flash[:info] = "Post Updated"
  redirect "/profile/#{user.profile.display_name}"
end


get "/post/:id" do
  # Show one particular post
  @post = Post.find(params[:id])
  erb :post
end


get "/sign-out" do
  # End the session, let the user know they successfully signed out and redirect them back to the homepage
  session[:user_id] = nil
  flash[:info] = "You have been signed out"
  redirect "/"
end


get "/profile/:display_name" do
  # Show the profile of the specified user
  @profile = Profile.find_by(display_name: params[:display_name])
  erb :profile
end


get "/feed" do
  # Show all posts in chronological order
  @posts = Post.all.reverse
  erb :feed
end


get "/users" do 
  # Show every user except the one currently logged in
  @users = User.where.not(id: session[:user_id])
  erb :users
end


post "/search" do
  # Pass search parameter as a query string to the results rout while making sure to escape any special characters
  redirect URI.escape("/results/?search=#{params[:search]}")
end

# unescape any special characters that were passed in
get URI.unescape("/results/") do
  # When searching for a profile, disregard the '@' symbol so it works with or without it
  if params[:search][0] == '@'
    @profiles = Profile.where("display_name LIKE ?", "#{params[:search][1..-1]}%")
  else  
    @profiles = Profile.where("display_name LIKE ?", "#{params[:search]}%")
  end
  # Look for a direct match for the hashtag
  @tags = []
  Tag.where(tag: params[:search]).reverse.each{|t| t.posts.each{|p|  @tags.push(p)}}
  # If no direct match found, try and find similar matches
  if @tags.empty?
    @close_match = "*No direct matches found* <br><br> Similar Matches to '#{params[:search]}':"
    Tag.where("tag LIKE ?", "#{params[:search]}%").reverse.each{|t| t.posts.each{|p|  @tags.push(p)}}
  end
  # Show results of the search
  erb :results
end


get "/settings" do
  # If user is logged in allow them to proceed to their settings else redirect them to the homepage.
  if session[:user_id]
    erb :settings
  else
    redirect "/"
  end
end


post "/deleteAccount" do
  # If the logged in user wants to delete their account, have them enter their current username/password to confirm they are sure.
  # If the username/password incorrect redirect them back to the same page and let them know what they did wrong
  user = User.find(session[:user_id]) 
  if params[:username] == user.username && params[:password] == user.password
    user.profile.posts.each{|p| Post.destroy(p.id)}
    Profile.destroy(session[:user_id])
    User.destroy(session[:user_id])
    session[:user_id] = nil
    flash[:info] = "Account Deleted"
    redirect "/"
  else
    flash[:warning] = "Your username or password is incorrect"
    redirect "/settings"
  end
end


post "/changePassword" do
  # If logged in user wants to change their password have them enter current password once and new password twice
  # If one of the fields has a mistake let them know what they did wrong
  user = User.find(session[:user_id]) 
  if params[:password] == user.password && params[:new_password] == params[:new_password2]
    user.update(password: params[:new_password])
    flash[:info] = "Password Updated"
    redirect "/settings"
  elsif params[:password] != user.password
    flash[:warning] = "Password is incorrect"
    redirect "/settings"
  elsif params[:new_password] != params[:new_password2]
    flash[:warning] = "New passwords do not match"
    redirect "/settings"
  end
end


post "/changeDisplayName" do
  # If logged in user wants to change their display name have them enter the new one that they want it to be changed to.
  user = User.find(session[:user_id])
  user.profile.update(display_name: params[:display_name])
  flash[:info] = "Display Name Updated"
  redirect "/settings"
end






# binding.pry