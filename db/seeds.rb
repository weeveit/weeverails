# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
salt = BCrypt::Engine.generate_salt
password = "weevechange"
hashed_password = BCrypt::Engine.hash_secret(password, salt)
Admin.create(:username => 'admins', :hashed_password => hashed_password, :salt => salt)