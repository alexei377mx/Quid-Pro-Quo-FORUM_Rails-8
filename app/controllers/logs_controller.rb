class LogsController < ApplicationController
  load_and_authorize_resource

  def index
    @logs = @logs.includes(:user).order(created_at: :desc).limit(100)
  end
end
