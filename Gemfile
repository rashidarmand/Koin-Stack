source "https://rubygems.org"

gem "sinatra"
gem "sinatra-flash"
gem "activerecord"
# gem "sqlite3"
gem "sinatra-activerecord"
gem "rake"
# gem "pry"

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
