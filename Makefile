# STACK picks the compose stack: default | aidbox
# RUNNER picks where Ruby commands run: docker (the inferno container) | local (host Ruby)
STACK ?= default
RUNNER ?= docker

ifneq ($(origin MODE), undefined)
$(error MODE was split in two: use STACK=aidbox for the Aidbox stack, RUNNER=local for local Ruby)
endif

ifeq ($(STACK), default)
compose = docker compose
else ifeq ($(STACK), aidbox)
compose = docker compose -f compose.yaml -f compose.aidbox.yaml
else
$(error Unknown STACK "$(STACK)": use default or aidbox)
endif

# ruby runs a Ruby command; ruby_db runs one that needs the database.
ifeq ($(RUNNER), docker)
# A one-off inferno container: removed afterwards, and running as the calling user so
# the files it writes into the checkout are not owned by root. HOME must be writable.
docker_run = $(compose) run --rm --user $$(id -u):$$(id -g) -e HOME=/tmp
# Lint, specs and generation need no other service, so none is started.
ruby = $(docker_run) --no-deps inferno
ruby_db = $(docker_run) inferno
else ifeq ($(RUNNER), local)
ruby =
ruby_db =
else
$(error Unknown RUNNER "$(RUNNER)": use docker or local)
endif

generated_dir = lib/gpccmp_test_kit/generated/
IG_REF ?=

.PHONY: setup run stop down reset tests rubocop rubocop-fix generate regenerate clean_generated

# Pull images, build, and migrate the database.
setup:
	$(compose) pull
	$(compose) build
	$(ruby_db) bundle exec rake db:migrate

# Build and start all services.
run:
	$(compose) build
	$(compose) up

stop:
	$(compose) stop

down:
	$(compose) down

# Start from zero: removes the containers AND their volumes (database, redis), then sets up and runs.
reset:
	$(compose) down --volumes
	$(MAKE) setup
	$(MAKE) run

tests:
	$(ruby) env APP_ENV=test bundle exec rspec

rubocop:
	$(ruby) bundle exec rubocop

rubocop-fix:
	$(ruby) bundle exec rubocop -A

# Generate the suite from the IG archive config.json points at, and autocorrect it.
generate:
	$(ruby) bundle exec rake gpccmp_test_kit:generate

# Rebuild the IG from the submodule and regenerate the suite; see bin/regenerate.sh.
regenerate:
	IG_REF=$(IG_REF) RUBY_PREFIX="$(ruby)" ./bin/regenerate.sh

# Discard the generated suite and restore it from git.
clean_generated:
	rm -rf $(generated_dir)
	git checkout $(generated_dir)
