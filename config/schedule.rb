# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

#set :job_template, "bash -l -c ':job'"

# Example:
#
#set :output, "#{Rails.root}/log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

 job_type :custom_rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent"
 
 every 5.minutes do
   custom_rake "apn:notifications:deliver"
 end

# Learn more: http://github.com/javan/whenever
