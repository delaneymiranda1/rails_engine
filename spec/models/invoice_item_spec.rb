require "rails_helper"

RSpec.describe InvoiceItem, type: :model do
  describe "associations" do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
  end

  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
  end
end
