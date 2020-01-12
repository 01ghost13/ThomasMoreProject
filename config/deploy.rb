# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "aitscore"
set :repo_url, "git@github.com:01ghost13/ThomasMoreProject.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ubuntu/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files,
#        'config/database.yml',
#        'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs,
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'vendor/bundle',
       '.bundle',
       'public/system',
       'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# capistrano/nginx
set :website_url, 'arbeidsinteressetest.be'
set :nginx_server_name, "www.#{fetch :website_url} #{fetch :website_url}"

# capistrano/nginx/ssl
set :nginx_use_ssl, true
set :nginx_ssl_certificate, "/etc/letsencrypt/live/www.arbeidsinteressetest.be/fullchain.pem"
set :nginx_ssl_certificate_key, "/etc/letsencrypt/live/www.arbeidsinteressetest.be/privkey.pem"
set :lets_encrypt_conf, "/etc/letsencrypt/options-ssl-nginx.conf"
set :ssl_dhparam, "/etc/letsencrypt/ssl-dhparams.pem"
