# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/must_support_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class LocationMustSupportTest < Inferno::Test
      include InfernoSuiteGenerator::MustSupportTest

      title 'All must support elements are provided in the Location resources returned'
      description %(
        GPCCMP Responders SHALL be capable of populating all data elements as
        part of the query results as specified by the GPCCMP Server Capability
        Statement. This test will look through the Location resources
        found previously for the following must support elements:

        * Location.address
        * Location.managingOrganization
        * Location.name
        * Location.physicalType
        * Location.type
      )

      id :gpccmp_v010_ci_build_location_must_support_test

      def resource_type
        'Location'
      end

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__,
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      def scratch_resources
        scratch[:location_resources] ||= {}
      end

      run do
        perform_must_support_test(all_scratch_resources)
      end
    end
  end
end
