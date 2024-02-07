class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, :description, :unit_price, :merchant_id, presence: true

  validate :valid_merchant

  private 

  def valid_merchant
    Merchant.find(merchant_id).valid?
  end
end
