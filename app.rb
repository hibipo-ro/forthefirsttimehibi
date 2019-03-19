require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
require 'sinatra/cookies'

enable :sessions

def client
  @client ||= Mysql2::Client.new(
    :host => '127.0.0.1',
    :username => 'root',
    :password => '',
    :database => 'instagram'
  )
end

def my_info
  @my_info = client.xquery('select * from users where id = ?', session[:user_id]).map{ |i| i }.first
end

def is_follow(creater_id)
  @is_follow = client.xquery('select * from follows where from_user_id = ? && to_user_id = ?;', session[:user_id], creater_id).first 
end

def is_like(post_id)
  @is_like = client.xquery('select * from likes where user_id = ? && post_id = ?;',session[:user_id], post_id).first 
end

get '/' do
  redirect '/login' unless session[:user_id]
  erb :line, layout: :layout
end

get '/login' do
  erb :login, layout: :layout
end

post '/login' do
  res = client.xquery('select * from users where name = ? && password = ?;',params[:l_name],params[:l_pass]).first
  if res
    cookies[:msg] = '成功： ログインしました'
    session[:user_id] = res['id']
    cookies[:l_name] = nil
  else
    session[:user_id] = nil
    cookies[:l_name] = params['l_name']
    unless client.xquery('select id from users where name = ?', params[:l_name]).first
      cookies[:msg] = '失敗： そのNameのユーザーは存在しません'
    else
      cookies[:msg] = '失敗： パスワードが間違っています'
    end
    
  end
  redirect '/line'
end

get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  cookies[:s_name] = params['s_name']
  
  unless params[:s_pass] == params[:s_pass_re]
    cookies[:msg] = '失敗： パスワードが一致しません'
    redirect '/sign_up'
  end
  
  res = client.xquery('select name from users where name = ?;', params[:s_name]).first
  res1 = client.xquery('select password from users where password = ?;', params[:s_pass]).first
  
  if !res && !res1
    name = params[:s_name]
    password = params[:s_pass]
    @results = client.xquery(
        'INSERT INTO users(name,password, profile_image_url)
        VALUES (?, ?, ?)', name, password,'sample.jpg') 
    res2 = client.xquery('select * from users where name = ? && password = ?', params[:s_name], params[:s_pass]).first

    cookies[:msg] = '成功： ログインしました'
    session[:user_id] = res2['id']
    cookies[:s_name] = nil

    redirect '/line'
    
  elsif res1
    cookies[:msg] = '失敗: そのpasswordは使えません'
    redirect '/sign_up'  
  else
    cookies[:msg] = '失敗： そのnameは使用されています'
    redirect '/sign_up'
  end
  
  redirect '/login'
end

get '/logout' do
  session[:user_id] = nil  
  redirect '/login'
end

get '/top' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  @posts = client.xquery("SELECT * FROM posts where user_id = ? order by id desc", session[:user_id])
  @posts.each do |item|
    item['comment'] = client.xquery("select * from comments c join users u on c.user_id = u.id where post_id = ?", item['id']).to_a
    item['like_count'] = client.xquery("select count(*) from likes where post_id = ?", item['id']).first['count(*)']
    item['comment_count'] = client.xquery("select count(*) from comments where post_id = ?", item['id']).first['count(*)']
  end
  erb :top
end

$n_limit = 3

get '/line' do
  if params[:n_page].nil?
    @posts = client.xquery("SELECT p.id, p.user_id, p.image_url, p.content, u.id creater_id, u.name, u.password, u.profile_image_url FROM posts p join users u on p.user_id = u.id order by id desc limit #{$n_limit}")
  else
    @posts = client.xquery("SELECT p.id, p.user_id, p.image_url, p.content, u.id creater_id, u.name, u.password, u.profile_image_url FROM posts p join users u on p.user_id = u.id order by id desc limit #{$n_limit} offset #{$n_limit * (params[:n_page].to_i - 1)}")
  end
  @post_count = client.xquery("select count(*) from posts").first['count(*)'].to_i
  @page_size = (@post_count.to_f / $n_limit).ceil
  @n_page = params[:n_page].to_i
  @posts.each do |item|
    item['like_count'] = client.xquery("select count(*) from likes where post_id = ?", item['id']).first['count(*)']
    item['comment'] = client.xquery("select * from comments c join users u on c.user_id = u.id where post_id = ?", item['id']).to_a
  end
  erb :line
end

post '/send_image' do
  image_url = params[:image][:filename]
  content = params[:content]
  @results = client.xquery(
      'INSERT INTO posts (user_id, image_url,content)
      VALUES (?, ?, ?)',session[:user_id], image_url, content)  
  FileUtils.mv(params[:image][:tempfile], "./public/images/#{params[:image][:filename]}")  
  redirect '/top'      
end

post '/comment' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  post_id = params[:post_id]
  comment = params[:comment]
  @results = client.xquery(
      'INSERT INTO comments (post_id, user_id,comment)
      VALUES (?, ?, ?)', post_id, session[:user_id], comment)  
  redirect '/line'      
end

get '/edit_form/:id' do
  redirect '/login' unless session[:user_id]
  @edit = client.xquery('SELECT * FROM posts where id = ?', params[:id]).first  
  erb :edit_form
end

post '/update' do
  content = params[:content]
  id = params[:id]
  client.xquery('update posts set content = ? where id = ?',content, id)
  redirect '/top'  
end

get '/delete/:id' do
  redirect '/login' unless session[:user_id]
  client.xquery('delete from posts where id = ?;', params[:id])
  redirect '/top'
end

get '/follow/:to_user_id' do
  redirect '/line' unless session[:user_id]
  client.xquery('insert into follows values(null, ?, ?)', session[:user_id], params[:to_user_id])
  redirect '/line'
end

get '/unfollow/:to_user_id' do
  redirect '/login' unless session[:user_id]
  client.xquery('delete from follows where from_user_id = ? && to_user_id = ?;', session[:user_id], params[:to_user_id])
  redirect '/line'
end

get '/like/:post_id' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  client.xquery('insert into likes values(null, ?, ?)', session[:user_id], params[:post_id])
  redirect '/line'  
end

get '/unlike/:post_id' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  client.xquery('delete from likes where user_id = ? && post_id = ?;', session[:user_id], params[:post_id])
  redirect '/line'
end

get '/profile' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  @follow_count = client.xquery("select count(*) from follows where from_user_id = ?",session[:user_id]).first['count(*)']
  @follower_count = client.xquery("select count(*) from follows where to_user_id = ?",session[:user_id]).first['count(*)']
  erb :profile
end

post '/edit_profile' do
  new_icon_img = params[:new_icon_img][:filename]
  FileUtils.mv(params[:new_icon_img][:tempfile], "./public/profile_images/#{params[:new_icon_img][:filename]}")  
  client.xquery('update users set profile_image_url = ? where id = ?;', new_icon_img, session[:user_id])
  redirect '/profile'
end

get '/follow_list' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  @posts = client.xquery("SELECT name,profile_image_url FROM follows f join users u on f.to_user_id = u.id where from_user_id = ?", session[:user_id])  
  @follow_count = client.xquery("select count(*) from follows where from_user_id = ?",session[:user_id]).first['count(*)']
  erb :follow_list
end

get '/follower_list' do
  cookies[:msg] = 'ログインお願いします'
  redirect '/line' unless session[:user_id]
  cookies[:msg] = nil
  @posts = client.xquery("SELECT * FROM follows f join users u on f.from_user_id = u.id where to_user_id = ?", session[:user_id])
  @follower_count = client.xquery("select count(*) from follows where to_user_id = ?",session[:user_id]).first['count(*)']
  erb :follower_list
end

get '/number_like' do
  @posts = client.xquery("SELECT count(*) as like_count, p.id, p.user_id, p.image_url, p.content, u.id creater_id, u.name, u.password, u.profile_image_url FROM posts p join users u on p.user_id = u.id join likes l on l.post_id = p.id group by post_id order by like_count desc limit 5;")
  @posts.each do |item|
    item['like_count'] = client.xquery("select count(*) from likes where post_id = ?", item['id']).first['count(*)']
  end
  erb :number_like
end

