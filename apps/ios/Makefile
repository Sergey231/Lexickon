PROJECT := Lexickon.xcodeproj
SCHEME := Lexickon
CONFIGURATION ?= Debug
SIMULATOR ?= iPhone 17 Pro
TEST_DESTINATION ?= platform=iOS Simulator,name=$(SIMULATOR),OS=latest

.PHONY: help build run test lint check

help:
	@echo "Available commands:"
	@echo "  make build                    Build for the iOS Simulator"
	@echo "  make run                      Build and launch on $(SIMULATOR)"
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

run: build
	@set -e; \
	device_id="$$(xcrun simctl list devices available | awk -v name="$(SIMULATOR)" '{ \
		line = $$0; \
		sub(/^[[:space:]]+/, "", line); \
		if (index(line, name " (") == 1) { \
			line = substr(line, length(name) + 3); \
			sub(/\).*/, "", line); \
			print line; \
			exit; \
		} \
	}')"; \
	if [ -z "$$device_id" ]; then \
		echo "Simulator '$(SIMULATOR)' was not found"; \
		exit 1; \
	fi; \
	if ! xcrun simctl list devices booted | grep -q "$$device_id"; then \
		xcrun simctl boot "$$device_id"; \
	fi; \
	open -a Simulator; \
	xcrun simctl bootstatus "$$device_id" -b; \
	build_settings="$$(xcodebuild \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-configuration "$(CONFIGURATION)" \
		-destination "$(TEST_DESTINATION)" \
		-showBuildSettings)"; \
	target_build_dir="$$(printf '%s\n' "$$build_settings" | awk -F ' = ' '/ TARGET_BUILD_DIR = / { print $$2; exit }')"; \
	wrapper_name="$$(printf '%s\n' "$$build_settings" | awk -F ' = ' '/ WRAPPER_NAME = / { print $$2; exit }')"; \
	bundle_id="$$(printf '%s\n' "$$build_settings" | awk -F ' = ' '/ PRODUCT_BUNDLE_IDENTIFIER = / { print $$2; exit }')"; \
	app_path="$$target_build_dir/$$wrapper_name"; \
	if [ ! -d "$$app_path" ]; then \
		echo "Built application was not found at $$app_path"; \
		exit 1; \
	fi; \
	xcrun simctl install "$$device_id" "$$app_path"; \
	xcrun simctl launch --terminate-running-process "$$device_id" "$$bundle_id"

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
