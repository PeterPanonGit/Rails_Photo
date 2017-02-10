# Rails_Photo

# install ruby and rails
## if testing locally using 
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs

cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 2.3.3
rbenv global 2.3.3
ruby -v

gem install bundler

curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs

gem install rails -v 4.2.4

# install mysql
sudo apt-get install mysql-server mysql-client libmysqlclient-dev
# mysql -u root -p
# create database photopaint_dev;
# use photopaint_dev;
# grant all privileges on photopaint_dev.* to 'sbadmin'@'localhost' identified by 'sbadmin';
# UPDATE `photopaint_dev`.`clients` SET `role_id`='300' WHERE `id`='1';

# install redis
## if test locally in dev mode, installing redis is not necessary and can set false in app/helpers/worker_helper.rb
sudo apt-get install build-essential tcl
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
make test
make install

# run
bundle install
rake db:migrate
rails s

# deploy
in config/deploy.rb, change repo_url to the correct repo
in config/deploy.rb, in set :default_env, setup s3 credentials
in config/deploy/production.rb, change the server name to the correct one
