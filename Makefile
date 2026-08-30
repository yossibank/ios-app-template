SCHEME    := ios-app-template
PROJECT   := ios-app-template.xcodeproj
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)

.PHONY: verify lint format build test clean

# 変更後に必ず通すもの。xcodebuild test はビルドを含む。
verify: lint test

lint:
	swiftformat --lint .
	swiftlint lint

# 自動修正できるものを直す。
format:
	swiftformat .
	swiftlint --fix

build:
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)'

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)'

clean:
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)
