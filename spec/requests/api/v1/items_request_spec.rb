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

  describe "DELETE /api/v1/items/:id" do
    before :each do
      @merchant = create(:merchant)
      @item1 = create(:item, merchant: @merchant)
      @item2 = create(:item, merchant: @merchant)
      @customer = create(:customer)
      @invoice = Invoice.create!(customer: @customer, merchant: @merchant, status: "shipped")
      @invoice_item1 = InvoiceItem.create!(invoice: @invoice, item: @item1, quantity: 1, unit_price: @item1.unit_price)
      @invoice_item2 = InvoiceItem.create!(invoice: @invoice, item: @item2, quantity: 1, unit_price: @item2.unit_price)
    end

    it "can destroy an existing item" do
      expect(Item.count).to eq(2)
      expect(InvoiceItem.count).to eq(2)
      expect(Invoice.count).to eq(1)

      delete "/api/v1/items/#{@item1.id}"

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(Item.count).to eq(1)
      expect(InvoiceItem.count).to eq(1)
      expect(Invoice.count).to eq(1)
    end

    it "deletes the invoice if the item deleted is the only item in the invoice" do
      expect(Item.count).to eq(2)
      expect(InvoiceItem.count).to eq(2)
      expect(Invoice.count).to eq(1)
      expect { Item.find(@item1.id) }.not_to raise_error(ActiveRecord::RecordNotFound)
      expect { Item.find(@item2.id) }.not_to raise_error(ActiveRecord::RecordNotFound)

      delete "/api/v1/items/#{@item1.id}"

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(Item.count).to eq(1)
      expect(InvoiceItem.count).to eq(1)
      expect(Invoice.count).to eq(1)

      delete "/api/v1/items/#{@item2.id}"

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(Item.count).to eq(0)
      expect(InvoiceItem.count).to eq(0)
      expect(Invoice.count).to eq(0)
      expect { Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Item.find(@item2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /api/v1/merchants/id/items" do
    it "happy: fetches all items for a merchant" do
      merchant = create(:merchant)
      item1 = create(:item, merchant: merchant)
      item2 = create(:item, merchant: merchant)
      item3 = create(:item, merchant: merchant)

      get "/api/v1/merchants/#{merchant.id}/items"

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

    it "sad: returns 404 if merchant not found" do
      get "/api/v1/merchants/7/items"

      expect(response).to have_http_status(:not_found)
      expect(response).not_to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:errors].first[:status]).to eq("404")
      expect(response_body[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=7")
    end
  end

  describe "GET /api/v1/items/:id/merchant" do
    it "happy: fetches the merchant of the item" do
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)

      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:data][:id].to_i).to eq(item.merchant.id)
      expect(data[:data][:type]).to eq("merchant")
      expect(data[:data][:attributes][:name]).to eq(item.merchant.name)
    end

    it "sad: throws 404 error if item not found" do
      get "/api/v1/items/35634/merchant"

      expect(response).to have_http_status(:not_found)
      expect(response).not_to be_successful
      expect(response.status).to eq(404)
    end
  end

  describe "GET /api/v1/items/find_all?name=Ring" do
    before :each do
      @merchant = create(:merchant)
    end

    it "happy: fetches all items with the given name" do
      item1 = create(:item, merchant: @merchant, name: "Ring")#
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")#
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")#
      item4 = create(:item, merchant: @merchant, name: "Pickled Herring")#
      item5 = create(:item, merchant: @merchant, name: "Spring Mattress")#
      item6 = create(:item, merchant: @merchant, name: "Fake Turtle Eggs")
      item7 = create(:item, merchant: @merchant, name: "Electric Trampoline Sweeper")

      get "/api/v1/items/find_all?name=Ring"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(5)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_an(String)

        expect(item).to have_key(:type)
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

    it "happy: fetches all items with the given min price" do
      item1 = create(:item, merchant: @merchant, unit_price: 100)#
      item2 = create(:item, merchant: @merchant, unit_price: 200)#
      item3 = create(:item, merchant: @merchant, unit_price: 50)

      get "/api/v1/items/find_all?min_price=99"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)
    end

    it "happy: fetches all items with the given max price" do
      item1 = create(:item, merchant: @merchant, unit_price: 100)#
      item2 = create(:item, merchant: @merchant, unit_price: 200)
      item3 = create(:item, merchant: @merchant, unit_price: 50)#

      get "/api/v1/items/find_all?max_price=199"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)
    end

    it "happy: fetches all items between the given min and max price" do
      item1 = create(:item, merchant: @merchant, unit_price: 100)#
      item2 = create(:item, merchant: @merchant, unit_price: 200)
      item3 = create(:item, merchant: @merchant, unit_price: 50)

      get "/api/v1/items/find_all?max_price=199&min_price=99"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(1)
    end

    it "happy: returns an empty array if no items match query" do
      item1 = create(:item, merchant: @merchant, name: "Ring")
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")

      get "/api/v1/items/find_all?name=Fake Turtle Eggs"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data]).to eq([])
      expect(items[:data].count).to eq(0)
    end

    it "happy: returns array even if space is sent in query" do
      item1 = create(:item, merchant: @merchant, name: "Ring")
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")

      get "/api/v1/items/find_all?name=  "

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data]).to eq([])
      expect(items[:data].count).to eq(0)

      get "/api/v1/items/find_all?name= "

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)
    end

    it "sad: must have parameter" do
      get "/api/v1/items/find_all"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('parameter cannot be empty or missing')
    end

    it "sad: param must not be empty" do
      get "/api/v1/items/find_all?name="

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('parameter cannot be empty or missing')
    end

    it "sad: cannot send both name and min_price" do
      item1 = create(:item, merchant: @merchant, name: "Ring")
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")

      get "/api/v1/items/find_all?name=Ring&min_price=99"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('cannot send both name and minimum price or maximum price')
    end

    it "sad: cannot send both name and max_price" do
      item1 = create(:item, merchant: @merchant, name: "Ring")
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")

      get "/api/v1/items/find_all?name=Ring&max_price=300"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('cannot send both name and minimum price or maximum price')
    end

    it "sad: cannot send both name and min_price and max_price" do
      item1 = create(:item, merchant: @merchant, name: "Ring")
      item2 = create(:item, merchant: @merchant, name: "Turing Coffee Mug")
      item3 = create(:item, merchant: @merchant, name: "Lord of The Rings Kite")

      get "/api/v1/items/find_all?name=Ring&min_price=99&max_price=300"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('cannot send name, minimum price and maximum price')
    end

    it "sad: isn't happy if unit_price is negative" do
      item = create(:item, merchant: @merchant)

      get "/api/v1/items/find_all?min_price=-100"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('price cannot be negative')

      get "/api/v1/items/find_all?max_price=-100"

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include('price cannot be negative')
    end
  end
end
