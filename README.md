# gpccmp-inferno

An [Inferno](https://github.com/onc-healthit/inferno-framework) test kit for testing API interactions against the GP Chronic Condition Management Plan (GPCCMP) FHIR Implementation Guide.

## Purpose

Runs a suite of conformance tests against a FHIR server to check that it correctly implements the GPCCMP IG.

## Requirements

- Docker and Docker Compose
- Ruby 3.3.6 (only needed for local/non-Docker development)

## Run with Docker

```bash
make setup   # pull images, build, run db migrations
make run     # build and start all services
```

The Inferno web UI is then available at [http://localhost](http://localhost).

To use Aidbox instead of the default validator stack, add `MODE=aidbox` to each `make` command.

Other useful targets:

```bash
make tests   # run the test kit's own test suite
make stop    # stop services
make down    # stop and remove containers
```

## Usage

1. Open the Inferno web UI.
2. Select the GPCCMP test suite.
3. Enter your FHIR server's base URL and any required credentials.
4. Run the suite and review pass/fail results per test.

## References

- [Inferno Framework](https://github.com/onc-healthit/inferno-framework)
- [GPCCMP FHIR Implementation Guide Sources](https://github.com/aehrc/gpccmp-fhir-ig)
