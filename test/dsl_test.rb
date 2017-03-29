require 'test_helper'

describe Hanami::Mailer do
  describe '.template' do
    describe 'when no value is set' do
      it 'returns the convention name' do
        RenderMailer.template.must_equal 'render_mailer'
      end

      it 'returns correct namespaced value' do
        Users::Welcome.template.must_equal 'users/welcome'
      end
    end

    describe 'when a value is set' do
      it 'returns that name' do
        InvoiceMailer.template.must_equal 'invoice'
      end
    end
  end

  describe '.templates' do
    describe 'when no value is set' do
      it 'returns a set of templates' do
        template_formats = LazyMailer.templates.keys
        template_formats.must_equal %i(html txt)
      end

      it 'returns only the template for the given format' do
        template = LazyMailer.templates(:txt)
        template.must_be_kind_of(Hanami::Mailer::Template)
        template.file.must_match %r{test/fixtures/templates/lazy_mailer.txt.erb\z}
      end
    end

    describe 'when a value is set' do
      it 'returns a set of templates' do
        template_formats = InvoiceMailer.templates.keys
        template_formats.must_equal [:html]
      end

      it 'returns only the template for the given format' do
        template = InvoiceMailer.templates(:html)
        template.must_be_kind_of(Hanami::Mailer::Template)
        template.file.must_match %r{test/fixtures/templates/invoice.html.erb\z}
      end
    end
  end
end
