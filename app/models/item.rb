class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, :description, :unit_price, :merchant_id, presence: true
  # validates :name, presence: true, uniqueness: {case_sensitive: false}
  validate :valid_merchant

  private 

  def valid_merchant
    Merchant.find(merchant_id).valid?
  end
end
