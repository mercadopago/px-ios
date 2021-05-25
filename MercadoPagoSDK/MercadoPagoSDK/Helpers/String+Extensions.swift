//
//  String+Extensions.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 26/04/21.
//

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                       .characterEncoding:String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
        } catch {
            return nil
        }
    }
}
