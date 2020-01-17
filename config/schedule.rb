# Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

env 'GEM_HOME', ENV['GEM_HOME']
# https://github.com/javan/whenever/wiki/Output-redirection-aka-logging-your-cron-jobs
set :output, File.join(Whenever.path, "log", "cron.log")

if @environment == 'production'
  # every 2.months every day in 0,12 hours
  every '0 0,12 * */2 *' do
    command "sudo /usr/local/bin/certbot-auto renew"
  end

  # every night in 0 0
  every '0 0 * * *' do
    rake 'picture:generate_variants', environment: :production
  end
end
