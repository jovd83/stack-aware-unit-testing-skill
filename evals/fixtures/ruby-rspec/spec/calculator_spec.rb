require_relative "../lib/calculator"

RSpec.describe Calculator do
  it "adds two numbers" do
    expect(described_class.new.add(2, 3)).to eq(5)
  end
end
