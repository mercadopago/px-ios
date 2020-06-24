//
//  PXPointsAndDiscounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/08/2019.
//

import Foundation

struct PXPointsAndDiscounts: Decodable {

    let points: PXPoints?
    let discounts: PXDiscounts?
    let crossSelling: [PXCrossSellingItem]?
    let viewReceiptAction: PXRemoteAction?
    let topTextBox: PXText?
    let customOrder: Bool?
    let expenseSplit: PXPaymentSplit?

    init(points: PXPoints?, discounts: PXDiscounts?, crossSelling: [PXCrossSellingItem]?, viewReceiptAction: PXRemoteAction?, topTextBox: PXText?, customOrder: Bool?, paymentSplit: PXPaymentSplit?) {
        self.points = points
        self.discounts = discounts
        self.crossSelling = crossSelling
        self.viewReceiptAction = viewReceiptAction
        self.topTextBox = topTextBox
        self.customOrder = customOrder
        self.expenseSplit = paymentSplit
    }

    enum PointsAndDiscountsCodingKeys: String, CodingKey {
        case points = "mpuntos"
        case discounts
        case crossSelling = "cross_selling"
        case viewReceiptAction = "view_receipt"
        case topTextBox = "top_text_box"
        case customOrder = "custom_order"
        case paymentSplit = "expense_split"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PointsAndDiscountsCodingKeys.self)
        let points: PXPoints? = try container.decodeIfPresent(PXPoints.self, forKey: .points)
        let discounts: PXDiscounts? = try container.decodeIfPresent(PXDiscounts.self, forKey: .discounts)
        let crossSelling: [PXCrossSellingItem]? = try container.decodeIfPresent([PXCrossSellingItem].self, forKey: .crossSelling)
        let viewReceiptAction: PXRemoteAction? = try container.decodeIfPresent(PXRemoteAction.self, forKey: .viewReceiptAction)
        let topTextBox: PXText? = try container.decodeIfPresent(PXText.self, forKey: .topTextBox)
        let customOrder: Bool? = try container.decodeIfPresent(Bool.self, forKey: .customOrder)
        let paymentSplit: PXPaymentSplit? = try container.decodeIfPresent(PXPaymentSplit.self, forKey: .paymentSplit)
        self.init(points: points, discounts: discounts, crossSelling: crossSelling, viewReceiptAction: viewReceiptAction, topTextBox: topTextBox, customOrder: customOrder, paymentSplit: paymentSplit)
    }
}
