require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "associations" do
    it { should have_many :invoices }

  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  it "can have a full name" do
    customer = create(:customer)

    expect(customer.first_name).to be_a String
    expect(customer.last_name).to be_a String 
  end
end
