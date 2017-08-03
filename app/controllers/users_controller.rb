class UsersController < ApplicationController
  before_action :find_user, only: [:show, :update]

  def show
  	set_meta
  end

  def update
    if @user.update_attributes user_params
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages
      redirect_to user_path(@user)
    end
  end

  private
  	def find_user
  		@user = User.find(params[:id])
  	end

  	def user_params
    	params.require(:user).permit(:max_distance, :min_score, :random_type)
	  end
end
