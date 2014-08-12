namespace :logs do
  desc "Tail rails log"
  task :tail do
    on roles(:app) do
      execute "tail -n 20 -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end
