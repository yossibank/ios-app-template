SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
DEFAULT_SIMULATOR := $(shell xcrun simctl list devices available | awk -F'[()]' '/^ *iPhone/ {gsub(/^ +| +$$/,"",$$1); print $$1; exit}')
SIMULATOR ?= $(DEFAULT_SIMULATOR)
DEST      := platform=iOS Simulator,name=$(SIMULATOR)
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO

SWIFTFORMAT ?= mint run swiftformat
SWIFTLINT   ?= mint run swiftlint

.PHONY: open verify bootstrap lint format test build build-test clean boot boot-wait

open:
	open $(WORKSPACE)

verify: lint build-test

bootstrap:
	mint bootstrap

lint:
	$(SWIFTFORMAT) --lint .
	$(SWIFTLINT) lint

format:
	$(SWIFTFORMAT) .
	$(SWIFTLINT) --fix

boot:
	xcrun simctl boot '$(SIMULATOR)' || true

boot-wait:
	xcrun simctl bootstatus '$(SIMULATOR)' -b

test:
	xcodebuild test -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

build-test:
	xcodebuild build test -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME)
