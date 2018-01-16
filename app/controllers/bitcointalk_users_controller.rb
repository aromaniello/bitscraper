class BitcointalkUsersController < ApplicationController

	def index
		@bitcointalk_users = BitcointalkUser.paginate(page: params[:page], per_page: 50)
	end

	def show
		@bitcointalk_user = BitcointalkUser.find(params[:id])
	end

end
