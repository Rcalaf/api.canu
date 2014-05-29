class TribesController < ApplicationController

	def list

		tribes = []

		relationsTribe = Tribe.where('user_id = ?',params[:user_id])

		relationsTribe.each do |relation|
			user = User.find_by_id(relation.friend_id)
			tribes << user
		end

		render json: tribes, status: 200

	end

	def add

		relationsTribe = Tribe.where('user_id = ?',params[:user_id])

		neverAdding = true

		relationsTribe.each do |relation|
			if relation.friend_id == params[:friend_id]
				neverAdding = false
			end
		end
		
		if neverAdding
			
			tribe = Tribe.new

			tribe.user_id = params[:user_id]
			tribe.friend_id = params[:friend_id]

			tribe.save

		end

		render json: {}, status: 200

	end

	def remove

		relationsTribe = Tribe.where('user_id = ?',params[:user_id])

		relationsTribe.each do |relation|
			if relation.friend_id == params[:friend_id].to_i
				relation.destroy
			end
		end

		render json: {}, status: 200
		
	end

end
