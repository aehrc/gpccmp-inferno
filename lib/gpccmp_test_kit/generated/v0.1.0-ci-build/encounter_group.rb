# frozen_string_literal: true

require 'inferno_suite_generator/core/ig_demodata'
require_relative 'encounter/encounter_read_test'
require_relative 'encounter/encounter_validation_test'
require_relative 'encounter/encounter_must_support_test'
require_relative 'encounter/encounter_reference_resolution_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class EncounterGroup < Inferno::TestGroup
      title 'GP CCMP Encounter Tests'
      short_description 'Verify support for the server capabilities required by the GP CCMP Encounter.'
      description %(
  # Background

The GPCCMP GP CCMP Encounter sequence verifies that the system under test is
able to provide correct responses for Encounter queries. These queries
must contain resources conforming to the GP CCMP Encounter as
specified in the GPCCMP v0.1.0-ci-build Implementation Guide.

# Testing Methodology


## Must Support
Each profile contains elements marked as "must support". This test
sequence expects to see each of these elements at least once. If at
least one cannot be found, the test will fail. The test will look
through the Encounter resources found in the first test for these
elements.

## Profile Validation
Each resource returned from the first search is expected to conform to
the [GP CCMP Encounter](https://gpccmp.csiro.au/ig/StructureDefinition/GPCCMPEncounter). Each element is checked against
teminology binding and cardinality requirements.

Elements with a required binding are validated against their bound
ValueSet. If the code/system in the element is not part of the ValueSet,
then the test will fail.

## Reference Validation
At least one instance of each external reference in elements marked as
"must support" within the resources provided by the system must resolve.
The test will attempt to read each reference found and will fail if no
read succeeds.

      )

      id :gpccmp_v010_ci_build_encounter
      run_as_group

      def self.metadata
        @metadata ||= InfernoSuiteGenerator::Generator::GroupMetadata.new(YAML.load_file(
                                                                            File.join(__dir__, 'encounter',
                                                                                      'metadata.yml'), aliases: true
                                                                          ))
      end

      test from: :gpccmp_v010_ci_build_encounter_read_test
      test from: :gpccmp_v010_ci_build_encounter_validation_test
      test from: :gpccmp_v010_ci_build_encounter_must_support_test
      test from: :gpccmp_v010_ci_build_encounter_reference_resolution_test
    end
  end
end
