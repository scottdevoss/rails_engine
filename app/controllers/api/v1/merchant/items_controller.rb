class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Merchant.find(params[:id]).items)
  end
end