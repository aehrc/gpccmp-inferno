# frozen_string_literal: true

require 'base64'
require 'inferno/dsl/oauth_credentials'
require 'inferno_suite_generator/utils/helpers'
require_relative '../../version'

require_relative 'patient_group'
require_relative 'allergy_intolerance_group'
require_relative 'gpccmp_condition_group'
require_relative 'medication_statement_group'
require_relative 'gpccmp_body_height_group'
require_relative 'gpccmp_body_weight_group'
require_relative 'gpccmp_waist_circumference_group'
require_relative 'gpccmp_pulse_rate_group'
require_relative 'gpccmp_pulse_rhythm_group'
require_relative 'gpccmp_oxygen_saturation_group'
require_relative 'gpccmp_blood_pressure_group'
require_relative 'gpccmp_smoking_status_group'
require_relative 'gpccmp_alcohol_use_status_group'
require_relative 'questionnaire_response_group'
require_relative 'encounter_group'
require_relative 'location_group'
require_relative 'medication_group'
require_relative 'practitioner_group'
require_relative 'practitioner_role_group'

module GPCCMPTestKit
  module GPCCMPV010_CI_BUILD
    class GPCCMPTestSuite < Inferno::TestSuite
      title 'GPCCMP v0.1.0-ci-build'
      description %(
        The GPCCMP Test Kit tests systems for their conformance to the [GP CCMP](https://gpccmp.csiro.au/ig/ImplementationGuide/csiro.fhir.au.gpccmp).

        HL7® FHIR® resources are validated with the Java validator using
        https://tx.fhir.org/r4 as the terminology server.

        The test suite is generated using the [InfernoSuiteGenerator](https://github.com/hl7au/inferno_suite_generator) gem version 0.1.1.
      )
      version VERSION

      VERSION_SPECIFIC_MESSAGE_FILTERS = [].freeze

      def self.metadata
        @metadata ||= YAML.load_file(File.join(__dir__, 'metadata.yml'), aliases: true)[:groups].map do |raw_metadata|
          Generator::GroupMetadata.new(raw_metadata)
        end
      end

      fhir_resource_validator do
        igs '/home/igs/0.1.0-ci-build.tgz'
        message_filters = [
          "The value provided ('xml') was not found in the value set 'MimeType'",
          "The value provided ('json') was not found in the value set 'MimeType'",
          "The value provided ('ttl') was not found in the value set 'MimeType'"
        ] + VERSION_SPECIFIC_MESSAGE_FILTERS

        cli_context do
          txServer ENV.fetch('TX_SERVER_URL', 'https://tx.fhir.org/r4')
          disableDefaultResourceFetcher false
        end

        exclude_message do |message|
          Helpers.is_message_exist_in_list(message_filters, message.message)
        end

        perform_additional_validation do |resource, _profile_url|
          ProvenanceValidator.validate(resource) if resource.instance_of?(FHIR::Provenance)
        end
      end

      links [
        {
          label: 'Report Issue',
          url: 'https://github.com/aehrc/gpccmp-inferno/issues'
        },
        {
          label: 'Source Code',
          url: 'https://github.com/aehrc/gpccmp-inferno'
        },
        {
          label: 'Implementation Guide',
          url: 'https://gpccmp.csiro.au/ig/ImplementationGuide/csiro.fhir.au.gpccmp'
        }
      ]

      id :gpccmp_v010_ci_build

      input :url,
            title: 'FHIR Endpoint',
            description: 'URL of the FHIR endpoint',
            default: 'https://proxy.smartforms.io/fhir'
      input :smart_credentials,
            title: 'OAuth Credentials',
            type: :oauth_credentials,
            optional: true
      input :header_name,
            title: 'Header name',
            optional: true
      input :header_value,
            title: 'Header value',
            optional: true

      fhir_client do
        url :url
        oauth_credentials :smart_credentials
        headers Helpers.get_http_header(header_name, header_value)
      end

      group do
        title 'GPCCMP FHIR API'
        id :gpccmp_v010_ci_build_fhir_api

        group from: :gpccmp_v010_ci_build_patient

        group from: :gpccmp_v010_ci_build_allergy_intolerance

        group from: :gpccmp_v010_ci_build_gpccmp_condition

        group from: :gpccmp_v010_ci_build_medication_statement

        group from: :gpccmp_v010_ci_build_gpccmp_body_height

        group from: :gpccmp_v010_ci_build_gpccmp_body_weight

        group from: :gpccmp_v010_ci_build_gpccmp_waist_circumference

        group from: :gpccmp_v010_ci_build_gpccmp_pulse_rate

        group from: :gpccmp_v010_ci_build_gpccmp_pulse_rhythm

        group from: :gpccmp_v010_ci_build_gpccmp_oxygen_saturation

        group from: :gpccmp_v010_ci_build_gpccmp_blood_pressure

        group from: :gpccmp_v010_ci_build_gpccmp_smoking_status

        group from: :gpccmp_v010_ci_build_gpccmp_alcohol_use_status

        group from: :gpccmp_v010_ci_build_questionnaire_response

        group from: :gpccmp_v010_ci_build_encounter

        group from: :gpccmp_v010_ci_build_location

        group from: :gpccmp_v010_ci_build_medication

        group from: :gpccmp_v010_ci_build_practitioner

        group from: :gpccmp_v010_ci_build_practitioner_role
      end
    end
  end
end
