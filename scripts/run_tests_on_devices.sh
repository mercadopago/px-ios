#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild clean test -project MercadoPagoSDK.xcodeproj -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,name=iPhone 7,OS=10.3" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO -quiet
xcodebuild clean test -project MercadoPagoSDK.xcodeproj -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,name=iPhone 7,OS=8.2" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO -quiet

# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6"
# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s"
