SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace

DEFAULT_SIMULATOR := $(shell xcrun simctl list devices available | awk -F'[()]' '/^ *iPhone/ {gsub(/^ +| +$$/,"",$$1); print $$1; exit}')
SIMULATOR ?= $(DEFAULT_SIMULATOR)

ifdef SHARED_DIR
DERIVED_DATA := -derivedDataPath $(HOME)/Library/Developer/Xcode/DerivedData/$(SCHEME)-local-shared
endif

XCODEBUILD   := xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) $(DERIVED_DATA)
ON_SIMULATOR := -destination 'platform=iOS Simulator,name=$(SIMULATOR)' SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES

SWIFTFORMAT ?= mint run swiftformat
SWIFTLINT   ?= mint run swiftlint

.PHONY: bootstrap open verify lint format testplan build test build-test boot boot-wait clean

bootstrap:
	mint bootstrap
	git config core.hooksPath scripts/git-hooks

open:
	open $(WORKSPACE)

verify: lint testplan build-test

lint:
	$(SWIFTFORMAT) --lint .
	$(SWIFTLINT) lint --strict

format:
	$(SWIFTFORMAT) .
	$(SWIFTLINT) --fix

testplan:
	@sh scripts/check-testplan.sh

build:
	$(XCODEBUILD) build $(ON_SIMULATOR)

test:
	$(XCODEBUILD) test $(ON_SIMULATOR)

build-test:
	$(XCODEBUILD) build test $(ON_SIMULATOR)

boot:
	xcrun simctl boot '$(SIMULATOR)' || true

boot-wait:
	xcrun simctl bootstatus '$(SIMULATOR)' -b

clean:
	$(XCODEBUILD) clean
