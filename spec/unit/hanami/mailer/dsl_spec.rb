RSpec.describe Hanami::Mailer do
  describe '.template' do
    describe 'when no value is set' do
      it 'returns the convention name' do
        expect(RenderMailer.template).to eq('render_mailer')
      end

      it 'returns correct namespaced value' do
        expect(Users::Welcome.template).to eq('users/welcome')
      end
    end

    describe 'when a value is set' do
      it 'returns that name' do
        expect(InvoiceMailer.template).to eq('invoice')
      end
    end
  end

  describe '.templates' do
    describe 'when no value is set' do
      it 'returns a set of templates' do
        template_formats = LazyMailer.templates.keys
        expect(template_formats).to eq(%i(html txt))
      end

      it 'returns only the template for the given format' do
        template = LazyMailer.templates(:txt)
        expect(template).to be_kind_of(Hanami::Mailer::Template)
        expect(template.file).to match(%r{spec/support/fixtures/templates/lazy_mailer.txt.erb\z})
      end
    end

    describe 'when a value is set' do
      it 'returns a set of templates' do
        template_formats = InvoiceMailer.templates.keys
        expect(template_formats).to eq([:html])
      end

      it 'returns only the template for the given format' do
        template = InvoiceMailer.templates(:html)
        expect(template).to be_kind_of(Hanami::Mailer::Template)
        expect(template.file).to match(%r{spec/support/fixtures/templates/invoice.html.erb\z})
      end
    end
  end
end
