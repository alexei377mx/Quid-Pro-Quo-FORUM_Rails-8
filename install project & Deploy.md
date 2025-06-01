# 💎 Installing Ruby on Rails based on Ubuntu/Debian

## Índice

1. [Install Ruby](#1-install-ruby)
2. [Configure Git and SSH](#2-configure-git-and-ssh)
3. [Clone project and set Ruby version](#3-clone-project-and-set-ruby-version)
4. [Install Rails](#4-install-rails)
5. [Install database](#5-install-database)
6. [Create a Rails app if none exists](#6-create-a-rails-app-if-none-exists)
7. [Deploy on Render with CockroachDB Cloud](#7-deploy-on-render-with-cockroachdb-cloud)
8. [Database configuration example (`database.yml`)](#8-database-configuration-example-databaseyml)

---

## 1. Install Ruby

Update and install dependencies:

```bash
sudo apt-get update
sudo apt install build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev
```

Install Mise (Ruby version manager):

```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.bashrc
source ~/.bashrc
```

Check the required Ruby version (look for the `.ruby-version` file if you have an existing project):

```bash
cat .ruby-version  # example: 3.2.2
```

Install that version or a default one:

```bash
mise use --global ruby@3.2.2
# or
mise use --global ruby@3
```

Verify the installation:

```bash
ruby --version
```

Update RubyGems:

```bash
gem update --system
```

---

## 2. Configure Git and SSH

```bash
git config --global color.ui true
git config --global user.name "YOUR NAME"
git config --global user.email "YOUR_EMAIL@example.com"
git config --global core.editor "code --wait"

ssh-keygen -t ed25519 -C "YOUR_EMAIL@example.com"
cat ~/.ssh/id_ed25519.pub
```

Add the SSH key to GitHub and test the connection:

```bash
ssh -T git@github.com
```

---

## 3. Clone project and set Ruby version

```bash
git clone git@github.com:username/repository.git
cd repository
cat .ruby-version
mise use --global ruby@3.2.2
ruby --version
```

---

## 4. Install Rails

```bash
gem install rails -v 8.0.2
rails -v
```

---

## 5. Install database

MySQL:

```bash
sudo apt-get install mysql-server mysql-client libmysqlclient-dev
```

PostgreSQL (recommended):

```bash
sudo apt install postgresql libpq-dev
```

---

## 6. Create a Rails app if none exists

MySQL:

```bash
rails new myapp -d mysql
```

PostgreSQL:

```bash
rails new myapp -d postgresql
```

Then:

```bash
cd myapp
# Edit config/database.yml if you use custom username/password
rake db:create
rails server
```

Open [http://localhost:3000](http://localhost:3000)

---

## 7. Deploy on Render with CockroachDB Cloud

### 7.1 Create CockroachDB Cloud database

* Sign up or login at [CockroachDB Cloud](https://www.cockroachlabs.com/product/cockroachcloud/).
* Create a PostgreSQL cluster and copy your SSL connection URL (example: `postgresql://user:password@host:port/defaultdb?sslmode=require`).

### 7.2 Configure Rails for production database

In your `config/database.yml` file, ensure the production configuration uses `DATABASE_URL`:

```yaml
production:
  primary:
    url: <%= ENV['DATABASE_URL'] %>
  cable:
    url: <%= ENV['DATABASE_URL'] %>
  queue:
    url: <%= ENV['DATABASE_URL'] %>
  cache:
    url: <%= ENV['DATABASE_URL'] %>
```

Make sure the PostgreSQL gem is included in your `Gemfile`:

```ruby
gem 'pg'
```

And run:

```bash
bundle install
```

Avoid `enable_extension "plpgsql"` in `schema.rb`

Remove the line from `db/schema.rb`:

```ruby
# Remove or comment out this line
# enable_extension "plpgsql"
```

### 7.3 Push your app to GitHub

Ensure your project is pushed to a remote GitHub (or other) repository accessible by Render.

### 7.4 Configure Render service

You can define your Render services and database in a `render.yaml` file like this:

```yaml
databases:
  - name: db
    databaseName: db
    user: db_user
    plan: free

services:
  - type: web
    name: mysite
    runtime: ruby
    plan: free
    buildCommand: >
      bundle install &&
      yarn install --check-files &&
      bundle exec rake assets:precompile &&
      bundle exec rails db:migrate &&
      bundle exec rails db:seed
    # preDeployCommand: "bundle exec rails db:migrate" # only available on paid plans
    startCommand: "bundle exec rails server -b 0.0.0.0 -p $PORT"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: db
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: WEB_CONCURRENCY
        value: 2 # sensible default
```

### 7.5 Deploy and verify

* Deploy your app on Render and open the provided URL.
* Verify that the app connects correctly to CockroachDB Cloud and runs smoothly.

---

## 8. Database configuration example (`config/database.yml`)

```yaml
# PostgreSQL
#
# Install the PostgreSQL driver
#   gem install pg
#
# Ensure the PostgreSQL gem is defined in your Gemfile
#   gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: postgres
  password: root
  host: localhost

development:
  <<: *default
  database: db_development

test:
  <<: *default
  database: db_test

production:
  primary:
    url: <%= ENV['DATABASE_URL'] %>
  cable:
    url: <%= ENV['DATABASE_URL'] %>
  queue:
    url: <%= ENV['DATABASE_URL'] %>
  cache:
    url: <%= ENV['DATABASE_URL'] %>
```
