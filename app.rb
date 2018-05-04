require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"
require 'uri'

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
  if session[:user_id]
    # p session[:user_id]
    @user = User.find(session[:user_id])
    erb :signed_in_homepage
  else
    erb :signed_out_homepage
  end
end

# displays sign in form
get "/sign-in" do
  erb :sign_in
end

# responds to sign in form
post "/sign-in" do
  @user = User.find_by(username: params[:username])

  # checks to see if the user exists
  #   and also if the user password matches the password in the db
  if @user && @user.password == params[:password]
    # this line signs a user in
    session[:user_id] = @user.id

    # lets the user know that something is wrong
    flash[:info] = "You have been signed in"

    # redirects to the home page
    redirect "/"
  else
    # lets the user know that something is wrong
    flash[:warning] = "Your username or password is incorrect"

    # if user does not exist or password does not match then
    #   redirect the user to the sign in page
    redirect "/sign-in"
  end
end

# displays signup form
#   with fields for relevant user information like:
#   username, password
get "/sign-up" do
  erb :sign_up
end

post "/sign-up" do
  @user = User.create(
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    birthday: params[:birthday],
    username: params[:username],
    password: params[:password],
  )
  
  Profile.create(
    display_name: params[:display_name],
    user_id: @user.id
  )

  # this line does the signing in
  session[:user_id] = @user.id

  # lets the user know they have signed up
  flash[:info] = "Thank you for signing up"

  # assuming this page exists
  redirect "/"
end

post "/make-post" do
  @user = User.find(session[:user_id]) 
  @post = Post.create(
    title: params[:title],
    content: params[:content],
    image: params[:image],
    profile_id: @user.id
  )

  if !params[:content].scan(/#[(\w|\d)]{1,50}/).empty?
    params[:content].scan(/#[(\w|\d)]{1,50}/).each do |tag|
      @tag = Tag.create(
        tag: tag
      )
      PostTag.create(
        post_id: @post.id,
        tag_id: @tag.id
      )
    end
  end 



  # @user = session[:user_id]
  #   @profile = Profile.find(session[:user_id])
  #   @post = Post.last
  # p @post
  # # this line does the signing in
  # session[:user_id] = @user.id

  # # lets the user know they have signed up
  # flash[:info] = "Thank you for signing up"

  # assuming this page exists
  redirect '/posts'
end

get '/posts' do
  @user = User.find(session[:user_id]) 
  # @tags = User.find(session[:user_id]).profile.posts.last.post_tags.each{|t| t.tag.tag}

  # tags = User.find(1).profile.posts.last.post_tags.each{|t| p t.tag.tag}
  erb :posts
end

# when hitting this get path via a link
#   it would reset the session user_id and redirect
#   back to the homepage
get "/sign-out" do
  # this is the line that signs a user out
  session[:user_id] = nil

  # lets the user know they have signed out
  flash[:info] = "You have been signed out"
  
  redirect "/"
end

# get "/profile/:id" do
#   params[:id]

#   @user = User.find(params[:id])

#   erb :profile
# end

get "/profile/:display_name" do
  # params[:id]

  # puts session[:user_id]

  @profile = Profile.find_by(display_name: params[:display_name] )

  erb :profile
end

get "/users" do 
  @users = User.all

  erb :users
end

post "/search" do
  # params[:search]
  # @profile = Profile.find_by(display_name: params[:search] )
  # p @profile
  if Profile.all.exists?(:display_name => params[:search] )
    @profile = Profile.find_by(display_name: params[:search] )
    redirect "/profile/#{@profile.display_name}"
  elsif Tag.all.exists?(:tag => params[:search])
    @tags = Tag.find_by(tag: params[:search]).posts.all
    redirect URI.escape("/results/?search=#{params[:search]}")
  else
    redirect "/"
  end

end


get URI.unescape("/results/") do
  p params
  p "hello"
  p "hello again"
  
  @tags = []
  Tag.where(tag: params[:search]).reverse.each{|t| t.posts.each{|p|  @tags.push(p)}}
  # @tags = 

  # @tags = Tag.where(tag: params[:search]).each{|t| t.posts.reverse}
  # @tags = Tag.where(tag: params[:search]).each{|t| t.posts.reverse.each{|post| post}}
  # Tag.where(tag: '#hashtags' ).each{|t| t.posts.reverse.each{|p| p p.content}}
  erb :results
end


# binding.pry