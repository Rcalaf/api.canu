class CounterController < ApplicationController

 def show

  user = User.find(params[:user_id])

  if user

    isCountIn = 0
    isUnlock = 0

    count = Counter.find_by_user_id(params[:user_id])

    if count
      isCountIn = 1

      if count.unlock
        isUnlock = 1
      end

    end

    render json: {
      countTotal: Counter.where('available_for <= ?',Time.now).count, 
      isCountIn:isCountIn,
      isUnlock:isUnlock
    }
  else
    render json: {
      countTotal: 0, 
      isCountIn:0,
      isUnlock:0
    }
  end

 end

 def countMe

  user = User.find(params[:user_id])

  if user

    count = Counter.find_by_user_id(params[:user_id])

    if !count
      count = {available_for: Time.now, unlock: false, user_id: params[:user_id]}
      count = Counter.create(count)
      if count.valid?

        dayStart = 1

        (1..3).each do |i|
          puts dayStart
          count = {available_for: dayStart.days.from_now, unlock: false}
          count = Counter.create(count)
          dayStart = dayStart * 3
        end
      end
    end
  end

  render json: {}, status: 200

 end

end
