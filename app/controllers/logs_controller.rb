class LogsController < ApplicationController
  load_and_authorize_resource

  def index
    @logs = Log.order(created_at: :desc).page(params[:page]).per(20)
  end
end
