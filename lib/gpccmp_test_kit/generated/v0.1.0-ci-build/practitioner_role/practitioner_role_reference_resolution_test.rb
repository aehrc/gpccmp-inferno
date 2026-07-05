# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/reference_resolution_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class PractitionerRoleReferenceResolutionTest < Inferno::Test
      include InfernoSuiteGenerator::ReferenceResolutionTest

      title 'MustSupport references within PractitionerRole resources are valid'
      description %(
        This test will attempt to read external references provided within elements
        marked as 'MustSupport', if any are available.

        It verifies that at least one external reference for each MustSupport Reference element
        can be accessed by the test client, and conforms to corresponding GPCCMP profile.

        Elements which may provide external references include:

        * PractitionerRole.location
        * PractitionerRole.organization
        * PractitionerRole.practitioner
      )

      id :gpccmp_v010_ci_build_practitioner_role_reference_resolution_test

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
        perform_reference_resolution_test(scratch_resources[:all], {})
      end
    end
  end
end
