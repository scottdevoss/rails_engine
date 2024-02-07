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

  it "can create a new item" do
    id = create(:merchant).id

    item_params = ({
      name: "Treadmill",
      description: "Exercise on the spot!",
      unit_price: 1000.00,
      merchant_id: id
    })

    headers = {"CONTENT_TYPE" => "application/json"}
      
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    created_item = Item.last
      
    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can update a new item" do
    id = create(:merchant).id
    item_params = ({
      name: "Treadmill",
      description: "Exercise on the spot!",
      unit_price: 1000.00,
      merchant_id: id
    })
    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    item_id = Item.last.id

    item_params_new = ({
      name: "Peloton"
    })

    patch "/api/v1/items/#{item_id}", headers: headers, params: JSON.generate({item: item_params_new})
    item = Item.find_by(id: item_id)

    expect(response).to be_successful
    expect(item.name).to eq("Peloton")
    expect(item.name).to_not eq("Treadmill")
  end

  it "can destroy an item" do
    item = create(:item)
   
    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "returns all items associated with a merchant" do
    merchant = create(:merchant)
    items = create_list(:item, 10)

    merchant.items << items
    
    get "/api/v1/merchants/#{merchant.id}/items"
    
    merchant_items = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to be_successful
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

    xit "create will gracefully handle if all the attributes are not created" do
      id = create(:merchant).id

      item_params = ({
                    name: "Treadmill",
                    unit_price: 1000.00,
                    merchant_id: id
                  })

      headers = {"CONTENT_TYPE" => "application/json"}
        
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to_not be_successful
      expect(response.status).to eq(400)

      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("400")
      expect(data[:errors].first[:title]).to eq("Validation Failed")
    end
  end

end