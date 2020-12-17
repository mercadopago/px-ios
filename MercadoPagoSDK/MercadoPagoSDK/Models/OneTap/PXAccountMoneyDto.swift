//
//  PXAccountMoneyDto.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 23/10/18.
//

import Foundation

/// :nodoc:
open class PXAccountMoneyDto: NSObject, Codable {
    open var availableBalance: Double = 0
    open var invested: Bool = false
    open var cardTitle: String?
    open var sliderTitle: String?
    open var cardType: PXAccountMoneyTypes?
    open var color: String?
    open var paymentMethodImageURL: String?
    open var gradientColors: [String]?
    
    public enum PXAccountMoneyTypes: String {
        case defaultType = "default"
        case hybrid = "hybrid"
    }

    public init(availableBalance: Double, invested: Bool, sliderTitle: String?, cardTitle: String?, cardType: String?, color: String?, paymentMethodImageURL: String?, gradientColors: [String]?) {
        self.availableBalance = availableBalance
        self.invested = invested
        self.cardTitle = cardTitle
        self.sliderTitle = sliderTitle
        
        if let cardType = cardType {
            self.cardType = PXAccountMoneyTypes(rawValue: cardType) ?? .defaultType
        } else {
            self.cardType = .defaultType
        }
        
        self.color = color
        self.paymentMethodImageURL = paymentMethodImageURL
        self.gradientColors = gradientColors
    }

    public enum PXAccountMoneyKeys: String, CodingKey {
        case availableBalance = "available_balance"
        case invested
        case displayInfo = "display_info"
        case cardTitle = "message"
        case sliderTitle = "slider_title"
        case cardType = "type"
        case color = "color"
        case paymentMethodImageURL = "payment_method_image_url"
        case gradientColors = "gradient_colors"
    }

    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXAccountMoneyKeys.self)
        let invested: Bool = try container.decode(Bool.self, forKey: .invested)
        let availableBalance: Double = try container.decode(Double.self, forKey: .availableBalance)
        let display_info = try container.nestedContainer(keyedBy: PXAccountMoneyKeys.self, forKey: .displayInfo)
        let cardTitle: String? = try display_info.decodeIfPresent(String.self, forKey: .cardTitle)
        let sliderTitle: String? = try display_info.decodeIfPresent(String.self, forKey: .sliderTitle)
        let cardType: String? = try display_info.decodeIfPresent(String.self, forKey: .cardType)
        let color: String? = try display_info.decodeIfPresent(String.self, forKey: .color)
        let paymentMethodImageURL: String? = try display_info.decodeIfPresent(String.self, forKey: .paymentMethodImageURL)
        let gradientColors: [String]? = try display_info.decodeIfPresent([String].self, forKey: .gradientColors)
        self.init(availableBalance: availableBalance, invested: invested, sliderTitle: sliderTitle, cardTitle: cardTitle, cardType: cardType, color: color, paymentMethodImageURL: paymentMethodImageURL, gradientColors: gradientColors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXAccountMoneyKeys.self)
        try container.encode(self.availableBalance, forKey: .availableBalance)
        try container.encode(self.invested, forKey: .invested)
        try container.encodeIfPresent(self.sliderTitle, forKey: .sliderTitle)
        try container.encodeIfPresent(self.cardTitle, forKey: .cardTitle)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXAccountMoneyDto {
        return try JSONDecoder().decode(PXAccountMoneyDto.self, from: data)
    }
}
