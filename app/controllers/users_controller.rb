# Language: Ruby, Level: Level 4
class UsersController < ApplicationController
  def index
    @users = User.all
  end
end
