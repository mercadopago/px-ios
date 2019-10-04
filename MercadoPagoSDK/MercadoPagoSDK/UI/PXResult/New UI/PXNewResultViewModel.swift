//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

struct ResultViewData {
    let view: UIView
    let verticalMargin: CGFloat
    let horizontalMargin: CGFloat
}

protocol PXNewResultViewModelInterface {
    func getViews() -> [ResultViewData]
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)
    func primaryResultColor() -> UIColor
    func buildHeaderView() -> UIView
    func buildFooterView() -> UIView
    func buildImportantCustomView() -> UIView?
    func buildTopCustomView() -> UIView?
    func buildBottomCustomView() -> UIView?
    func buildPaymentMethodView(paymentData: PXPaymentData) -> UIView?
    func buildPointsViews() -> UIView?
    func buildDiscountsView() -> UIView?
    func buildDiscountsAccessoryView() -> ResultViewData?
    func buildCrossSellingViews() -> [UIView]?
    func buildReceiptView() -> UIView?
    func getTrackingProperties() -> [String: Any]
    func getTrackingPath() -> String
}
