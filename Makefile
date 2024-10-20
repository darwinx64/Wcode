STRIP := $(shell command -v strip)
WCODETMP := $(TMPDIR)/WCODE
WCODE_STAGE_DIR := $(WCODETMP)/stage
WCODE_APP_DIR := $(WCODETMP)/Build/Products/Release/WCODE.app
CODE_SIGN := YES

.PHONY: package

package:
	@if [ "$(CODE_SIGN)" = "NO" ]; then \
		CODE_SIGN_IDENTITY=""; \
		CODE_SIGNING_REQUIRED=NO; \
	fi
	# Build
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'Wcode.xcodeproj' -scheme Wcode -configuration Release -sdk macosx -derivedDataPath $(WCODETMP) \
		DSTROOT=$(WCODETMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	
	@rm -rf $(WCODE_STAGE_DIR)/
	@mkdir -p $(WCODE_STAGE_DIR)/Payload
	@mv $(WCODE_APP_DIR) $(WCODE_STAGE_DIR)/Payload/WCODE.app

	# Package
	@echo $(WCODETMP)
	@rm -rf packages

	# Move new app bundle to package directory
	@mkdir packages
	@mv $(WCODE_STAGE_DIR)/Payload/WCODE.app packages/WCODE.app
	@rm -rf $(WCODETMP)
	@rm -rf Payload
	@codesign -f -s - packages/WCODE.app --preserve-metadata=entitlements
