namespace :apn do
  
  namespace :notifications do
    
    desc "Deliver all unsent APN notifications."
    task :deliver => [:environment] do
      #Activity.active(Time.zone.now).to_be_remind(Time.zone.now)
    end

  end # notifications
  
  namespace :feedback do
    desc "Process all devices that have feedback from APN."
    task :process => [:environment] do
      #APN::App.process_devices
    end
  end
  
end 