# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/search_test'
require 'inferno_suite_generator/core/group_metadata'
require 'inferno_suite_generator/utils/helpers'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class MedicationStatementStatusSearchTest < Inferno::Test
      include InfernoSuiteGenerator::SearchTest

      title '(MAY) Server returns valid results for MedicationStatement search by status'
      description %(
A server MAY support searching by
status on the MedicationStatement resource. This test
will pass if resources are returned and match the search criteria. If
none are returned, the test is skipped.

[GPCCMP Server CapabilityStatement](https://gpccmp.csiro.au/ig/CapabilityStatement/csiro.fhir.au.gpccmp)

      )

      id :gpccmp_v010_ci_build_medication_statement_status_search_test
      optional

      def self.demodata
        @demodata ||= InfernoSuiteGenerator::Generator::IGDemodata.new(
          YAML.load_file(File.join(File.dirname(__dir__), 'demodata.yml'), aliases: true)
        )
      end

      def self.properties
        @properties ||= InfernoSuiteGenerator::SearchTestProperties.new(
          resource_type: 'MedicationStatement',
          search_param_names: ['status']
        )
      end

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__,
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      def scratch_resources
        scratch[:medication_statement_resources] ||= {}
      end

      def keep_all_search_results?
        false
      end

      run do
        run_search_test
      end
    end
  end
end
