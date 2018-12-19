RSpec.describe Hanami::Mailer do
  describe '#render' do
    describe 'when template is explicitly declared' do
      let(:mailer) { InvoiceMailer.new }

      it 'renders the given template' do
        expect(mailer.render(:html)).to include(%(<h1>Invoice template</h1>))
        expect(mailer.render(:html)).to include(%(This is a html layout))
      end
    end

    describe 'when template is implicitly declared' do
      let(:mailer) { LazyMailer.new }

      it 'looks for template with same name with inflected classname and render it' do
        expect(mailer.render(:html)).to include(%(Hello World))
        expect(mailer.render(:txt)).to include(%(This is a txt template))
        expect(mailer.render(:txt)).to include(%(This is a txt layout))
      end
    end

    describe 'when mailer defines context' do
      let(:mailer) { WelcomeMailer.new }

      it 'renders template with defined context' do
        expect(mailer.render(:txt)).to include(%(Ahoy))
        expect(mailer.render(:txt)).to include(%(This is a txt layout))
      end
    end

    describe 'when locals are parsed in' do
      let(:mailer) { RenderMailer.new(user: User.new('Luca')) }

      it 'renders template with parsed locals' do
        expect(mailer.render(:html)).to include(%(Luca))
        expect(mailer.render(:html)).to include(%(This is a html layout))
      end
    end

    describe 'when layout is explicitly declared' do
      let(:mailer) { WithLayoutMailer.new }
      let(:rendered) { mailer.render(:html) }

      it 'renders template with parsed locals' do
        expect(rendered).to include(%(This mailer with layout))
        expect(rendered).to include(%(This is a custom html layout))
      end
    end

    describe 'when layout not exist' do
      let(:mailer) { NotExistLayoutMailer.new }

      it 'return layout name' do
        expect(mailer.render(:html).strip).to eq('<p>Layout not exist</p>')
      end
    end

    describe 'with HAML template engine' do
      let(:mailer) { TemplateEngineMailer.new(user: User.new('Luca')) }

      it 'renders template with parsed locals' do
        expect(mailer.render(:html)).to include(%(<h1>\nLuca\n</h1>\n))
        expect(mailer.render(:html)).to include(%(This is a html layout))
      end
    end
  end
end
