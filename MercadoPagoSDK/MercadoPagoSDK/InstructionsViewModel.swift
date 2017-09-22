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
        if indexPath.section == 1 {
            return UITableViewAutomaticDimension
        }
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
    
    func getCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.header.rawValue:
            if indexPath.row == 0 {
                let cell: HeaderCongratsTableViewCell = MercadoPago.getBundle()!.loadNibNamed("HeaderCongratsTableViewCell", owner: nil, options: nil)?[0] as! HeaderCongratsTableViewCell
                cell.fillCell(instructionsInfo: instructionsInfo!, color: getHeaderColor())
                cell.selectionStyle = .none
                return cell
            } else {
                let cell: InstructionsSubtitleTableViewCell = MercadoPago.getBundle()!.loadNibNamed("InstructionsSubtitleTableViewCell", owner: nil, options: nil)?[0] as! InstructionsSubtitleTableViewCell
                cell.fillCell(instruction: self.instructionsInfo!.instructions[0])
                cell.selectionStyle = .none
                return cell
            }
        case Sections.body.rawValue:
            let cell: InstructionBodyTableViewCell = MercadoPago.getBundle()!.loadNibNamed("InstructionBodyTableViewCell", owner: nil, options: nil)?[0] as! InstructionBodyTableViewCell
            cell.selectionStyle = .none
            ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
            cell.fillCell(instruction: self.instructionsInfo!.instructions[0], paymentResult: paymentResult)
            return cell
        default:
            if indexPath.row == 0 && shouldShowSecundaryInformation() {
                let cell: SecondaryInfoTableViewCell = MercadoPago.getBundle()!.loadNibNamed("SecondaryInfoTableViewCell", owner: nil, options: nil)?[0] as! SecondaryInfoTableViewCell
                cell.fillCell(instruction: instructionsInfo?.instructions[0])
                cell.selectionStyle = .none
                ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
                return cell
            } else {
                let cell: FooterTableViewCell = MercadoPago.getBundle()!.loadNibNamed("FooterTableViewCell", owner: nil, options: nil)?[0] as! FooterTableViewCell
                cell.selectionStyle = .none
                ViewUtils.drawBottomLine(y: cell.contentView.frame.minY, width: UIScreen.main.bounds.width, inView: cell.contentView)
                cell.setCallbackStatus(callback: callback, status: PaymentResult.CongratsState.ok)
                cell.fillCell(paymentResult: paymentResult, paymentResultScreenPreference: paymentResultScreenPreference)
                return cell
            }
        }
    }
    
    func shouldShowSubtitle() -> Bool {
        return instructionsInfo.hasSubtitle()
    }
    
    func shouldShowSecundaryInformation() -> Bool {
        return MercadoPagoCheckoutViewModel.servicePreference.shouldShowEmailConfirmationCell() && instructionsInfo.hasSecundaryInformation()
    }
    
    public enum Sections: Int {
        case header = 0
        case body = 1
        case footer = 2
    }
}
