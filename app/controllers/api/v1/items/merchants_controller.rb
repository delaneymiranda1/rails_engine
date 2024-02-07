class Api::V1::Items::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index 
    item = Item.find(params[:id])
    merchant = item.merchants
    render json: MerchantSerializer.new(merchant)
  end

  private

  def not_found_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 404)).serialize_json, status: :not_found
  end
end
