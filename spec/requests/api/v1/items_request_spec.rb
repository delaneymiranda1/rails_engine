require "rails_helper"

describe "items API" do
  it "fetches all items" do
    merchant = create(:merchant)
    items = create_list(:item, 7, merchant: merchant)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

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

  it 'creates an item' do
    merchant = create(:merchant)
    item = ({
      name: 'Butter',
      description: 'Lite',
      unit_price: 3.99,
      merchant_id: merchant.id
    })

    headers = {"CONTENT_TYPE" => "application/json"}
    
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item)
    expect(response).to be_successful
    new_item = Item.last 

    expect(new_item.name).to eq(item[:name])
    expect(new_item.description).to eq(item[:description])
    expect(new_item.unit_price).to eq(item[:unit_price])
  end

  it 'gets an error if one of the attributes is not filled in' do
    merchant = create(:merchant)
    item = ({
      name: '',
      description: 'Lite',
      unit_price: 3.99,
      merchant_id: merchant.id
    })
    headers = {"CONTENT_TYPE" => "application/json"}
    
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item)
    expect(response).to_not be_successful
    data = JSON.parse(response.body, symbolize_names: true)
    expect(data[:errors]).to be_a(Array)
    expect(data[:errors].first[:status]).to eq("400")
    expect(data[:errors].first[:title]).to eq("Validation failed: Name can't be blank")
  end
end
