# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/read_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class PractitionerRoleReadTest < Inferno::Test
      include InfernoSuiteGenerator::ReadTest

      title '(SHALL) Server returns correct PractitionerRole resource from PractitionerRole read interaction'
      description 'A server SHALL support the PractitionerRole read interaction.'

      id :gpccmp_v010_ci_build_practitioner_role_read_test

      def self.demodata
        @demodata ||= InfernoSuiteGenerator::Generator::IGDemodata.new(
          YAML.load_file(File.join(File.dirname(__dir__), 'demodata.yml'), aliases: true)
        )
      end

      def resource_type
        'PractitionerRole'
      end

      def scratch_resources
        scratch[:practitioner_role_resources] ||= {}
      end

      run do
        perform_read_test(scratch.dig(:references, 'PractitionerRole'))
      end
    end
  end
end
