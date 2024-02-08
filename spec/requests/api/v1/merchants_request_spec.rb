require "rails_helper"

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 10)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
    
    expect(merchants[:data].count).to eq(10)

    merchants[:data].each do |merchant|
     
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_an(String)
    end
  end

    it "sends a merchant based on ID" do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data].count).to eq(3)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data]).to be_a(Hash)

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_an(String)

  end

  it "can find one merchant based on search criteria" do
    merchant_1 = Merchant.create!(name: "walmart")
    merchant_2 = Merchant.create!(name: "walgreens")
    merchant_3 = Merchant.create!(name: "Malmart")
    merchant_4 = Merchant.create!(name: "K-Mart")
    merchant_5 = Merchant.create!(name: "Ballmart")
    merchant_6 = Merchant.create!(name: "Carmart")
    merchant_7 = Merchant.create!(name: "minimart")
    merchant_8 = Merchant.create!(name: "ezmart")
    
    
    get "/api/v1/merchants/find?name=mart"

    expect(response).to be_successful

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data).to be_a(Hash)
    expect(data[:data]).to be_a(Hash)
    expect(data[:data][:id]).to eq("#{merchant_5.id}")
    expect(data[:data][:attributes]).to be_a(Hash)
    expect(data[:data][:attributes][:name]).to eq("Ballmart")
  end

  describe 'sad paths' do
    it "will gracefully handle if a merchant id doesn't exist" do
      get "/api/v1/merchants/1"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=1")
    end

    it "will gracefully handle if there is no match for a merchant search" do
      get "/api/v1/merchants/find?name=NOMATCH"

      expect(response).to be_successful
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:data]).to be_a(Hash)
      expect(data[:data].count).to eq(2)
      expect(data[:data][:message]).to eq(nil)
      expect(data[:data][:status_code]).to eq(200)
    end
  end
end