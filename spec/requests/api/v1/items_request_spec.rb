require "rails_helper"

describe "items API", type: :request do
  it "fetches all items" do
    merchant = create(:merchant)
    items = create_list(:item, 7, merchant: merchant)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].length).to eq(7)
    expect(items[:data].count).to eq(7)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  it 'fetches one item' do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    get "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    item = JSON.parse(response.body, symbolize_names: true)


    data = item[:data]

    expect(data).to have_key(:id)
    expect(data[:id]).to be_an(String)

    expect(data[:attributes]).to have_key(:name)
    expect(data[:attributes][:name]).to be_a(String)

    expect(data[:attributes]).to have_key(:description)
    expect(data[:attributes][:description]).to be_a(String)

    expect(data[:attributes]).to have_key(:unit_price)
    expect(data[:attributes][:unit_price]).to be_a(Float)

    expect(data[:attributes]).to have_key(:merchant_id)
    expect(data[:attributes][:merchant_id]).to be_a(Integer)
  end

  it 'throws error if id does not exist' do
    get "/api/v1/items/1"

    expect(response).to_not be_successful
    expect(response.status).to eq(404)

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:errors]).to be_a(Array)
    expect(data[:errors].first[:status]).to eq("404")
    expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=1")
  end

  describe "PATCH /api/v1/items/:id" do
    it "can update an existing item" do
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)

      patch "/api/v1/items/#{item.id}", params: { item: { name: "Donkey Donkey", description: "BFF forever?", unit_price: 253452.65, merchant_id: merchant.id } }

      updated_item = item.reload

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(updated_item.name).to eq("Donkey Donkey")
      expect(updated_item.description).to eq("BFF forever?")
      expect(updated_item.unit_price).to eq(253452.65)
    end

    it "throws error if item does not exist" do
      merchant = create(:merchant)

      patch "/api/v1/items/1", params: { item: { name: "Donkey Donkey", description: "BFF forever?", unit_price: 253452.65, merchant_id: merchant.id } }

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=1")
    end
  end
end
