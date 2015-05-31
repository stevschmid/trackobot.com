source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.10'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

gem 'devise'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails', require: false
end

gem 'therubyracer'
gem 'less-rails' #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'twitter-bootstrap-rails', github: 'seyhunak/twitter-bootstrap-rails', branch: 'bootstrap3'

gem 'bootstrap_form'
gem 'chosen-rails'

gem 'kaminari'
gem 'kaminari-bootstrap', '~> 3.0.1'

gem 'active_model_serializers'

gem 'font-awesome-sass'

gem 'redcarpet'

gem 'local_time'

group :staging, :production do
  gem 'pg'
  gem 'newrelic_rpm'

  # Use unicorn as the app server
  gem 'unicorn'
end

gem 'dotenv-rails'
group :development do
  # Use Capistrano for deployment
  gem 'capistrano-rails'
end

# view support
gem 'schema_plus'

gem 'possessive'
