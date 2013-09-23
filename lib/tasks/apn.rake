namespace :apn do
  
  namespace :notifications do
    
    desc "Deliver all unsent APN notifications."
    task :deliver => [:environment] do
      notifications = []
      badge = nil
      device = nil
      ActivityNotification.includes(:activity).where('activities.start <= ? && end_date > ?',Time.zone.now + 30.minutes,Time.zone.now).order('device_id asc').each do |notification|
        device && notification.device.id == device.id ?  badge += 1 : badge = notification.device.badge.to_i + 1
        notifications << APNS::Notification.new(notification.device.token,{:alert => "#{notification.activity.title} in about 30 minutes", :badge => badge, :sound => 'default'})
        puts "#{(Time.zone.now - notification.activity.start).truncate}"
        puts Time.zone.now 
        puts notification.activity.start
        device = notification.device
        notification.delete
      end
      APNS.send_notifications(notifications) unless notifications.empty?
    end

  end # notifications
  
  namespace :feedback do
    desc "Process all devices that have feedback from APN."
    task :process => [:environment] do
      #APN::App.process_devices
    end
  end
  
end 