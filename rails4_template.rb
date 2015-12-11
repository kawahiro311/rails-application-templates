require 'bundler'

## .gitignore
run 'wget -O .gitignore https://raw.githubusercontent.com/github/gitignore/master/Rails.gitignore'

# Gemfile
gem 'paranoia', '~> 2.0' # 論理削除
gem 'kaminari' # ページネーション
gem 'exception_notification' # エラー通知

gem_group :development, :test do
  gem 'pry-rails' # REPL

  # Rspec
  gem 'rspec-rails'
  gem 'capybara'
  gem 'turnip'
  gem 'factory_girl_rails'
  gem 'database_rewinder'

  gem 'quiet_assets' # ログ出力抑制
  gem 'did_you_mean' # typo cover
end

gem_group :development do
  # Deploy
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'
  gem 'slackistrano', require: false
end

# install gems
run 'bundle install --path vendor/bundle --jobs=4'

# install locales
remove_file 'config/locales/en.yml'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/en.yml -P config/locales/'
run 'wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# config/application.rb
application do
  %q{
    config.time_zone = 'Tokyo'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.view_specs false
      g.controller_specs false
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end
  }
end

# Remove files
remove_file 'README.rdoc'

# Remove comment and empty lines
empty_line_pattern = /^\s*\n/
comment_line_pattern = /^\s*#.*\n/

gsub_file 'Gemfile', comment_line_pattern, ''

gsub_file 'config/application.rb', comment_line_pattern, ''

gsub_file 'config/routes.rb', comment_line_pattern, ''
gsub_file 'config/routes.rb', empty_line_pattern, ''

gsub_file 'config/database.yml', comment_line_pattern, ''

# setup rspec
after_bundle do
  generate 'rspec:install'

  create_file 'spec/turnip_helper.rb', <<RUBY
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'

require 'capybara'
require 'capybara/poltergeist'

require 'turnip'
require 'turnip/capybara'
require 'turnip/rspec'

require 'factory_girl_rails'

require 'database_cleaner'

# using driver (need phantomjs)
Capybara.current_driver = :poltergeist
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.run_server = true

# web driverの設定
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :default_wait_time => 30, :timeout => 100})
end

Dir.glob("spec/**/*steps.rb") { |f| load f, true }


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end
RUBY
end

# git
after_bundle do
  git :init
end
