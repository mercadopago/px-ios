#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" 
xcodebuild clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s" ONLY_ACTIVE_ARCH=NO -quiet

# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6"
# xcodebuild test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s"
