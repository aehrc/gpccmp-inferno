# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/search_test'
require 'inferno_suite_generator/core/group_metadata'
require 'inferno_suite_generator/utils/helpers'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class PractitionerRoleIdSearchTest < Inferno::Test
      include InfernoSuiteGenerator::SearchTest

      title '(MAY) Server returns valid results for PractitionerRole search by _id'
      description %(
A server MAY support searching by
_id on the PractitionerRole resource. This test
will pass if resources are returned and match the search criteria. If
none are returned, the test is skipped.

Because this is the first search of the sequence, resources in the
response will be used for subsequent tests.

Additionally, this test will check that GET and POST search methods
return the same number of results. Search by POST is required by the
FHIR R4 specification, and these tests interpret search by GET as a
requirement of GPCCMP v0.1.0-ci-build.

[GPCCMP Server CapabilityStatement](https://gpccmp.csiro.au/ig/CapabilityStatement/csiro.fhir.au.gpccmp)

      )

      id :gpccmp_v010_ci_build_practitioner_role__id_search_test
      optional

      def self.demodata
        @demodata ||= InfernoSuiteGenerator::Generator::IGDemodata.new(
          YAML.load_file(File.join(File.dirname(__dir__), 'demodata.yml'), aliases: true)
        )
      end

      def self.properties
        @properties ||= InfernoSuiteGenerator::SearchTestProperties.new(
          first_search: true,
          resource_type: 'PractitionerRole',
          search_param_names: ['_id'],
          saves_delayed_references: true,
          test_post_search: true
        )
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

      def keep_all_search_results?
        false
      end

      run do
        run_search_test
      end
    end
  end
end
