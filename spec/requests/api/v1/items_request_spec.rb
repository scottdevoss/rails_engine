require "rails_helper"

describe "Items API" do
  it "sends a list of merchants" do
    create_list(:item, 10)

    get '/api/v1/items'
    
    expect(response).to be_successful
    
    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(10)
    
    items[:data].each do |item|
      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_an(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_an(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_an(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_an(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  it "can return one item" do

    id = create(:item).id

    get "/api/v1/items/#{id}"
    
    expect(response).to be_successful
    
    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data].count).to eq(3)

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_an(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_an(String)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_an(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_an(Float)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to be_an(Integer)
  end

  describe 'sad paths' do
    it "will gracefully handle if a book id doesn't exist" do
      get "/api/v1/items/1"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=1")
    end
  end

end