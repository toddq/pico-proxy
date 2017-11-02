require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'awesome_print'
require 'picobrew/api'

configure do
    enable :cross_origin
    if settings.environment == :development
        puts "DEVELOPMENT"
        enable :sessions
        set :session_secret, "asdfjas dfl; as;dfhaskj fhlkashdfljahsd"
    elsif settings.environment == :production
        puts "PRODUCTION"
        puts "Enabling Rack session pools"
        use Rack::Session::Pool
    end
end

before  do
    unless request.path_info == '/login' || request.path_info == '/logout'
        if session[:picobrew].nil?
            session[:route] = request.path_info
            redirect '/login'
        end
    end
end

get '/' do
    erb :index, :locals => { :whats_picobrewing => has_whats_picobrewing }
end

get '/login' do
    erb :login, :locals => { :error => nil, :user => nil, :password => nil }
end

post '/login' do
    if !params['user'].empty? && !params['password'].empty?
        session[:user] = params['user']
        log "Attempting to login #{session[:user]}"
        begin
            session[:picobrew] = Picobrew::Api.new(params['user'], params['password'])
            puts "Login success - #{session[:user]}"
            redirect(session[:route] || '/')
        rescue Exception => e
            puts "Login failure - #{session[:user]} - #{e}"
        end
    end
    erb :login, :locals => { :error => 'Login error', :user => params['user'], :password => params['password'] }
end

get '/logout' do
    session.clear()
    redirect '/login', :locals => { :error => "You have been logged out", :user => nil, :password => nil }
end

get '/api/active_session' do
    format session[:picobrew].get_active_session()
end

get '/api/check_active/:id?' do |session_id|
    format session[:picobrew].check_active(session_id)
end

get '/recipes' do
    recipes = session[:picobrew].get_all_recipes()
    recipes.sort_by! { |recipe| recipe['Name'] }
    erb :recipes, :locals => { :recipes => recipes }
end

get '/api/recipes' do
    format session[:picobrew].get_all_recipes, params[:format]
end

get '/api/recipes/sync' do
    format session[:picobrew].get_recipe_control_programs()
end

get '/recipe/:id/recipe' do |recipe_id|
    recipe = session[:picobrew].get_recipe(recipe_id)
    erb :recipe, :locals => { :recipe_id => recipe_id, :recipe => recipe }
end

get '/api/recipe/:id/recipe' do |recipe_id|
    format session[:picobrew].get_recipe(recipe_id), params[:format]
end

get '/recipe/:id/control' do |recipe_id|
    control_program = session[:picobrew].get_recipe_control_program(recipe_id)
    erb :control_program, :locals => { :recipe_id => recipe_id, :control_program => control_program }
end

get '/api/recipe/:id/control' do |recipe_id|
    format session[:picobrew].get_recipe_control_program(recipe_id), params[:format]
end

get '/recipe/:id/sessions' do |recipe_id|
    sessions = session[:picobrew].get_sessions_for_recipe(recipe_id)
    erb :recipe_sessions, :locals => { :recipe_id => recipe_id, :sessions => sessions }
end

get '/api/recipe/:id/sessions' do |recipe_id|
    format session[:picobrew].get_sessions_for_recipe(recipe_id), params[:format]
end

get '/recipe/:id' do |recipe_id|
    recipe = session[:picobrew].get_recipe(recipe_id)
    control_program = session[:picobrew].get_recipe_control_program(recipe_id)
    sessions = session[:picobrew].get_sessions_for_recipe(recipe_id)
    erb :full_recipe, :locals => { :recipe_id => recipe_id, :recipe => recipe, :control_program => control_program, :sessions => sessions }
end

get '/sessions' do
    sessions = session[:picobrew].get_all_sessions()
    erb :sessions, :locals => { :sessions => sessions, :whats_picobrewing => has_whats_picobrewing }
end

get '/session/:id/log' do |session_id|
    log = session[:picobrew].get_session_log(session_id)
    erb :session_log, :locals => { :session_id => session_id, :log => log }
end

get '/api/session/:id/log' do |session_id|
    format session[:picobrew].get_session_log(session_id), params[:format]
end

get '/session/:id/notes' do |session_id|
    notes = session[:picobrew].get_session_notes(session_id)
    erb :session_notes, :locals => { :session_id => session_id, :notes => notes }
end

get '/api/session/:id/notes' do |session_id|
    format session[:picobrew].get_session_notes(session_id), params[:format]
end

get '/api/session/:id/recipe' do |session_id|
    format( {'recipe_id' => session[:picobrew].get_recipe_id_for_session_id(session_id)}, params[:format] )
end

get '/session/:id' do |session_id|
    log = session[:picobrew].get_session_log(session_id)
    notes = session[:picobrew].get_session_notes(session_id)
    erb :full_session, :locals => { :session_id => session_id, :notes => notes, :log => log }
end

get '/api/sessions' do
    format session[:picobrew].get_all_sessions(), params[:format]
end

get '/whats-picobrewing' do
    redirect '/whats-picobrewing/index.html' if has_whats_picobrewing
    pass
end

def has_whats_picobrewing()
    File.exists? "public/whats-picobrewing/index.html"
end

def format(response, type=:json)
    if type == :html || type == 'pretty'
        begin
            "<pre>#{JSON.pretty_generate(response)}</pre>"
        rescue
            ap response
            "Error: check the log"
        end
    else
        content_type :json
        response.to_json
    end
end

def log(msg)
    puts msg
end
