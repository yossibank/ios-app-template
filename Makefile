SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO

.PHONY: verify lint format test build clean

verify: lint test build

lint:
	swiftformat --lint .
	swiftlint lint

format:
	swiftformat .
	swiftlint --fix

test:
	xcodebuild test -workspace $(WORKSPACE) -scheme FeatureHomeTests -destination '$(DEST)'

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME)
