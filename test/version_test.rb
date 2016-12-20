require 'test_helper'

describe Hanami::Mailer::VERSION do
  it 'returns current version' do
    Hanami::Mailer::VERSION.must_equal '1.0.0.beta1'
  end
end
