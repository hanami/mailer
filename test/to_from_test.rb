require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  before do
    Lotus::Mailer.reset!
  end
  
  describe '#from' do
    describe 'returns_from_address' do
      it 'returns_the_variable_content' do
        
      end
    end
    describe 'sets_the_correct_from_address_given_a_string' do
      it 'has_the_address_in_the_variable' do
        StringMailer.from.must_equal 'noreply@example.com'
      end
    end
    describe 'sets_the_correct_from_address_given_a_proc' do
      it 'has_the_address_in_the_variable' do
        ProcMailer.from.must_equal 'user_sender@example.com'
      end
    end
  end
  
  describe '#to' do
    describe 'returns_recipients' do
      it 'returns_the_variable_content' do
      end
    end
    describe 'sets_the_correct_recipients_given_a_string' do
      it 'has_the_recipients_in_the_variable' do
        StringMailer.to.must_equal 'noreply1@example.com'
      end
    end
    describe 'sets_the_correct_recipients_given_an_array' do
      it 'has_the_recipients_in_the_variable' do
        ArrayMailer.to.must_equal 'noreply1@example.com,noreply2@example.com'
      end
    end
    describe 'sets_the_correct_recipients_given_a_proc' do
      it 'has_the_recipients_in_the_variable' do
        ProcMailer.to.must_equal 'user_receiver@example.com'
      end
    end
  end
  
  describe '#subject' do
    describe 'returns_subject' do
      it 'returns_the_variable_content' do
      end
    end
    describe 'sets_the_correct_subject_given_a_string' do
      it 'has_the_subject_in_the_variable' do
        StringMailer.subject.must_equal 'This is the subject'
      end
    end
    describe 'sets_the_correct_subject_given_a_proc' do
      it 'has_the_subject_in_the_variable' do
        ProcMailer.subject.must_equal 'This is the subject'
      end
    end
  end
end
