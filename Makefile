SHELL := /bin/bash
# Install Tasks

install-iOS:
	true

install-OSX:
	true

install-tvOS:
	true

install-carthage:
	brew rm carthage || true
	brew install carthage

install-coverage:
	true

install-cocoapods:
	gem install cocoapods --pre --no-rdoc --no-ri --no-document --quiet

# Run Tasks

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-project Transporter.xcodeproj \
		-scheme Transporter \
		-destination "name=iPhone 6s" \
		clean test \
		| xcpretty -ct

test-OSX:
	set -o pipefail && \
		xcodebuild \
		-project Transporter.xcodeproj \
		-scheme Transporter \
		test \
		| xcpretty -ct

test-tvOS:
	set -o pipefail && \
		xcodebuild \
		-project Transporter.xcodeproj \
		-scheme Transporter \
		-destination "name=Apple TV 1080p" \
		clean test \
		| xcpretty -ct

test-carthage:
	carthage build --no-skip-current
	ls Carthage/build/Mac/Transporter.framework
	ls Carthage/build/iOS/Transporter.framework
	ls Carthage/build/tvOS/Transporter.framework
	ls Carthage/build/watchOS/Transporter.framework

test-coverage:
	  set -o pipefail && xcodebuild -project Transporter.xcodeproj -scheme Transporter -enableCodeCoverage YES test | xcpretty -ct
		bash <(curl -s https://codecov.io/bash)

test-cocoapods:
	pod lib lint Transporter.podspec --verbose
