# frozen_string_literal: true

require 'inferno_suite_generator/test_modules/validation_test'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class AllergyIntoleranceValidationTest < Inferno::Test
      include InfernoSuiteGenerator::ValidationTest

      id :gpccmp_v010_ci_build_allergy_intolerance_validation_test
      title 'AllergyIntolerance resources returned during previous tests conform to the GP CCMP AllergyIntolerance'
      description %(
This test verifies resources returned from the first search conform to
the [GP CCMP AllergyIntolerance](https://gpccmp.csiro.au/ig/StructureDefinition/GPCCMPAllergyIntolerance).
If at least one resource from the first search is invalid, the test will fail.

It verifies the presence of mandatory elements and that elements with
required bindings contain appropriate values. CodeableConcept element
bindings will fail if none of their codings have a code/system belonging
to the bound ValueSet. Quantity, Coding, and code element bindings will
fail if their code/system are not found in the valueset.

      )
      output :dar_code_found, :dar_extension_found

      def resource_type
        'AllergyIntolerance'
      end

      def scratch_resources
        scratch[:allergy_intolerance_resources] ||= {}
      end

      def filter_set
        []
      end

      run do
        perform_validation_test(scratch_resources[:all] || [],
                                'https://gpccmp.csiro.au/ig/StructureDefinition/GPCCMPAllergyIntolerance',
                                '0.1.0',
                                skip_if_empty: true)
      end
    end
  end
end
