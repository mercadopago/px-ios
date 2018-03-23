#!/bin/bash -e

value=$(<./MercadoPagoSDK/translations.plist)

cat /dev/null >| ./MercadoPagoSDK/PXStrings.swift

cat <<EOT >> ./MercadoPagoSDK/PXStrings.swift
//
//  PXStrings.swift
//  MercadoPagoSDK

import Foundation

enum PXStrings {
EOT

for key in $value
do
  if [[ $key = *"<key>"* ]]; then
    prefix="<key>"
    suffix="</key>"
    trimmed=${key#$prefix}
    trimmed=${trimmed%$suffix}
    if [ $trimmed != "es" ] && [ $trimmed != "pt" ] && [ $trimmed != "en" ] && [ $trimmed != "comment" ]; then
      echo "    static let $trimmed =  \"$trimmed\"" >> ./MercadoPagoSDK/PXStrings.swift
    fi
  fi
done

echo "}" >> ./MercadoPagoSDK/PXStrings.swift

exit 0
