require 'test_helper'

describe Lotus::Mailer do
   before do
     Lotus::Mailer.load!
   end
  
   after do
     Lotus::Mailer.reset!
   end

  describe '#render' do
    describe 'when template is explicitly declared' do
      let(:mailer) { InvoiceMailer.new }

      it 'renders the given template' do
        mailer.render(:html).must_include %(<h1>Invoice template</h1>)
      end
    end

    describe 'when template is implicitly declared' do
      let(:mailer) { LazyMailer.new }

      it 'looks for template with same name with inflected classname and render it' do
        mailer.render(:html).must_include %(Hello World)
        mailer.render(:haml).must_include %(This is a haml template)
        mailer.render(:txt).must_include %(This is a txt template)
      end
    end

    describe 'when mailer defines context' do
      let(:mailer) { WelcomeMailer.new }

      it 'renders template with defined context' do
        mailer.render(:txt).must_include %(Ahoy)
      end
    end

    describe 'when locals are parsed in' do
      let(:mailer) { RenderMailer.new(user: User.new('Luca')) }

      it 'renders template with parsed locals' do
        mailer.render(:html).must_include %(Luca)
      end
    end
  end
end
