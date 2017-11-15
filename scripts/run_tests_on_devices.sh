#!/bin/sh

cd ../MercadoPagoSDK

xcodebuild clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" -quiet | xcpretty -t

xcodebuild clean test -scheme MercadoPagoSDKTests -destination "platform=iOS Simulator,OS=10.0,name=iPhone 6s" -quiet