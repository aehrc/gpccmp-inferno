# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/read_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class MedicationReadTest < Inferno::Test
      include InfernoSuiteGenerator::ReadTest

      title '(SHALL) Server returns correct Medication resource from Medication read interaction'
      description 'A server SHALL support the Medication read interaction.'

      input :medication_ids,
            title: 'Medication IDs',
            description: 'Comma separated list of medication IDs that in sum contain all MUST SUPPORT elements',
            default: '4active-ingredients',
            optional: true

      id :gpccmp_v010_ci_build_medication_read_test

      def self.demodata
        @demodata ||= InfernoSuiteGenerator::Generator::IGDemodata.new(
          YAML.load_file(File.join(File.dirname(__dir__), 'demodata.yml'), aliases: true)
        )
      end

      def resource_type
        'Medication'
      end

      def scratch_resources
        scratch[:medication_resources] ||= {}
      end

      run do
        perform_read_test(scratch.dig(:references, 'Medication'))
      end
    end
  end
end
