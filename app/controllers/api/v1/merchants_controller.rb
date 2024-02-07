class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error_response
  def find
    if params[:name].blank?
      render json: { error: "Parameter 'name' cannot be empty" }, status: :unprocessable_entity
      return
    end

    merchant = Merchant.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%").order(:name).first
    if merchant.present?
      render json: MerchantSerializer.new(merchant)
    else
      render json: { error: "Merchant not found" }, status: :not_found
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

  def validation_error_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 400))
    .serialize_json, status: :bad_request
  end

end
