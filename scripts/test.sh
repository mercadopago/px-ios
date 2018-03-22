#!/bin/bash -e

pwd

value=$(<./MercadoPagoSDK/translations.plist)
echo "$value"

echo "Clearing PXStrings Content"
cat /dev/null >| ./MercadoPagoSDK/PXStrin.swift

cat <<EOT >> ./MercadoPagoSDK/PXStrin.swift
//
//  PXStrings.swift
//  MercadoPagoSDK

import Foundation

enum PXStr {
EOT

for number in {1..14}
do
  echo "    static let numero_$number =  "$number"" >> ./MercadoPagoSDK/PXStrin.swift
done

echo "}" >> ./MercadoPagoSDK/PXStrin.swift

exit 0
