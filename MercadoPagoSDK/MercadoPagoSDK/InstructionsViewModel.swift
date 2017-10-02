//
//  InstructionsViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 9/27/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

open class InstructionsViewModel: NSObject {
    var paymentResult: PaymentResult!
    var instructionsInfo: InstructionsInfo!
    var paymentResultScreenPreference: PaymentResultScreenPreference!
    var callback : ( _ status: PaymentResult.CongratsState) -> Void

    public init(paymentResult: PaymentResult, paymentResultScreenPreference: PaymentResultScreenPreference, instructionsInfo: InstructionsInfo, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.paymentResult = paymentResult
        self.paymentResultScreenPreference = paymentResultScreenPreference
        self.instructionsInfo = instructionsInfo
        self.callback = callback
    }

    func getHeaderColor() -> UIColor {
        return UIColor.instructionsHeaderColor()
    }

    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func numberOfSections() -> Int {
        return (instructionsInfo != nil) ? 3 : 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case Sections.header.rawValue:
            let numberOfCells =  shouldShowSubtitle() ? 2 : 1
            return numberOfCells
        case Sections.body.rawValue:
            return 1
        case Sections.footer.rawValue:
            let numberOfCells = shouldShowSecundaryInformation() ? 2 : 1
            return numberOfCells
        default:
            return 0
        }
    }

    func shouldShowSubtitle() -> Bool {
        return instructionsInfo.hasSubtitle()
    }

    func getInstruction() -> Instruction {
        return instructionsInfo.getInstruction()!
    }

    func shouldShowSecundaryInformation() -> Bool {
        return MercadoPagoCheckoutViewModel.servicePreference.shouldShowEmailConfirmationCell() && instructionsInfo.hasSecundaryInformation()
    }

    func getMetada() -> [String: String?] {
        var metadata = [TrackingUtil.METADATA_PAYMENT_IS_EXPRESS: TrackingUtil.IS_EXPRESS_DEFAULT_VALUE,
                        TrackingUtil.METADATA_PAYMENT_STATUS: self.paymentResult.status,
                        TrackingUtil.METADATA_PAYMENT_STATUS_DETAIL: self.paymentResult.statusDetail,
                        TrackingUtil.METADATA_PAYMENT_ID: self.paymentResult._id]
        if let pm = self.paymentResult.paymentData?.getPaymentMethod() {
            metadata[TrackingUtil.METADATA_PAYMENT_METHOD_ID] = pm._id
        }
        if let issuer = self.paymentResult.paymentData?.getIssuer() {
            metadata[TrackingUtil.METADATA_ISSUER_ID] = issuer._id
        }
        return metadata
    }

    func isHeaderTitleCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.header.rawValue && indexPath.row == 0
    }
    func isHeaderSubtitleCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.header.rawValue && indexPath.row == 1 && shouldShowSubtitle()
    }

    func isBodyCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.body.rawValue
    }

    func isSecondaryInfoCellFor(indexPath: IndexPath) -> Bool {
        return indexPath.section == Sections.footer.rawValue && indexPath.row == 0 && shouldShowSecundaryInformation()
    }

    func isFooterCellFor(indexPath: IndexPath) -> Bool {
        let isSection = indexPath.section == Sections.footer.rawValue
        let isRow = shouldShowSecundaryInformation() ? indexPath.row == 1 : indexPath.row == 0
        return isSection && isRow
    }

    public enum Sections: Int {
        case header = 0
        case body = 1
        case footer = 2
    }
}
