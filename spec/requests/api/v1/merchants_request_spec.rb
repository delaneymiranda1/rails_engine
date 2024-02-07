require "rails_helper"

describe "merchants API" do
  it "fetches all merchants" do
    merchant = create(:merchant)

    get "/api/v1/merchants"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].length).to eq(1)
    expect(merchants[:data].count).to eq(1)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end
end
