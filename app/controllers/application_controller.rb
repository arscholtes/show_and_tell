# Language: Ruby, Level: Level 4
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
end
