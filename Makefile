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
compose = docker compose -f compose.aidbox.yaml
else
$(error Unknown STACK "$(STACK)": use default or aidbox)
endif

ifeq ($(RUNNER), docker)
ruby = $(compose) run inferno
else ifeq ($(RUNNER), local)
ruby =
else
$(error Unknown RUNNER "$(RUNNER)": use docker or local)
endif

rm_generated = rm -rf lib/gpccmp_test_kit/generated/
ber_generate = bundle exec rake gpccmp_test_kit:generate
lint_generated = bundle exec rubocop -A --fail-level E lib/gpccmp_test_kit/
IG_REF ?=

.PHONY: setup generate regenerate summary tests run pull build up stop down rubocop migrate clean_generated uploadfig_generate_local

setup: pull build migrate

generate:
	$(ruby) $(ber_generate)
	$(ruby) $(lint_generated)

regenerate:
	STACK=$(STACK) RUNNER=$(RUNNER) IG_REF=$(IG_REF) ./bin/regenerate.sh

tests:
	$(ruby) env APP_ENV=test bundle exec rspec

run: build up

pull:
	$(compose) pull

build:
	$(compose) build

up:
	$(compose) up

stop:
	$(compose) stop

down:
	$(compose) down

rubocop:
	$(ruby) bundle exec rubocop

rubocop-fix:
	$(ruby) bundle exec rubocop -A

migrate:
	$(ruby) bundle exec rake db:migrate

clean_generated:
	sudo $(rm_generated)
	git checkout lib/gpccmp_test_kit/generated/

start_from_zero: stop down setup run

full_develop_restart: stop down generate setup run
