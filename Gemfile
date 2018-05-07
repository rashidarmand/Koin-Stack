source "https://rubygems.org"

ruby "2.5.0"
gem "sinatra"
gem "sinatra-flash"
gem "activerecord"
gem "sinatra-activerecord"
gem "rake"

group :development do
  # our sqlite3 gem will only be used locally
  #   the sqlite3 gem is an adapter for sqlite
  gem "sqlite3"
  gem "pry"
end

group :production do
  # our pg gem will only be used on production
  #   the pg gem is an adapter for postgresql
  gem "pg"
end
