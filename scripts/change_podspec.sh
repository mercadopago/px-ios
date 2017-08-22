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

text="  s.subspec 'ESC' do |esc|	\\$lf	esc.dependency 'MercadoPagoSDK\/Default'  \\$lf    	esc.dependency 'MLESCManager' \\$lf     esc.pod_target_xcconfig = { \\$lf       'OTHER_SWIFT_FLAGS[config=Debug]' => '-D MPESC_ENABLE', \\$lf       'OTHER_SWIFT_FLAGS[config=Release]' => '-D MPESC_ENABLE' \\$lf     } \\$lf   end"

 sed "18s/^//p; 18s/^.*/ $text\\$lf/g" $temp_name | tee $file_name


echo "=========================================="
echo "2) Validate .podspec --allow-warnings"
echo "=========================================="

pod lib lint --allow-warnings --verbose --sources='git@github.com:mercadolibre/mobile-ios_specs.git'
STATUS=$?
if [ $STATUS -ne 0 ]
	then
		echo "Error ocurred. Validate podspec."
		exit 0
fi

echo "=========================================="
echo "3) Push podspec into mobile-ios_specs"
echo "=========================================="

OUTPUT="$(pod repo list | grep -c "MLPod")"

# Add private repo if not set

if test $OUTPUT != 2
	then
	pod repo add MLPods git@github.com:mercadolibre/mobile-ios_specs.git
fi

pod repo push MLPods $file_name --allow-warnings --verbose

rm $file_name
mv $temp_name $file_name

exit