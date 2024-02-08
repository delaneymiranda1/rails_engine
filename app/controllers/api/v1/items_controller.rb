class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error_response

  def index
    if params[:merchant_id].present?
      check_for_merchant
    else
      items = Item.all
      render json: ItemSerializer.new(items)
    end
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    item = Item.create!(item_params)
    render json: ItemSerializer.new(item), status: 201
  end

  def update
    item = Item.find(params[:id])
    item.update!(item_params)
    render json: ItemSerializer.new(item)
  end

  def destroy
    item = Item.find(params[:id])
    destroy_invoice_if_needed(item)
    item.destroy!
  end

  def merchant
    @item = Item.find(params[:id])
    items_merchant
  end

  def find_all
    if params[:name]
      items = Item.where('name ILIKE ?', "%#{params[:name]}%")
      if items.empty?
        items = []
      end
    elsif params[:min_price] && !params[:max_price].present?
      items = Item.where('unit_price >=?', params[:min_price])
      if items.empty?
        items = []
      end
    elsif params[:max_price] && !params[:min_price].present?
      items = Item.where('unit_price <=?', params[:max_price])
      if items.empty?
        items = []
      end
    elsif params[:min_price] && params[:max_price]
      items = Item.where('unit_price >=? AND unit_price <=?', params[:min_price], params[:max_price])
      if items.empty?
        items = []
      end
    end
    render json: ItemSerializer.new(items)
  end

  private

  def not_found_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 404)).serialize_json, status: :not_found
  end

  def validation_error_response(exception)
    render json: ErrorSerializer.new(ErrorMessage.new(exception.message, 400))
    .serialize_json, status: :bad_request
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def destroy_invoice_if_needed(item)# should only happen if item is last on invoice
    item.invoices.each do |invoice|
      if invoice.items.count == 1
        invoice.destroy
      end
    end
  end

  def check_for_merchant
    merchant = Merchant.find(params[:merchant_id])
    if merchant
      items = merchant.items
      render json: ItemSerializer.new(items)
    else
      render json: { error: 'Merchant not found' }, status: :not_found
    end
  end

  def items_merchant
    merchant = @item.merchant
    if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: { error: "Merchant not found" }, status: 404
    end
  rescue
    render json: { error: "Item not found" }, status: :not_found
  end
end
