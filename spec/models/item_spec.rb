require "rails_helper"

RSpec.describe Item, type: :model do
  describe "associations" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
  end

  it "destroys an invoice item if the last item is destroyed" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)
    customer = create(:customer)
    invoice = Invoice.create!(customer: customer, merchant: merchant, status: "shipped")
    invoice_item1 = InvoiceItem.create!(invoice: invoice, item: item, quantity: 1, unit_price: item.unit_price)

    item_id = item.id
    invoice_id = invoice.id

    expect(InvoiceItem.where(item_id: item_id)).to exist

    item.destroy!

    expect { Item.find(item_id) }.to raise_exception(ActiveRecord::RecordNotFound)
    expect(InvoiceItem.where(item_id: item_id)).not_to exist
  end
end
