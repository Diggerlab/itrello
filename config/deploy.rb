set :application, "itrello"
set :repository,  "scm@project.diggerlab.com:itrello.git"
set :branch, "master"
set :user, "webuser"
set :use_sudo, false
set :scm, :git

set :deploy_to, "/home/webuser/www/itrello"
set :current_path, "#{deploy_to}/current"
set :releases_path, "#{deploy_to}/releases/"
set :shared_path, "#{deploy_to}/shared"

role :web, "122.226.109.67"                          # Your HTTP server, Apache/etc
role :app, "122.226.109.67"                          # This may be the same as your `Web` server
# role :db,  "192.168.1.128", :primary => true        # This is where Rails migrations will run
# role :db,  "175.102.1.128"

namespace:deploy do
    namespace:app do 
      task:start do
      end
      
      task:stop do
      end

      after "deploy:restart", :roles => :app do
        #add any tasks in here that you want to run after the project is deployed
        run "rm -rf #{release_path}.git"
        run "chmod -R 755 #{current_path}"
      end
    end

end

