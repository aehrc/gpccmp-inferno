# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/must_support_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class GpccmpConditionMustSupportTest < Inferno::Test
      include InfernoSuiteGenerator::MustSupportTest

      title 'All must support elements are provided in the Condition resources returned'
      description %(
        GPCCMP Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the GPCCMP Server Capability
        Statement. This test will look through the Condition resources
        found previously for the following must support elements:

        * Condition.abatement[x]
        * Condition.abatement[x]:abatementDateTime
        * Condition.category
        * Condition.category:problemListCategory
        * Condition.clinicalStatus
        * Condition.code
        * Condition.note
        * Condition.onsetDateTime
        * Condition.onset[x]:onsetDateTime
        * Condition.severity
        * Condition.subject
        * Condition.verificationStatus
      )

      id :gpccmp_v010_ci_build_gpccmp_condition_must_support_test

      def resource_type
        'Condition'
      end

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__,
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      def scratch_resources
        scratch[:gpccmp_condition_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
