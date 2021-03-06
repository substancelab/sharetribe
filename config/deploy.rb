# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "tumlino"
set :repo_url, "git@github.com:substancelab/sharetribe.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Cache bundled gems across deployments
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
append :linked_files, 'config/database.yml', 'config/config.yml'

set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v7.8.0'
set :nvm_map_bins, %w{node npm yarn}

set :rbenv_type, :user
set :rbenv_ruby, '2.3.4'

set :default_env, {
  "PATH" => [
    "$PATH",
    "/home/tumlino_production/.nvm/versions/node/v7.8.0/bin"
  ].join(":")
}

set :whenever_environment, fetch(:stage)
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_variables, -> do
  "'environment=#{fetch(:whenever_environment)}" \
  "&rbenv_root=#{fetch(:rbenv_path)}'"
end
# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  task :make_systemd_directories do
    on roles(:worker) do
      systemd_config_directory = "/home/tumlino_production/.config/systemd/user/"
      execute(:mkdir, "-p", systemd_config_directory)
    end
  end

  before "systemd:delayed_job:setup", "deploy:make_systemd_directories"
  after "deploy:publishing", "systemd:delayed_job:restart"
end
