# Rails Application Templates

My Rails application templates

## Usage

```
mkdir YOUR_RAILS_PROJECT
cd YOUR_RAILS_PROJECT
bundle init
bundle install --path vendor/bundle --jobs=4
```

for postgres

```
bundle exec rails new . --database=postgresql --skip-test-unit --skip-turbolinks -m https://raw.githubusercontent.com/kawahiro311/rails-application-templates/master/rails4_template.rb
```

for mysql

```
bundle exec rails new . --database=mysql --skip-test-unit --skip-turbolinks -m https://raw.githubusercontent.com/kawahiro311/rails-application-templates/master/rails4_template.rb
```
