$LOAD_PATH.unshift "lib"
require "hanami/utils"
require "hanami/devtools/unit"
require "hanami/mailer"
require "pry"
require "pry-nav"


Hanami::Mailer.configure do
  root 'spec/support/fixtures/templates'
end

Hanami::Utils.require!("spec/support")
