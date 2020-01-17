#!/bin/bash -e
booted=( $(xcrun simctl list | sed -n 's/.*(\(.*\)) (Booted)/\1/p') )

cd ../MercadoPagoSDK

if [ ${#booted[@]} != 0 ]; then
    device=${booted[0]}
    if `gem list xcpretty -i`; then
        xcodebuild -workspace MercadoPagoSDK.xcworkspace -scheme MercadoPagoSDKTests -destination 'id='$device'' clean test| grep error | xcpretty -t
    else
        xcodebuild -workspace MercadoPagoSDK.xcworkspace -scheme MercadoPagoSDKTests -destination 'id='$device'' clean test| grep error
    fi
else
    if `gem list xcpretty -i`; then
        xcodebuild -workspace MercadoPagoSDK.xcworkspace -scheme MercadoPagoSDKTests -destination 'platform=iOS Simulator,name=iPhone SE,OS=11.4' clean test| grep error | xcpretty -t
    else 
        xcodebuild -workspace MercadoPagoSDK.xcworkspace -scheme MercadoPagoSDKTests -destination 'platform=iOS Simulator,name=iPhone SE,OS=11.4' clean test| grep error
    fi
fi
exit ${PIPESTATUS[0]}



