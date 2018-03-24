Pod::Spec.new do |s|
  s.name             = "MercadoPagoSDK"
  s.version          = "4.0.0.beta.14"
  s.summary          = "MercadoPagoSDK"
  s.homepage         = "https://www.mercadopago.com"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "Mercado Pago"
  s.source           = { :git => "https://github.com/mercadopago/px-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.default_subspec = 'Default'

  s.subspec 'Default' do |default|
    default.resources = ['MercadoPagoSDK/MercadoPagoSDK/*.xcassets','MercadoPagoSDK/MercadoPagoSDK/*/*.xcassets', 'MercadoPagoSDK/MercadoPagoSDK/*.ttf','MercadoPagoSDK/*.plist', 'MercadoPagoSDK/MercadoPagoSDK/*.lproj']
    default.source_files = ['MercadoPagoSDK/MercadoPagoSDK/*', 'MercadoPagoSDK/MercadoPagoSDK/Hooks/*', 'MercadoPagoSDK/MercadoPagoSDK/PaymentMethodPlugins/*']
    s.dependency 'MercadoPagoPXTracking', '2.1.0'
    s.dependency 'MercadoPagoServices', '1.0.6'
  end

s.pod_target_xcconfig = {
  'SWIFT_VERSION' => '3.0.1'
}

end
