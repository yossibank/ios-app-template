SCHEME    := AppTemplate
WORKSPACE := AppTemplate.xcworkspace
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)

# Xcode はパッケージターゲットに -suppress-warnings を渡すため、これが無いと
# Package/ 配下（＝このリポジトリのコードのほぼ全部）の警告が一切出ない。
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
	swift test --package-path Macro/RequiresMacro

build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DEST)' $(SETTINGS)

clean:
	xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME)
