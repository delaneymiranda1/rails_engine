class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  validates :quantity, presence: true
  validates :unit_price, presence: true
end
