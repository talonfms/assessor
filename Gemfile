source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.0"
# Use postgresql as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.3"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.0", ">= 1.0.2"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", github: "excid3/jbuilder", branch: "fix-caching-with-api-controllers" # "~> 2.12"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", ">= 2.0.0.rc2", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.12"

# Use Rails' new view component system
gem "view_component"

# Translate enum values for internationalization
gem "translate_enum"

gem "positioning"

gem "rubyzip", "~> 2.3"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", ">= 4.1.0"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", ">= 3.39"
  gem "selenium-webdriver", ">= 4.20.1"
  gem "mocha"
end

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.1"

# Jumpstart Pro dependencies
require_relative "lib/jumpstart/lib/jumpstart/configuration"
eval_gemfile "Gemfile.jumpstart"

# We recommend using strong migrations when your app is in production
# gem "strong_migrations"

group :development, :test do
  gem "pry"
  gem "pry-rails"  # Adds some nice Rails-specific features to pry
end

gem "aws-sdk-s3", "~> 1.182"

gem "dotenv-rails", "~> 3.1"
