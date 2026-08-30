SCHEME    := ios-app-template
PROJECT   := ios-app-template.xcodeproj
SIMULATOR ?= iPhone 17 Pro
DEST      := platform=iOS Simulator,name=$(SIMULATOR)

KMP_DIR ?= ../kmp-app-template

.PHONY: bootstrap verify build test test-ui clean

# 共通コアの XCFramework を生成する。clone 直後と kmp 変更後に必要。
bootstrap:
	$(MAKE) -C $(KMP_DIR) build-ios

# 変更後に必ず通すもの。xcodebuild test はビルドを含む。
verify: test

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
