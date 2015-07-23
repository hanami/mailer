require 'test_helper'

describe Lotus::Mailer::VERSION do
  it 'exposes version' do
    Lotus::Mailer::VERSION.must_equal '0.1.0'
  end
end
