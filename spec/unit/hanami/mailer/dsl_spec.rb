RSpec.describe Hanami::Mailer do
  describe '.layout' do
    describe 'when no value is set' do
      it 'returns default layout' do
        expect(RenderMailer.layout).to eq(Hanami::Mailer::Dsl::DEFAULT_LAYOUT)
      end
    end

    describe 'when a value is set' do
      it 'returns that name' do
        expect(WithLayoutMailer.layout).to eq('custom_layout')
      end
    end
  end

  describe '.layouts' do
    describe 'when no value is set' do
      it 'returns a set of layouts' do
        layout_formats = RenderMailer.layouts.keys
        expect(layout_formats).to match_array(%i[html txt])
      end

      it 'returns only the layout for the given format' do
        layout = RenderMailer.layouts(:html)
        expect(layout).to be_kind_of(Hanami::Mailer::Layout)
        defult_layout_name = Hanami::Mailer::Dsl::DEFAULT_LAYOUT
        expect(layout.file).to match(
          %r{spec/support/fixtures/templates/layouts/#{defult_layout_name}.html.erb\z}
        )
      end
    end

    describe 'when a value is set' do
      it 'returns a set of layouts' do
        layout_formats = WithLayoutMailer.layouts.keys
        expect(layout_formats).to eq([:html])
      end

      it 'returns only the layout for the given format' do
        layout = WithLayoutMailer.layouts(:html)
        expect(layout).to be_kind_of(Hanami::Mailer::Layout)
        expect(layout.file).to match(
          %r{spec/support/fixtures/templates/layouts/custom_layout.html.erb\z}
        )
      end
    end
  end

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
        expect(template_formats).to match_array(%i[html txt])
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
