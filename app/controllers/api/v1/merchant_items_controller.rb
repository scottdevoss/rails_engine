class Api::V1::MerchantItemsController < ApplicationController

  def index
    render json: MerchantSerializer.new(Merchant.find(Item.find(params[:id]).merchant_id))
  end
end