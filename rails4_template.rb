## .gitignore
run 'wget -O .gitignore https://raw.githubusercontent.com/github/gitignore/master/Rails.gitignore'

# Gemfile
gsub_file 'Gemfile', /gem 'turbolinks'\n/, ''

gem 'paranoia', '~> 2.0' # 論理削除
gem 'kaminari' # ページネーション
gem 'exception_notification' # エラー通知

gem_group :development, :test do
  gem 'pry-rails' # REPL

  # Rspec
  gem 'rspec-rails'
  gem 'capybara'
  gem 'turnip'

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

# setup rspec
generate 'rspec:install'

create_file '.rspec', <<EOF, force: true
--color -f d -r turnip/rspec
EOF

# remove files
remove_file 'README.rdoc'
