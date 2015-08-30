class NotificationController < ApplicationController

	def read
		
		user = User.find(params[:user_id])
		activity = Activity.find(params[:activity_id])

		notifs = Notification.where(' activity_id = ? AND user_id = ?', activity.id, user.id).where(:read =>  false)

		notifs.each do |notif|
			notif.update_attribute(:read,true)
        end

        countNotifs = 0

        allNotifsUser = Notification.where('user_id = ?', user.id).where(:read =>  false)

        allNotifsUser.each do |notif|
			if notif.activity.end_date > Time.zone.now
				countNotifs = countNotifs + 1
			end
        end

        user.devices.each do |device| 
          device.update_attribute(:badge,countNotifs)
        end

        render json: { number_notifications: countNotifs}

	end

end
