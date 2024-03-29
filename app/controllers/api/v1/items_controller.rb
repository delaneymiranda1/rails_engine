class Api::V1::ItemsController < ApplicationController

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
    if (params[:name] && params[:name].length > 0) && (!params[:max_price] && !params[:min_price])
      @items = Item.where('name ILIKE ?', "%#{params[:name]}%")
      check_for_items
    elsif params[:min_price] && (!params[:max_price] && !params[:name])
      if params[:min_price].to_i > 0
        @items = Item.where('unit_price >=?', params[:min_price])
        check_for_items
      else
        render json: { errors: 'price cannot be negative' }, status: :bad_request
      end
    elsif params[:max_price] && (!params[:min_price] && !params[:name])
      if params[:max_price].to_i > 0
        @items = Item.where('unit_price <=?', params[:max_price])
        check_for_items
      else
        render json: { errors: 'price cannot be negative' }, status: :bad_request
      end
    elsif params[:min_price] && (params[:max_price] && !params[:name])
      @items = Item.where('unit_price >=? AND unit_price <=?', params[:min_price], params[:max_price])
      check_for_items
    else
      find_all_sad_paths
    end
  end

  private

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
    end
  end

  def items_merchant
    merchant = @item.merchant
    if merchant
      render json: MerchantSerializer.new(merchant)
    end
  end

  def check_for_items
    if @items
      render json: ItemSerializer.new(@items)
    end
  end

  def find_all_sad_paths
    if !params[:name].present? && (!params[:min_price].present? && !params[:max_price].present?)
      render json: { error: 'parameter cannot be empty or missing' }, status: :bad_request
    elsif params[:name].present? && (params[:min_price].present? && params[:max_price].present?)#must come before next condition
      render json: { error: 'cannot send name, minimum price and maximum price' }, status: :bad_request
    elsif params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      render json: { error: 'cannot send both name and minimum price or maximum price' }, status: :bad_request
    end
  end
end
