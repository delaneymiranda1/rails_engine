require "rails_helper"

RSpec.describe Transaction, type: :model do
  describe "associations" do
    it { should belong_to(:invoice) }
  end
end
