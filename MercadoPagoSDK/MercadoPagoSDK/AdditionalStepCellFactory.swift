//
//  AdditionalStepCellFactory.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class AdditionalStepCellFactory: NSObject {
    
    open class func buildCell(object: Cellable, width: Double, height: Double) -> UITableViewCell {
        
        if object.objectType == ObjectTypes.payerCost {
            let bundle = MercadoPago.getBundle()
            let cell: PayerCostRowTableViewCell = bundle!.loadNibNamed("PayerCostRowTableViewCell", owner: nil, options: nil)?[0] as! PayerCostRowTableViewCell
            let showDescription = MercadoPagoCheckout.showPayerCostDescription()
            cell.fillCell(payerCost: object as! PayerCost, showDescription: showDescription)
            cell.addSeparatorLineToBottom(width: width, height: height)
            cell.selectionStyle = .none
            
            return cell
        }
        
        if object.objectType == ObjectTypes.issuer {
            let bundle = MercadoPago.getBundle()
            let cell: IssuerRowTableViewCell = bundle!.loadNibNamed("IssuerRowTableViewCell", owner: nil, options: nil)?[0] as! IssuerRowTableViewCell
            cell.fillCell(issuer: object as! Issuer, bundle: bundle!)
            cell.addSeparatorLineToBottom(width: width, height: height)
            cell.selectionStyle = .none
            
            return cell
        }
        
        if object.objectType == ObjectTypes.entityType {
            let bundle = MercadoPago.getBundle()
            let cell: EntityTypeTableViewCell = bundle!.loadNibNamed("EntityTypeTableViewCell", owner: nil, options: nil)?[0] as! EntityTypeTableViewCell
            cell.fillCell(entityType: object as! EntityType)
            cell.addSeparatorLineToBottom(width: width, height: height)
            cell.selectionStyle = .none
            
            return cell
        }
        
        if object.objectType == ObjectTypes.financialInstitution {
            let bundle = MercadoPago.getBundle()
            let cell: FinancialInstitutionTableViewCell = bundle!.loadNibNamed("FinancialInstitutionTableViewCell", owner: nil, options: nil)?[0] as! FinancialInstitutionTableViewCell
            cell.fillCell(financialInstitution: object as! FinancialInstitution, bundle: bundle!)
            cell.addSeparatorLineToBottom(width: width, height: height)
            cell.selectionStyle = .none
            
            return cell
        }
        
        if object.objectType == ObjectTypes.paymentMethod {
            let bundle = MercadoPago.getBundle()
            let cell: CardTypeTableViewCell = bundle!.loadNibNamed("CardTypeTableViewCell", owner: nil, options: nil)?[0] as! CardTypeTableViewCell
            cell.setPaymentMethod(paymentMethod: object as! PaymentMethod)
            cell.addSeparatorLineToBottom(width: width, height: height)
            cell.selectionStyle = .none
            
            return cell
        }
        
        let defaultCell = UITableViewCell()
        
        return defaultCell
    }
    
}

public enum ObjectTypes : String {
    case payerCost = "payer_cost"
    case issuer = "issuer"
    case entityType = "entity_type"
    case financialInstitution = "financial_instituions"
    case paymentMethod = "payment_method"
}
