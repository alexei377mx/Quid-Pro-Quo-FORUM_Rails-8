class RadiosController < ApplicationController
  load_and_authorize_resource

  before_action :set_radio, only: [ :destroy ]

  def create
    @radio = Radio.new(radio_params)
    if @radio.save
      redirect_to admin_path(tab: "radios"), notice: "Radio añadida correctamente."
    else
      @radios = Radio.order(:title)
      flash.now[:error] = "No se pudo añadir la radio. Revisa los datos."
      render "admin/radios", status: :unprocessable_entity
    end
  end

  def destroy
    @radio.destroy
    redirect_to admin_path(tab: "radios"), notice: "Radio eliminada correctamente."
  end

  private

  def set_radio
    @radio = Radio.find(params[:id])
  end

  def radio_params
    params.require(:radio).permit(:title, :stream_url)
  end
end
