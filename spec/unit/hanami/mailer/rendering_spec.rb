RSpec.describe Hanami::Mailer do
  describe "#render" do
    describe "when template is explicitly declared" do
      let(:mailer) { InvoiceMailer.new }

      it "renders the given template" do
        expect(mailer.render(:html)).to include(%(<h1>Invoice template</h1>))
      end
    end

    describe "when template is implicitly declared" do
      let(:mailer) { LazyMailer.new }

      it "looks for template with same name with inflected classname and render it" do
        expect(mailer.render(:html)).to include(%(Hello World))
        expect(mailer.render(:txt)).to include(%(This is a txt template))
      end
    end

    describe "when mailer defines context" do
      let(:mailer) { WelcomeMailer.new }

      it "renders template with defined context" do
        expect(mailer.render(:txt)).to include(%(Ahoy))
      end
    end

    describe "when locals are parsed in" do
      let(:mailer) { RenderMailer.new(user: User.new("Luca")) }

      it "renders template with parsed locals" do
        expect(mailer.render(:html)).to include(%(Luca))
      end
    end

    describe "with HAML template engine" do
      let(:mailer) { TemplateEngineMailer.new(user: User.new("Luca")) }

      it "renders template with parsed locals" do
        expect(mailer.render(:html)).to include(%(<h1>\nLuca\n</h1>\n))
      end
    end
  end
end
