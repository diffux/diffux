require 'coveralls'
require 'nokogiri'
Coveralls.wear!('rails')

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'sidekiq/testing'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'diffux_core'

include ActionDispatch::TestProcess

Capybara.server_port = 12345
# Sets up phantomJS as the JS driver for integration testing
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: true, inspector: true)
end

Capybara.javascript_driver = :poltergeist

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Avoid warnings about locale when running specs
  I18n.enforce_available_locales = false

  config.mock_with :mocha

  config.include FactoryGirl::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # In RSpec 3, symbols passed as metadata arguments to configuration options
  # will be treated as metadata keys with a value of `true`. To get this
  # behavior now (and prevent a warning), we can set this configuration option.
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:each) do
    Phantomjs.stubs(:run).yields '{"title": "A title"}'  # Don't run PhantomJS
    Sidekiq::Testing.inline! # Run async worker jobs synchronous
  end

  # Tag "without_transactional_fixtures" helps when after_commit hook is expected
  # to fire in a spec. It would never fire because of having enabled
  # use_transactional_fixtures. It waits for transaction to end. The
  # workaround disables transaction-wrapping for the tagged spec and
  # instead uses a DatabaseCleaner strategy to wipe the tables here.
  # Also used in integrations specs that have JS enabled.
  config.around(:each, :without_transactional_fixtures) do |example|
    _orig_use_transactional_fixtures = use_transactional_fixtures
    self.use_transactional_fixtures = false
    DatabaseCleaner.clean_with(:truncation)
    example.call
    DatabaseCleaner.clean_with(:truncation)
    self.use_transactional_fixtures = _orig_use_transactional_fixtures
  end
end

