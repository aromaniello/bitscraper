class BitcointalkUsersController < ApplicationController

	def index
		@bitcointalk_users = BitcointalkUser.all
	end

	def show
		@bitcointalk_user = BitcointalkUser.find(params[:id])
	end

end
