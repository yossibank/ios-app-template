SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
DEFAULT_SIMULATOR := $(shell xcrun simctl list devices available | awk -F'[()]' '/^ *iPhone/ {gsub(/^ +| +$$/,"",$$1); print $$1; exit}')
SIMULATOR ?= $(DEFAULT_SIMULATOR)
DEST      := platform=iOS Simulator,name=$(SIMULATOR)
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO
TEST_SCHEMES := ScreenCore FeatureHomeTests

.PHONY: open verify lint format test build clean boot boot-wait

open:
	open $(WORKSPACE)

verify: lint test build

lint:
	swiftformat --lint .
	swiftlint lint

format:
	swiftformat .
	swiftlint --fix

boot:
	xcrun simctl boot '$(SIMULATOR)' || true

boot-wait:
	xcrun simctl bootstatus '$(SIMULATOR)' -b

test:
	for scheme in $(TEST_SCHEMES); do \
		xcodebuild test -workspace $(WORKSPACE) -scheme $$scheme -destination '$(DEST)' || exit 1; \
	done

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME)
