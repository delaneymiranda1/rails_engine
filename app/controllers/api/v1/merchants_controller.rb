class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  def find
    if params[:name].blank?
      render json: { data: { status: 422, title: "Parameter 'name' cannot be empty" } }, status: :unprocessable_entity
      return
    end

    merchant = Merchant.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%").order(:name).first
    if merchant.present?
      render json: MerchantSerializer.new(merchant)
    else
      render json: { data: { status: 404, title: "Merchant not found" } }, status: :not_found
    end
  end

  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  private

  def not_found_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 404)).serialize_json, status: :not_found
  end
end
