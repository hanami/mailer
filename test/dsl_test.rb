require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe '.template' do
    describe 'when no value is set' do
      it 'returns the convention name' do
        RenderMailer.template.must_equal 'render_mailer'
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
        template_formats.must_equal [:html, :txt]
      end

      it 'returns only the template for the given format' do
        template = LazyMailer.templates(:txt)
        template.must_be_kind_of(Lotus::Mailer::Template)
        template.file.must_match %r{test/fixtures/templates/lazy_mailer.txt.erb\z}
      end

      it "raises an error if the given format isn't associated with any template" do
        exception = -> { LazyMailer.templates(:rtf) }.must_raise Lotus::Mailer::MissingTemplateError
        exception.message.must_equal "Can't find template 'lazy_mailer' for 'rtf' format."
      end
    end

    describe 'when a value is set' do
      it 'returns a set of templates' do
        template_formats = InvoiceMailer.templates.keys
        template_formats.must_equal [:html]
      end

      it 'returns only the template for the given format' do
        template = InvoiceMailer.templates(:html)
        template.must_be_kind_of(Lotus::Mailer::Template)
        template.file.must_match %r{test/fixtures/templates/invoice.html.erb\z}
      end

      it "raises an error if the given format isn't associated with any template" do
        exception = -> { InvoiceMailer.templates(:txt) }.must_raise Lotus::Mailer::MissingTemplateError
        exception.message.must_equal "Can't find template 'invoice' for 'txt' format."
      end
    end
  end

  describe '.attach' do
    describe 'when given a string with the path' do
      it 'adds the attachment to the mail object' do
        LazyMailer.attach 'path/to/file/attachment1.pdf'
        LazyMailer.attachments['attachment1.pdf'].must_equal 'path/to/file/attachment1.pdf'
      end
    end
    describe 'when given an array of strings with the paths' do
      it 'adds the attachments to the mail object' do
        LazyMailer.attach ['path/to/file/attachment2.pdf', 'path/to/file/attachment3.pdf']
        LazyMailer.attachments['attachment2.pdf'].must_equal 'path/to/file/attachment2.pdf'
        LazyMailer.attachments['attachment3.pdf'].must_equal 'path/to/file/attachment3.pdf'
      end
    end
  end

end
