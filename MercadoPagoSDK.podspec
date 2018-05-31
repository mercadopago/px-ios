Pod::Spec.new do |s|
  s.name             = "MercadoPagoSDK"
  s.version          = "4.0.0.beta.24"
  s.summary          = "MercadoPagoSDK"
  s.homepage         = "https://www.mercadopago.com"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "Mercado Pago"
  s.source           = { :git => "https://github.com/mercadopago/px-ios.git", :tag => s.version.to_s }
  s.swift_version = '4.0'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.default_subspec = 'Default'

  s.subspec 'Default' do |default|
    default.resources = ['MercadoPagoSDK/MercadoPagoSDK/*.xcassets','MercadoPagoSDK/MercadoPagoSDK/*/*.xcassets', 'MercadoPagoSDK/MercadoPagoSDK/*.ttf', 'MercadoPagoSDK/MercadoPagoSDK/**/**.{plist,xib,strings}', 'MercadoPagoSDK/MercadoPagoSDK/*.lproj']
    default.source_files = ['MercadoPagoSDK/MercadoPagoSDK/**/**/**.{h,m,swift}']
    s.dependency 'MercadoPagoPXTracking', '2.1.2'
    s.dependency 'MercadoPagoServices', '1.0.9'
    s.dependency 'MLUI', '4.1.0'
  end

end
