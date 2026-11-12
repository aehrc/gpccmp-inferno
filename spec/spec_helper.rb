# frozen_string_literal: true

ENV['APP_ENV'] ||= 'test'

require 'inferno/config/application'
require 'inferno/utils/migration'
Inferno::Utils::Migration.new.run

require 'inferno'
Inferno::Application.finalize!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
