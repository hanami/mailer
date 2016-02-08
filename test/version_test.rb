require 'test_helper'

describe Hanami::Mailer::VERSION do
  it 'returns current version' do
    Hanami::Mailer::VERSION.must_equal '0.3.0'
  end
end
