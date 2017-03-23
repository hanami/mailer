RSpec.describe Hanami::Mailer::VERSION do
  it "returns current version" do
    expect(Hanami::Mailer::VERSION).to eq("1.0.0.beta2")
  end
end
