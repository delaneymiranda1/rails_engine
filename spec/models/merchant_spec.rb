require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "associations" do
    it { should have_many(:invoices)}
    it { should have_many(:items) }
    # it { should have_many(transactions).through :invoices }
    # it { should have_many(invoice_items).through :invoices }
  end
end
