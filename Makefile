PROJECT := Lexickon.xcodeproj
SCHEME := Lexickon
CONFIGURATION ?= Debug
SIMULATOR ?= iPhone 17 Pro
TEST_DESTINATION ?= platform=iOS Simulator,name=$(SIMULATOR),OS=latest

.PHONY: help build test lint check

help:
	@echo "Available commands:"
	@echo "  make build                    Build for the iOS Simulator"
	@echo "  make test                     Run tests on $(SIMULATOR)"
	@echo "  make lint                     Run SwiftLint"
	@echo "  make check                    Run lint and tests"
	@echo "  make test SIMULATOR='name'    Run tests on another simulator"

build:
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		-destination "generic/platform=iOS Simulator" \
		build

test:
	xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		-destination "$(TEST_DESTINATION)" \
		test

lint:
	swiftlint lint --no-cache Lexickon LexickonTests LexickonUITests

check: lint test
