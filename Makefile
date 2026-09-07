# ==============================================================================
# Flanki - Development & Build Automation Makefile
# ==============================================================================

FLUTTER ?= fvm flutter
DART    ?= fvm dart
CARGO   ?= cargo

.DEFAULT_GOAL := help
.PHONY: help setup get upgrade outdated codegen watch l10n gen native \
        format fmt analyze test check run run-windows run-macos run-linux run-android \
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

test: ## Run unit and widget tests
	$(FLUTTER) test

check: ## Verify format, analyze linter, and run tests (CI-ready)
	$(DART) format --output=none --set-exit-if-changed lib test
	$(FLUTTER) analyze
	$(FLUTTER) test

## ----------------------------------------------------------------------
## Run (Development)
## ----------------------------------------------------------------------

run: ## Run Flutter app with default device
	$(FLUTTER) run

run-windows: ## Run Flutter app on Windows desktop
	$(FLUTTER) run -d windows

run-macos: ## Run Flutter app on macOS desktop
	$(FLUTTER) run -d macos

run-linux: ## Run Flutter app on Linux desktop
	$(FLUTTER) run -d linux

run-android: ## Run Flutter app on Android device/emulator
	$(FLUTTER) run -d android

## ----------------------------------------------------------------------
## Build (Release)
## ----------------------------------------------------------------------

build-windows: ## Build Windows release executable
	$(FLUTTER) build windows --release

build-macos: ## Build macOS release app bundle
	$(FLUTTER) build macos --release

build-linux: ## Build Linux release executable
	$(FLUTTER) build linux --release

build-apk: ## Build Android release APK
	$(FLUTTER) build apk --release

build-appbundle: ## Build Android release App Bundle (.aab)
	$(FLUTTER) build appbundle --release

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

