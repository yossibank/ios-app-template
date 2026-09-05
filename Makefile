SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO

.PHONY: verify lint format build clean

verify: lint build

lint:
	swiftformat --lint .
	swiftlint lint

format:
	swiftformat .
	swiftlint --fix

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME)
