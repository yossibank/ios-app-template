SCHEME    := ios-app-template
PROJECT   := ios-app-template.xcodeproj
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)

# Xcode はパッケージターゲットに -suppress-warnings を渡すため、これが無いと
# Package/ 配下（＝このリポジトリのコードのほぼ全部）の警告が一切出ない。
SETTINGS  := SWIFT_SUPPRESS_WARNINGS=NO

.PHONY: verify lint format build test clean

# 変更後に必ず通すもの。xcodebuild test はビルドを含む。
verify: lint test

lint:
	swiftformat --lint .
	swiftlint lint

format:
	swiftformat .
	swiftlint --fix

build:
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)
