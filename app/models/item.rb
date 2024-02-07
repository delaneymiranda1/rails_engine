class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true

  before_destroy :check_for_invoices

  private

  def check_for_invoices# not sure if still needed after adding controller private method, might be useful?
    invoices.each do |invoice|
      invoice.destroy if invoice.items.count == 1
    end
  end
end
