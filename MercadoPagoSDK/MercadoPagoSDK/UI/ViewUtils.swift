//
//  ViewUtil.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 21/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

internal class ViewUtils {
    class func loadImageFromUrl(_ imageURL: String?) -> UIImage? {
        guard let imageURL = imageURL else {
            return nil
        }
        let url = URL(string: imageURL)
        if url != nil {
            let data = try? Data(contentsOf: url!)
            if data != nil {
                let image = UIImage(data: data!)
                return image
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
