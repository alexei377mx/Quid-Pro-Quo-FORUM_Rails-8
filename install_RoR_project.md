# 💎 Installing Ruby on Rails on Ubuntu

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
