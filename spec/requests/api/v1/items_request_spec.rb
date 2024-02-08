require "rails_helper"

describe "Items API" do
  it "sends a list of items" do
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
    expect(merchant_items[:data].count).to eq(10)

    merchant_items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

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

  describe 'sad paths' do
    it "will gracefully handle if a item id doesn't exist" do
      get "/api/v1/items/1"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Item with 'id'=1")
    end

    it "will gracefully handle if a merchant id doesn't exist" do
      item_params = ({
        name: "Treadmill",
        description: "Exercise on the spot!",
        unit_price: 1000.00,
        merchant_id: 1
      })

      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to_not be_successful
      expect(response.status).to eq(404)
      data = JSON.parse(response.body, symbolize_names: true)

      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("404")
      expect(data[:errors].first[:title]).to eq("Couldn't find Merchant with 'id'=1")
    end

    it "create will gracefully handle if all the attributes are not created" do
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
      expect(data[:errors].first[:title]).to eq("Validation failed: Description can't be blank")
    end

    it "sad path: can't have name and price in search" do
      merchant_1 = create(:merchant)
      merchant_2 = create(:merchant)
      item_1 = Item.create!(name: "small Table", description: "small little table", unit_price: 88.88, merchant_id: merchant_1.id)
      Item.create!(name: "large Table", description: "a large table", unit_price: 99.99, merchant_id: merchant_1.id)
      Item.create!(name: "medium Table", description: "medium sized table", unit_price: 23.50, merchant_id: merchant_1.id)
      Item.create!(name: "children's table", description: "children's table", unit_price: 75.99, merchant_id: merchant_1.id)
      Item.create!(name: "high top table", description: "tall table", unit_price: 2.00, merchant_id: merchant_2.id)
      Item.create!(name: "coffee table", description: "coffee table", unit_price: 0.99, merchant_id: merchant_2.id)
      Item.create!(name: "bouncy ball", description: "a small bouncy ball", unit_price: 13.25, merchant_id: merchant_2.id)
      Item.create!(name: "guitar tabulature", description: "guitar music book", unit_price: 55.49, merchant_id: merchant_1.id)
      Item.create!(name: "twenty can tabs", description: "a child's collection of can tabs", unit_price: 1000.99, merchant_id: merchant_1.id)
      Item.create!(name: "pogo stick", description: "a pogo stick", unit_price: 140.73, merchant_id: merchant_1.id)
  
      get "/api/v1/items/find_all?name=table&min_price=50"
      
      expect(response).to_not be_successful
  
      data = JSON.parse(response.body, symbolize_names: true)
  
      expect(data).to have_key(:errors)
      expect(data[:errors]).to be_an(Array)
  
      data[:errors].each do |data|
        expect(data).to have_key(:status)
        expect(data).to have_key(:title)
      end
    end
  end

  it "returns the merchant associated with an item" do
    id = create(:merchant).id
    id_2 = create(:merchant).id

    item_1 = create(:item, merchant_id: id)
    item_2 = create(:item, merchant_id: id_2)
    headers = {"CONTENT_TYPE" => "application/json"}

    get "/api/v1/items/#{item_1.id}/merchant"

  
    data = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful
    expect(data[:data][:id]).to eq("#{id}")
    expect(data[:data][:type]).to eq("merchant")
    expect(data[:data][:attributes][:name]).to be_a(String)
  end

  it "can find all items based on a search query" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    item_1 = Item.create!(name: "small Table", description: "small little table", unit_price: 88.88, merchant_id: merchant_1.id)
    Item.create!(name: "large Table", description: "a large table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "medium Table", description: "medium sized table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "children's table", description: "children's table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "high top table", description: "tall table", unit_price: 99.99, merchant_id: merchant_2.id)
    Item.create!(name: "coffee table", description: "coffee table", unit_price: 99.99, merchant_id: merchant_2.id)
    Item.create!(name: "bouncy ball", description: "a small bouncy ball", unit_price: 99.99, merchant_id: merchant_2.id)
    Item.create!(name: "guitar tabulature", description: "guitar music book", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "twenty can tabs", description: "a child's collection of can tabs", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "pogo stick", description: "a pogo stick", unit_price: 99.99, merchant_id: merchant_1.id)

    get "/api/v1/items/find_all?name=tab"

    expect(response).to be_successful

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data[:data]).to be_a(Array)
    expect(data[:data].count).to eq(8)

    expect(data[:data].first).to be_a(Hash)
    expect(data[:data].first[:id]).to eq("#{item_1.id}")
    expect(data[:data].first[:type]).to eq("item")
    expect(data[:data].first[:attributes]).to be_a(Hash)
    expect(data[:data].first[:attributes][:name]).to eq(item_1.name)
    expect(data[:data].first[:attributes][:description]).to eq(item_1.description)
    expect(data[:data].first[:attributes][:unit_price]).to eq(88.88)
    expect(data[:data].first[:attributes][:merchant_id]).to eq(item_1.merchant_id)
  end

  it "can find items based on min price" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    item_1 = Item.create!(name: "small Table", description: "small little table", unit_price: 88.88, merchant_id: merchant_1.id)
    Item.create!(name: "large Table", description: "a large table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "medium Table", description: "medium sized table", unit_price: 23.50, merchant_id: merchant_1.id)
    Item.create!(name: "children's table", description: "children's table", unit_price: 75.99, merchant_id: merchant_1.id)
    Item.create!(name: "high top table", description: "tall table", unit_price: 2.00, merchant_id: merchant_2.id)
    Item.create!(name: "coffee table", description: "coffee table", unit_price: 0.99, merchant_id: merchant_2.id)
    Item.create!(name: "bouncy ball", description: "a small bouncy ball", unit_price: 13.25, merchant_id: merchant_2.id)
    Item.create!(name: "guitar tabulature", description: "guitar music book", unit_price: 55.49, merchant_id: merchant_1.id)
    Item.create!(name: "twenty can tabs", description: "a child's collection of can tabs", unit_price: 1000.99, merchant_id: merchant_1.id)
    Item.create!(name: "pogo stick", description: "a pogo stick", unit_price: 140.73, merchant_id: merchant_1.id)

    get "/api/v1/items/find_all?min_price=50"

    expect(response).to be_successful
    
    data = JSON.parse(response.body, symbolize_names: true)
    
    expect(data).to be_a(Hash)
    expect(data[:data]).to be_a(Array)
    expect(data[:data].count).to eq(6)
    
    data[:data].each do |data|
      expect(data).to have_key(:id)
      expect(data).to have_key(:attributes)
      expect(data[:attributes]).to have_key(:name)
      expect(data[:attributes]).to have_key(:description)
      expect(data[:attributes]).to have_key(:unit_price)
      expect(data[:attributes]).to have_key(:merchant_id)
    end
    
  end

  it "Can have min and max price" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    item_1 = Item.create!(name: "small Table", description: "small little table", unit_price: 88.88, merchant_id: merchant_1.id)
    Item.create!(name: "large Table", description: "a large table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "medium Table", description: "medium sized table", unit_price: 23.50, merchant_id: merchant_1.id)
    Item.create!(name: "children's table", description: "children's table", unit_price: 75.99, merchant_id: merchant_1.id)
    Item.create!(name: "high top table", description: "tall table", unit_price: 2.00, merchant_id: merchant_2.id)
    Item.create!(name: "coffee table", description: "coffee table", unit_price: 0.99, merchant_id: merchant_2.id)
    Item.create!(name: "bouncy ball", description: "a small bouncy ball", unit_price: 13.25, merchant_id: merchant_2.id)
    Item.create!(name: "guitar tabulature", description: "guitar music book", unit_price: 55.49, merchant_id: merchant_1.id)
    Item.create!(name: "twenty can tabs", description: "a child's collection of can tabs", unit_price: 1000.99, merchant_id: merchant_1.id)
    Item.create!(name: "pogo stick", description: "a pogo stick", unit_price: 140.73, merchant_id: merchant_1.id)

    get "/api/v1/items/find_all?max_price=130&min_price=50"

    expect(response).to be_successful

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data).to be_a(Hash)
    expect(data[:data]).to be_a(Array)

    data[:data].each do |data|
      expect(data).to have_key(:id)
      expect(data).to have_key(:attributes)
      expect(data[:attributes]).to have_key(:name)
      expect(data[:attributes]).to have_key(:description)
      expect(data[:attributes]).to have_key(:unit_price)
      expect(data[:attributes]).to have_key(:merchant_id)
    end
  end 

  it "can find items based on max price" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    item_1 = Item.create!(name: "small Table", description: "small little table", unit_price: 88.88, merchant_id: merchant_1.id)
    Item.create!(name: "large Table", description: "a large table", unit_price: 99.99, merchant_id: merchant_1.id)
    Item.create!(name: "medium Table", description: "medium sized table", unit_price: 23.50, merchant_id: merchant_1.id)
    Item.create!(name: "children's table", description: "children's table", unit_price: 75.99, merchant_id: merchant_1.id)
    Item.create!(name: "high top table", description: "tall table", unit_price: 2.00, merchant_id: merchant_2.id)
    Item.create!(name: "coffee table", description: "coffee table", unit_price: 0.99, merchant_id: merchant_2.id)
    Item.create!(name: "bouncy ball", description: "a small bouncy ball", unit_price: 13.25, merchant_id: merchant_2.id)
    Item.create!(name: "guitar tabulature", description: "guitar music book", unit_price: 55.49, merchant_id: merchant_1.id)
    Item.create!(name: "twenty can tabs", description: "a child's collection of can tabs", unit_price: 1000.99, merchant_id: merchant_1.id)
    Item.create!(name: "pogo stick", description: "a pogo stick", unit_price: 140.73, merchant_id: merchant_1.id)

    get "/api/v1/items/find_all?max_price=150"

    expect(response).to be_successful

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data).to be_a(Hash)
    expect(data[:data]).to be_a(Array)
    
    data[:data].each do |data|
      expect(data).to have_key(:id)
      expect(data).to have_key(:attributes)
      expect(data[:attributes]).to have_key(:name)
      expect(data[:attributes]).to have_key(:description)
      expect(data[:attributes]).to have_key(:unit_price)
      expect(data[:attributes]).to have_key(:merchant_id)
    end
  end
end