//
//  PXBusinessResult.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 8/3/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

@objc public enum PXBusinessResultStatus: Int {
    case APPROVED
    case REJECTED
    case PENDING
    case IN_PROGRESS

    func getDescription() -> String {
        switch self {
        case .APPROVED : return "APPROVED"
        case .REJECTED  : return "REJECTED"
        case .PENDING   : return "PENDING"
        case .IN_PROGRESS : return "IN PROGRESS"
        }
    }
}

/*
 Esta clase representa un resultado de pago de negocio.
 Por ejemplo, cuando hay un error al momento de realizar un pago que tiene que ver con el negocio y no con el payment method.
 */
@objcMembers open class PXBusinessResult: NSObject {

    private let status: PXBusinessResultStatus // APPROVED REJECTED PENDING
    private let title: String // Titluo de Congrats
    private let subtitle: String? // Sub Titluo de Congrats
    private let icon: UIImage?  // Icono de Congrats
    private let mainAction: PXComponentAction? // Boton principal (Azul)
    private let secondaryAction: PXComponentAction? // Boton secundario (link)
    private let helpMessage: String? // Texto
    private let showPaymentMethod: Bool // Si quiere que muestre la celda de PM
    private let statementDescription: String?
    private let imageUrl: String?
    private let topCustomView: UIView?
    private let bottomCustomView: UIView?
    private var receiptId: String?

    public init(receiptId: String? = nil, status: PXBusinessResultStatus, title: String, subtitle: String? = nil, icon: UIImage? = nil, mainAction: PXComponentAction? = nil, secondaryAction: PXComponentAction?, helpMessage: String? = nil, showPaymentMethod: Bool = false, statementDescription: String? = nil, imageUrl: String? = nil, topCustomView: UIView? = nil, bottomCustomView: UIView? = nil) {
        self.receiptId = receiptId
        self.status = status
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.mainAction = mainAction
        self.secondaryAction = secondaryAction
        self.helpMessage = helpMessage
        self.showPaymentMethod = showPaymentMethod
        self.statementDescription = statementDescription
        self.imageUrl = imageUrl
        self.topCustomView = topCustomView
        self.bottomCustomView = bottomCustomView
        super.init()
    }

}

// MARK: Getters
extension PXBusinessResult {

    public func getStatus() -> PXBusinessResultStatus {
        return self.status
    }
    public func getTitle() -> String {
        return self.title
    }
    public func getStatementDescription() -> String? {
        return self.statementDescription
    }
    public func getTopCustomView() -> UIView? {
        return self.topCustomView
    }
    public func getBottomCustomView() -> UIView? {
        return self.bottomCustomView
    }
    public func getImageUrl() -> String? {
        return self.imageUrl
    }
    public func getReceiptId() -> String? {
        return self.receiptId
    }
    public func getSubTitle() -> String? {
        return self.subtitle
    }
    public func getHelpMessage() -> String? {
        return self.helpMessage
    }
    public func getIcon() -> UIImage? {
        return self.icon
    }
    public func getMainAction() -> PXComponentAction? {
        return self.mainAction
    }
    public func getSecondaryAction() -> PXComponentAction? {
        return self.secondaryAction
    }
    public func mustShowPaymentMethod() -> Bool {
        return self.showPaymentMethod
    }
}
