class UsersController < ApplicationController


  def new
    @user = User.new
  end

  # def create(follower, followee)
  #   @user = User.new
  #   @user.twitter_follower_id = follower
  #   @user.twitter_followee_id = followee
  #   @user.save
  # end

end
