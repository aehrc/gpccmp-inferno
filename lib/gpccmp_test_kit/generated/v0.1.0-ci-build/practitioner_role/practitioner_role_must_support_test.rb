# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/must_support_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class PractitionerRoleMustSupportTest < Inferno::Test
      include InfernoSuiteGenerator::MustSupportTest

      title 'All must support elements are provided in the PractitionerRole resources returned'
      description %(
        GPCCMP Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the GPCCMP Server Capability
        Statement. This test will look through the PractitionerRole resources
        found previously for the following must support elements:

        * PractitionerRole.code
        * PractitionerRole.id
        * PractitionerRole.identifier
        * PractitionerRole.location
        * PractitionerRole.organization
        * PractitionerRole.practitioner
        * PractitionerRole.specialty
        * PractitionerRole.telecom
        * PractitionerRole.telecom.system
        * PractitionerRole.telecom.value
      )

      id :gpccmp_v010_ci_build_practitioner_role_must_support_test

      def resource_type
        'PractitionerRole'
      end

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__,
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      def scratch_resources
        scratch[:practitioner_role_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
