# ==============================================================================
# Flanki - Development & Build Automation Makefile
# ==============================================================================

FLUTTER ?= fvm flutter
DART    ?= fvm dart
CARGO   ?= cargo

# Environment-specific configuration:
# Defaults to .env.dev for local run/test, and .env.prod for release/build targets.
ENV_DEV_FILE  := $(wildcard .env.dev)
ENV_PROD_FILE := $(wildcard .env.prod)
ENV_FILE      ?= $(if $(filter build-% release,$(MAKECMDGOALS)),$(if $(ENV_PROD_FILE),.env.prod,.env),$(if $(ENV_DEV_FILE),.env.dev,.env))
ENV_ARGS      ?= --dart-define-from-file=$(ENV_FILE)

.DEFAULT_GOAL := help
.PHONY: help setup get upgrade outdated codegen watch l10n gen native \
        format fmt analyze lint-dimensions test check run run-windows run-macos run-linux run-android \
        build-windows build-macos build-linux build-apk build-appbundle clean clean-all release

## ----------------------------------------------------------------------
## Help
## ----------------------------------------------------------------------

help: ## Show available make targets and descriptions
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## ----------------------------------------------------------------------
## Setup & Dependencies
## ----------------------------------------------------------------------

setup: ## Install pinned Flutter SDK (FVM) and dependencies
	fvm install
	$(FLUTTER) pub get

get: ## Download Flutter dependencies
	$(FLUTTER) pub get

upgrade: ## Upgrade dependencies
	$(FLUTTER) pub upgrade

outdated: ## Check outdated dependencies
	$(FLUTTER) pub outdated

## ----------------------------------------------------------------------
## Code Generation & Native
## ----------------------------------------------------------------------

codegen: ## Run build_runner (Drift SQLite schema / models)
	$(DART) run build_runner build --delete-conflicting-outputs

watch: ## Watch and re-run build_runner on changes
	$(DART) run build_runner watch --delete-conflicting-outputs

l10n: ## Generate localization files from ARB
	$(FLUTTER) gen-l10n

gen: codegen l10n ## Run all code generators (build_runner + l10n)

native: ## Build Rust bridge library (anki-bridge-rs)
	$(CARGO) build --release --manifest-path native/anki-bridge-rs/Cargo.toml

## ----------------------------------------------------------------------
## Code Quality & Testing
## ----------------------------------------------------------------------

format: fmt ## Alias for fmt
fmt: ## Format Dart code in lib/ and test/
	$(DART) format lib test

analyze: ## Run Flutter analyzer / linter
	$(FLUTTER) analyze

lint-dimensions: ## Check for dimension magic numbers (AppTokens guardrail)
	$(DART) run tool/check_dimensions.dart

test: ## Run unit and widget tests
	$(FLUTTER) test

check: ## Verify format, analyze linter, dimension guardrail, and run tests (CI-ready)
	$(DART) format --output=none --set-exit-if-changed lib test
	$(DART) run tool/check_dimensions.dart
	$(FLUTTER) analyze
	$(FLUTTER) test

## ----------------------------------------------------------------------
## Run (Development)
## ----------------------------------------------------------------------

run: ## Run Flutter app with default device
	$(FLUTTER) run $(ENV_ARGS)

run-windows: ## Run Flutter app on Windows desktop
	$(FLUTTER) run -d windows $(ENV_ARGS)

run-macos: ## Run Flutter app on macOS desktop
	$(FLUTTER) run -d macos $(ENV_ARGS)

run-linux: ## Run Flutter app on Linux desktop
	$(FLUTTER) run -d linux $(ENV_ARGS)

run-android: ## Run Flutter app on Android device/emulator
	$(FLUTTER) run -d android $(ENV_ARGS)

## ----------------------------------------------------------------------
## Build (Release)
## ----------------------------------------------------------------------

build-windows: ## Build Windows release executable
	$(FLUTTER) build windows --release $(ENV_ARGS)

build-macos: ## Build macOS release app bundle
	$(FLUTTER) build macos --release $(ENV_ARGS)

build-linux: ## Build Linux release executable
	$(FLUTTER) build linux --release $(ENV_ARGS)

build-apk: ## Build Android release APK
	$(FLUTTER) build apk --release $(ENV_ARGS)

build-appbundle: ## Build Android release App Bundle (.aab)
	$(FLUTTER) build appbundle --release $(ENV_ARGS)

## ----------------------------------------------------------------------
## Clean
## ----------------------------------------------------------------------

clean: ## Clean Flutter build cache
	$(FLUTTER) clean

clean-all: clean ## Clean Flutter build cache, .dart_tool, and build output
	rm -rf .dart_tool build

## ----------------------------------------------------------------------
## Release Automation
## ----------------------------------------------------------------------

release: ## Auto bump version, test, tag and push (e.g. make release [v=1.0.3] [ARGS=--push])
	$(DART) run tool/release.dart $(v) $(ARGS)

release-push: ## Retry pushing release commits and tags to origin
	git push origin HEAD
	git push origin --tags

qr: ## Show download link and open QR code image for latest APK
	@echo "Direct APK Download: https://github.com/zoroneo/flanki/releases/latest/download/flanki-android.apk"
	@echo "QR Image: packaging/qr_android_apk.png"

