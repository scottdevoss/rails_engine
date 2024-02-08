class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def find
    variable = Merchant.where("lower(name) LIKE ?", "%#{params[:name].downcase}%").order('lower(name)').first
    if variable
      render json: MerchantSerializer.new(variable)
    else 
      render json: ErrorSerializer.new(ErrorMessage.new(nil, 200)).data_serialize
    end
  end

  private

  def not_found_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 404))
    .serialize_json, status: :not_found
  end
end