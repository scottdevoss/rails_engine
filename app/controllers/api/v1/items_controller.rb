class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_response

  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create!(item_params)), status: 201
  end

  def update
    
    render json: ItemSerializer.new(Item.update(params[:id],item_params))
  end

  def destroy
    render json: Item.delete(params[:id]), status: 204
  end

  def find_all
    if params[:min_price] && params[:max_price] && params[:min_price].to_i >= 0 && params[:max_price].to_i >= 0 && !params[:name]
      render json: ItemSerializer.new(Item.where("unit_price >= #{params[:min_price]}").where("unit_price <= #{params[:max_price]}"))
    elsif params[:min_price] && params[:min_price].to_i >= 0 && !params[:name]
      render json: ItemSerializer.new(Item.where("unit_price >= #{params[:min_price]}"))
    elsif params[:max_price] && params[:max_price].to_i >= 0 && !params[:name]
      render json: ItemSerializer.new(Item.where("unit_price <= #{params[:max_price]}"))
    elsif params[:name] && !params[:min_price] && !params[:max_price]
      render json: ItemSerializer.new(Item.where("lower(name) LIKE ?", "%#{params[:name].downcase}%"))
    else
      render json: ErrorSerializer.new(ErrorMessage.new(nil, 400)).serialize_json, status: 400
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def not_found_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 404))
    .serialize_json, status: :not_found
  end

  def invalid_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 400))
    .serialize_json, status: :bad_request
  end
end