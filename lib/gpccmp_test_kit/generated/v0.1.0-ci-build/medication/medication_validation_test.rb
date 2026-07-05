# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/validation_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class MedicationValidationTest < Inferno::Test
      include InfernoSuiteGenerator::ValidationTest

      id :gpccmp_v010_ci_build_medication_validation_test
      title 'Medication resources returned during previous tests conform to the GP CCMP Medication'
      description %(
This test verifies resources returned from previous tests conform to
the [GP CCMP Medication](https://gpccmp.csiro.au/ig/StructureDefinition/GPCCMPMedication).

It verifies the presence of mandatory elements and that elements with
required bindings contain appropriate values. CodeableConcept element
bindings will fail if none of their codings have a code/system belonging
to the bound ValueSet. Quantity, Coding, and code element bindings will
fail if their code/system are not found in the valueset.

      )
      output :dar_code_found, :dar_extension_found

      def resource_type
        'Medication'
      end

      def scratch_resources
        scratch[:medication_resources] ||= {}
      end

      def filter_set
        []
      end

      run do
        perform_validation_test(scratch_resources[:all] || [],
                                'https://gpccmp.csiro.au/ig/StructureDefinition/GPCCMPMedication',
                                '0.1.0',
                                skip_if_empty: false)
      end
    end
  end
end
