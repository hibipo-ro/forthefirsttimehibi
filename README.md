# instagram-clone

始める前に、、、
publicフォルダ直下にimagesフォルダを作ってください。

ターミナルで
mysql -u root

create database instagram; 

use instagram;

create table users (id int(10) auto_increment, name varchar(20), password varchar(20), profile_image_url varchar(100), primary key(id));

create table posts (id int(10) auto_increment, user_id int(10), image_url varchar(50), content varchar(200), primary key(id));

create table likes (id int(10) auto_increment, user_id int(10), post_id int(10), primary key(id));

create table follows (id int(10) auto_increment, from_user_id int(10), to_user_id int(10), primary key(id));

create table comments (id int(10) auto_increment, post_id int(10), user_id int(10), comment varchar(100), primary key(id));
