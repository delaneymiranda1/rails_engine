require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "associations" do
    it { should have_many(:invoices)}
    it { should have_many(:items) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end
