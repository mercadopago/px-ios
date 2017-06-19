#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild clean test -project MercadoPagoSDK.xcodeproj -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,name=iPhone SE,OS=10.1" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO -quiet
xcodebuild clean test -project MercadoPagoSDK.xcodeproj -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,name=iPhone 6S,OS=9.0" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO -quiet

# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6"
# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s"
