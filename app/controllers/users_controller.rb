# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[show update]

  layout 'user'

  def show
    set_meta
  end

  def update
    flash[:error] = @user.errors.full_messages if @user.update_attributes user_params

    redirect_to user_path(@user)
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:max_distance, :min_score, :random_type, :open_now)
  end
end
