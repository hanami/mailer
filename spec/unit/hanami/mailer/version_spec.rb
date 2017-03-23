# frozen_string_literal: true
RSpec.describe Hanami::Mailer::VERSION do
  it "returns current version" do
    expect(subject).to eq("1.0.0.beta2")
  end
end
