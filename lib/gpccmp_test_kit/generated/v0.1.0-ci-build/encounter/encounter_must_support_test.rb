# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/must_support_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class EncounterMustSupportTest < Inferno::Test
      include InfernoSuiteGenerator::MustSupportTest

      title 'All must support elements are provided in the Encounter resources returned'
      description %(
        GPCCMP Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the GPCCMP Server Capability
        Statement. This test will look through the Encounter resources
        found previously for the following must support elements:

        * Encounter.class
        * Encounter.id
        * Encounter.location
        * Encounter.location.location
        * Encounter.participant
        * Encounter.participant.individual
        * Encounter.participant.type
        * Encounter.period
        * Encounter.reasonCode
        * Encounter.reasonReference
        * Encounter.serviceProvider
        * Encounter.serviceType
        * Encounter.status
        * Encounter.subject
      )

      id :gpccmp_v010_ci_build_encounter_must_support_test

      def resource_type
        'Encounter'
      end

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__,
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      def scratch_resources
        scratch[:encounter_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
