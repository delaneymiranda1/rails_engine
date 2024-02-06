class Invoice < ApplicationRecord
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  belongs_to :merchant
  belongs_to :customer

  validates :status, presence: true
end
