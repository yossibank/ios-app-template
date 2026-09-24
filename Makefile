SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
DEFAULT_SIMULATOR := $(shell xcrun simctl list devices available | awk -F'[()]' '/^ *iPhone/ {gsub(/^ +| +$$/,"",$$1); print $$1; exit}')
SIMULATOR ?= $(DEFAULT_SIMULATOR)
DEST      := platform=iOS Simulator,name=$(SIMULATOR)
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES

SWIFTFORMAT ?= mint run swiftformat
SWIFTLINT   ?= mint run swiftlint

.PHONY: open verify bootstrap lint testplan format test build build-test clean boot boot-wait

open:
	open $(WORKSPACE)

verify: lint testplan build-test

testplan:
	@sh Scripts/check-testplan.sh

bootstrap:
	mint bootstrap

lint:
	$(SWIFTFORMAT) --lint .
	$(SWIFTLINT) lint --strict

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
