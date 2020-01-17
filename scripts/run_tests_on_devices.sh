#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild -workspace MercadoPagoSDK.xcworkspace clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=11.4,name=iPhone SE"

#xcodebuild -workspace MercadoPagoSDK.xcworkspace clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s"
