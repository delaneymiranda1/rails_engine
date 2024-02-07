require "rails_helper"

describe "merchant items API", type: :request do
  it "returns the merchant associated with an item" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    get "/api/v1/items/#{item.id}/merchant"

    expect(response).to be_successful

    items_merchant = JSON.parse(response.body, symbolize_names: true)

    expect(items_merchant[:data]). have_key(:item_id)
    expect(items_merchant[:data][:item_id]).to be_an(String)

    expect(items_merchant[:data]). have_key(:merchant_id)
    expect(items_merchant[:data][:merchant_id]).to be_an(String)

    expect(items_merchant[:data][:attributes]).to have_key(:name)
    expect(items_merchant[:data][:attributes][:name]).to be_a(String)
  end
end