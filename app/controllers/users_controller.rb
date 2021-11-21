class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])  #modelのUserからidを取り出す
  end
  
  def new
  end
end
