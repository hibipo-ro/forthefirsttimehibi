# instagram-clone

始める前にやること
publicフォルダ直下にimagesフォルダを作ってください。

ターミナルで
mysqlを開く
```mysql -u root```
データベース作成
create database instagram; 
データベース選択
use instagram;
ユーザーテーブル作成
create table users (id int(10) auto_increment, name varchar(20), password varchar(20), profile_image_url varchar(100), primary key(id));
投稿テーブル作成
create table posts (id int(10) auto_increment, user_id int(10), image_url varchar(50), content varchar(200), primary key(id));
いいねテーブル作成
create table likes (id int(10) auto_increment, user_id int(10), post_id int(10), primary key(id));
フォローテーブル作成
create table follows (id int(10) auto_increment, from_user_id int(10), to_user_id int(10), primary key(id));
コメントテーブル作成
create table comments (id int(10) auto_increment, post_id int(10), user_id int(10), comment varchar(100), primary key(id));
