# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/read_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class LocationReadTest < Inferno::Test
      include InfernoSuiteGenerator::ReadTest

      title '(SHALL) Server returns correct Location resource from Location read interaction'
      description 'A server SHALL support the Location read interaction.'

      id :gpccmp_v010_ci_build_location_read_test

      def self.demodata
        @demodata ||= InfernoSuiteGenerator::Generator::IGDemodata.new(
          YAML.load_file(File.join(File.dirname(__dir__), 'demodata.yml'), aliases: true)
        )
      end

      def resource_type
        'Location'
      end

      def scratch_resources
        scratch[:location_resources] ||= {}
      end

      run do
        perform_read_test(scratch.dig(:references, 'Location'))
      end
    end
  end
end
