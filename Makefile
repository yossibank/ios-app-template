SCHEME    := ios-app-template
PROJECT   := ios-app-template.xcodeproj
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)

.PHONY: verify lint format build test test-ui clean

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

# ユニットテストのみ。UI テストは時間がかかるため除外する。
test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' \
		-skip-testing:ios-app-templateUITests

test-ui:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)'

clean:
	xcodebuild clean -project $(PROJECT) -scheme $(SCHEME)
