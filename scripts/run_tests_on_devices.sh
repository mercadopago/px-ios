#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild -workspace MercadoPagoSDK.xcworkspace clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6"

#xcodebuild -workspace MercadoPagoSDK.xcworkspace clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s"
