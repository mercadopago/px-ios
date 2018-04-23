# !/bin/bash -e

file_name="MercadoPagoSDK.podspec"
temp_name="TempMercadoPagoSDK"

echo "=========================================="
echo "1) Changing .podspec"
echo "=========================================="

cd ..
mv $file_name $temp_name
cp $temp_name $file_name

lf=$'\n'


text="  s.subspec 'ESC' do |esc|	\\$lf	esc.dependency 'MercadoPagoSDK\/Default'  \\$lf    	esc.dependency 'MLESCManager', '1.0.2' \\$lf     esc.pod_target_xcconfig = { \\$lf       'OTHER_SWIFT_FLAGS[config=Debug]' => '-D MPESC_ENABLE', \\$lf       'OTHER_SWIFT_FLAGS[config=Release]' => '-D MPESC_ENABLE', \\$lf       'OTHER_SWIFT_FLAGS[config=Testflight]' => '-D MPESC_ENABLE' \\$lf     } \\$lf   end"

sed -e "20s/^//p; 20s/^.*/ $text\\$lf/g" -e 's/:git.*/:git => "git@github.com:mercadopago\/px-ios.git", :tag => s.version.to_s }/' $temp_name | tee $file_name


echo "=========================================="
echo "2) Validate .podspec --allow-warnings"
echo "=========================================="

pod lib lint --allow-warnings --verbose --sources='git@github.com:mercadolibre/mobile-ios_specs.git,https://github.com/CocoaPods/Specs'
STATUS=$?
if [ $STATUS -ne 0 ]
	then
		echo "Error ocurred. Validate podspec."
		exit 0
fi

echo "=========================================="
echo "3) Push podspec into mobile-ios_specs"
echo "=========================================="

OUTPUT="$(pod repo list | grep -c "MPPods")"

# Add private repo if not set

if test $OUTPUT != 2
	then
	pod repo add MPPods git@github.com:mercadolibre/mpmobile-ios_specs.git
fi

pod repo push MPPods $file_name --allow-warnings --verbose

rm $file_name
mv $temp_name $file_name

exit
