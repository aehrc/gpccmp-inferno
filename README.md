# gpccmp-inferno

An [Inferno](https://github.com/onc-healthit/inferno-framework) test kit for testing API interactions against the GP Chronic Condition Management Plan (GPCCMP) FHIR Implementation Guide.

## Purpose

Runs a suite of conformance tests against a FHIR server to check that it correctly implements the GPCCMP IG.

## Hosted instance

A hosted instance of this test kit runs at **<https://inferno.smartforms.io>**, alongside the Smart Health Checks kit, served by the platform in [aehrc/smart-forms-inferno-platform](https://github.com/aehrc/smart-forms-inferno-platform). Test results there persist across deploys and restarts. The older `gpccmp-inferno-test.smartforms.io` address still resolves to the same instance.

**Pushing to `main` here does not deploy anything.** The platform consumes this repository as a gem pinned to a git ref, so a change reaches the hosted instance only when that ref is bumped in the platform's `Gemfile`. The EC2 VM that used to poll this repository every three minutes and rebuild itself was decommissioned on 2026-08-27.

The rest of this README covers running the kit locally.

## Requirements

- Docker and Docker Compose
- Ruby 3.3.6 (only needed for local/non-Docker development)

## Run with Docker

```bash
make setup   # pull images, build, run db migrations
make run     # build and start all services
```

The Inferno web UI is then available at [http://localhost](http://localhost).

To use Aidbox instead of the default validator stack, add `STACK=aidbox` to each `make` command. `compose.aidbox.yaml` is an override on top of `compose.yaml` and holds only the validator services.

Other targets:

```bash
make tests            # run the test kit's own test suite
make rubocop          # lint; make rubocop-fix autocorrects
make generate         # generate the suite from the IG archive config.json points at
make stop             # stop services
make down             # stop and remove containers
make reset            # remove containers AND volumes (database, redis), then setup and run
make clean_generated  # discard the generated suite and restore it from git
```

## Regenerate the suite

The IG sources are the `gpccmp-fhir-ig` submodule (`git submodule update --init`). The suite is generated from an IG archive built from that submodule:

```bash
make regenerate                 # rebuild the pinned IG commit and regenerate the suite
make regenerate IG_REF=master   # move the submodule to the latest IG master first
```

Add `RUNNER=local` to generate with local Ruby instead of Docker; the same flag works for `make tests`, `make rubocop` and `make generate`. The IG itself is always built in Docker. When the IG's version changes, the new version's archive and suite replace the old ones, and `config.json`, `lib/gpccmp_test_kit.rb` and the outer groups are updated to match.

The **Regenerate Suite** workflow runs `make regenerate IG_REF=master` from the Actions tab. If anything changed, it opens a pull request on branch `suite-for-<version>` for a new IG version, or `suite-changed-for-<version>-at-<datetime>` otherwise.

## Usage

1. Open the Inferno web UI.
2. Select the GPCCMP test suite.
3. Enter your FHIR server's base URL and any required credentials.
4. Run the suite and review pass/fail results per test.

## References

- [Inferno Framework](https://github.com/onc-healthit/inferno-framework)
- [GPCCMP FHIR Implementation Guide Sources](https://github.com/aehrc/gpccmp-fhir-ig)
