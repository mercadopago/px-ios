//
//  PXOneTapHeaderViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import UIKit

typealias OneTapHeaderSummaryData = (title: String, value: String, highlightedColor: UIColor, alpha: CGFloat, isTotal: Bool, image: UIImage?)

class PXOneTapHeaderViewModel {
    let icon: UIImage
    let title: String
    let data: [OneTapHeaderSummaryData]

    init(icon: UIImage, title: String, data: [OneTapHeaderSummaryData]) {
        self.icon = icon
        self.title = title
        self.data = data
    }
}
