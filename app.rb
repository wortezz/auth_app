require 'sinatra'
require 'json'
require 'sinatra/cookies'

enable :sessions

# --- Docker-friendly settings ---
set :bind, '0.0.0.0'
set :port, 4567

# Використовуємо layout для всіх сторінок
set :erb, layout: :'layout'

USERS_FILE = "users.json"

# --- Допоміжні методи ---
def load_users
  if File.exist?(USERS_FILE) && File.read(USERS_FILE).strip != ""
    JSON.parse(File.read(USERS_FILE))
  else
    []
  end
end

def save_users(users)
  File.write(USERS_FILE, JSON.pretty_generate(users))
end

def current_user
  session[:user]
end

# --- Головна сторінка ---
get "/" do
  if current_user
    redirect "/welcome"
  else
    redirect "/login"
  end
end

# --- Реєстрація ---
get "/register" do
  erb :register
end

post "/register" do
  users = load_users

  if users.any? { |u| u["email"] == params[:email] }
    return "Користувач з такою поштою вже існує!"
  end

  new_user = {
    "name" => params[:name],
    "email" => params[:email],
    "password" => params[:password] # у реальних проєктах хешують!
  }

  users << new_user
  save_users(users)

  session[:user] = new_user
  redirect "/welcome"
end

# --- Логін ---
get "/login" do
  erb :login
end

post "/login" do
  users = load_users
  user = users.find { |u| u["email"] == params[:email] && u["password"] == params[:password] }

  if user
    session[:user] = user
    redirect "/welcome"
  else
    "Невірний логін або пароль!"
  end
end

# --- Вихід ---
get "/logout" do
  session.clear
  redirect "/login"
end

# --- Привітання ---
get "/welcome" do
  redirect "/login" unless current_user
  @name = current_user["name"]
  erb :welcome
end

# --- Показати всіх користувачів ---
get "/users" do
  redirect "/login" unless current_user
  @users = load_users
  erb :users
end

