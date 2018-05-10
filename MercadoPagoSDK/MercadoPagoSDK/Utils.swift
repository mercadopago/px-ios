//
//  Utils.swift
//  MercadoPagoSDK
//
//  Created by Matias Gualino on 21/4/15.
//  Copyright (c) 2015 MercadoPago. All rights reserved.
//

import Foundation
import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l__?, r__?):
        return l__ < r__
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l__?, r__?):
        return l__ > r__
    default:
        return rhs < lhs
    }
}

class Utils {

    private static let kSdkSettingsFile = "mpsdk_settings"

    class func setContrainsHorizontal(views: [String: UIView], constrain: CGFloat) {
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(constrain))-[label]-(\(constrain))-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(widthConstraints)
    }

    class func setContrainsVertical(label: UIView, previus: UIView?, constrain: CGFloat) {
        if let previus = previus {
            let heightConstraints = [NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: previus, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: constrain)]
            NSLayoutConstraint.activate(heightConstraints)
        }
    }

    class func getDateFromString(_ string: String!) -> Date! {
        if string == nil {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var dateArr = string.split {$0 == "T"}.map(String.init)
        return dateFormatter.date(from: dateArr[0])
    }

    class func getStringFromDate(_ date: Date?) -> Any! {

        if date == nil {
            return JSONHandler.null
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date!)
    }

    class func getAttributedAmount(_ formattedString: String, thousandSeparator: String, decimalSeparator: String, currencySymbol: String, color: UIColor = UIColor.px_white(), fontSize: CGFloat = 20, centsFontSize: CGFloat = 10, baselineOffset: Int = 7) -> NSAttributedString {
        let cents = getCentsFormatted(formattedString, decimalSeparator: decimalSeparator)
        let amount = getAmountFormatted(String(describing: Int(formattedString)), thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: fontSize) ?? Utils.getFont(size: fontSize), NSAttributedStringKey.foregroundColor: color]
        let smallAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: centsFontSize) ?? UIFont.systemFont(ofSize: centsFontSize), NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.baselineOffset: baselineOffset as AnyObject]

        let attributedSymbol = NSMutableAttributedString(string: currencySymbol, attributes: normalAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSAttributedString(string: String.NON_BREAKING_LINE_SPACE, attributes: smallAttributes)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedAmount)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedCents)
        return attributedSymbol
    }

    class func getAttributedAmount(_ amount: Double, currency: Currency, color: UIColor = UIColor.px_white(), fontSize: CGFloat = 20, centsFontSize: CGFloat = 10, baselineOffset: Int = 7, negativeAmount: Bool = false) -> NSMutableAttributedString {
        return getAttributedAmount(amount, thousandSeparator: currency.thousandsSeparator, decimalSeparator: currency.decimalSeparator, currencySymbol: currency.symbol, color: color, fontSize: fontSize, centsFontSize: centsFontSize, baselineOffset: baselineOffset, negativeAmount: negativeAmount)
    }

    class func getAttributedAmount(_ amount: Double, thousandSeparator: String, decimalSeparator: String, currencySymbol: String, color: UIColor = UIColor.px_white(), fontSize: CGFloat = 20, centsFontSize: CGFloat = 10, baselineOffset: Int = 7, negativeAmount: Bool = false, smallSymbol: Bool = false) -> NSMutableAttributedString {
        let cents = getCentsFormatted(String(amount), decimalSeparator: ".")
        let amount = getAmountFormatted(String(describing: Int(amount)), thousandSeparator: thousandSeparator, decimalSeparator: ".")

        let normalAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: fontSize) ?? Utils.getFont(size: fontSize), NSAttributedStringKey.foregroundColor: color]
        let smallAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: centsFontSize) ?? UIFont.systemFont(ofSize: centsFontSize), NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.baselineOffset: baselineOffset as AnyObject]

        var symbols: String!
        if negativeAmount {
            symbols = "-" + currencySymbol
        } else {
            symbols = currencySymbol
        }
        var symbolAttributes = normalAttributes
        if smallSymbol {
            symbolAttributes = smallAttributes
        }
        let attributedSymbol = NSMutableAttributedString(string: symbols, attributes: symbolAttributes)
        let attributedAmount = NSMutableAttributedString(string: amount, attributes: normalAttributes)
        let attributedCents = NSAttributedString(string: cents, attributes: smallAttributes)
        let space = NSMutableAttributedString(string: String.NON_BREAKING_LINE_SPACE, attributes: smallAttributes)
        attributedSymbol.append(space)
        attributedSymbol.append(attributedAmount)
        if cents != "00" {
            attributedSymbol.append(space)
            attributedSymbol.append(attributedCents)
        }
        return attributedSymbol
    }

    class func getAmountFormated(amount: Double, forCurrency currency: Currency, addingParenthesis: Bool = false) -> String {
        return getAmountFormatted(amount: amount, thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), addingCurrencySymbol: currency.getCurrencySymbolOrDefault(), addingParenthesis: addingParenthesis)
    }

    class func getAmountFormatted(amount: Double, thousandSeparator: String, decimalSeparator: String, addingCurrencySymbol symbol: String? = nil, addingParenthesis: Bool = false) -> String {
        let cents = getCentsFormatted(String(amount), decimalSeparator: ".")
        let entireAmount = getAmountFormatted(String(describing: Int(amount)), thousandSeparator: thousandSeparator, decimalSeparator: decimalSeparator)
        var amountFotmated = entireAmount
        if !cents.isEmpty {
              amountFotmated += decimalSeparator + cents
              amountFotmated = amountFotmated.replacingOccurrences(of: decimalSeparator + "00", with: "")
        }

        if let symbol = symbol {
            amountFotmated = symbol + " " + amountFotmated
        }
        if addingParenthesis {
            amountFotmated = "(\(amountFotmated))"
        }
        return amountFotmated
    }

    class func getAccreditationTimeAttributedString(from text: String, fontSize: CGFloat? = nil) -> NSAttributedString {
        let clockImage = NSTextAttachment()
        var attributes: [NSAttributedStringKey: Any]? = nil
        if let fontSize = fontSize {
            attributes = [NSAttributedStringKey.font: Utils.getFont(size: fontSize)]
        }
        clockImage.image = MercadoPago.getImage("iconTime")
        let clockAttributedString = NSAttributedString(attachment: clockImage)
        let labelAttributedString = NSMutableAttributedString(string: String(describing: " " + text), attributes: attributes)
        labelAttributedString.insert(clockAttributedString, at: 0)
        let labelTitle = labelAttributedString
        return labelTitle
    }

    class func getTransactionInstallmentsDescription(_ installments: String, currency: Currency, installmentAmount: Double, additionalString: NSAttributedString? = nil, color: UIColor? = nil, fontSize: CGFloat = 22, centsFontSize: CGFloat = 10, baselineOffset: Int = 7) -> NSAttributedString {
        let color = color ?? UIColor.lightBlue()
        let currency = MercadoPagoContext.getCurrency()

        let descriptionAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: getFont(size: fontSize), NSAttributedStringKey.foregroundColor: color]

        let stringToWrite = NSMutableAttributedString()

        let installmentsValue = Int(installments)
        if  installmentsValue > 1 {
            stringToWrite.append(NSMutableAttributedString(string: installments + "x ", attributes: descriptionAttributes))
        }

        stringToWrite.append(Utils.getAttributedAmount(installmentAmount, thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), currencySymbol: currency.getCurrencySymbolOrDefault(), color: color, fontSize: fontSize, centsFontSize: centsFontSize, baselineOffset: baselineOffset))

        if additionalString != nil {
            stringToWrite.append(additionalString!)
        }

        return stringToWrite
    }
    class func getFont(size: CGFloat) -> UIFont {
        return UIFont(name: ThemeManager.shared.getFontName(), size: size) ?? UIFont.systemFont(ofSize: size)
    }

    class func getLightFont(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont(name: ThemeManager.shared.getLightFontName(), size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
        } else {
            return UIFont(name: ThemeManager.shared.getLightFontName(), size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }

    class func getIdentificationFont(size: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont(name: "KohinoorBangla-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
        } else {
            return UIFont(name: "KohinoorBangla-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }

    class func append(firstJSON: String, secondJSON: String) -> String {
        if firstJSON == "" && secondJSON == "" {
            return ""
        } else if secondJSON == "" {
            return firstJSON
        } else if firstJSON == "" {
            return secondJSON
        }
        var firstJSON = firstJSON
        var secondJSON = secondJSON

        secondJSON.remove(at: secondJSON.startIndex)
        firstJSON.remove(at: firstJSON.index(before: firstJSON.endIndex))

        return firstJSON + secondJSON
    }
    /**
     Returns cents string formatted
     Ex: formattedString = "100.2", decimalSeparator = "."
     returns 20
     **/
    class func getCentsFormatted(_ formattedString: String, decimalSeparator: String, decimalPlaces: Int = MercadoPagoContext.getCurrency().getDecimalPlacesOrDefault()) -> String {
        var range = formattedString.range(of: decimalSeparator)

        if range == nil {
            range = formattedString.range(of: ".")
        }

        var cents = ""
        if range != nil {
            let centsIndex = formattedString.index(range!.lowerBound, offsetBy: 1)
            cents = String(formattedString[centsIndex...])
        }

        if cents.isEmpty || cents.count < decimalPlaces {
            var missingZeros = decimalPlaces - cents.count
            while missingZeros > 0 {
                cents.append("0")
                missingZeros -= 1
            }
        } else if cents.count > decimalPlaces {
            let index1 = cents.index(cents.startIndex, offsetBy: decimalPlaces)
            cents = String(cents[..<index1])
        }

        return cents
    }

    /**
     Returns amount string formatted according to separators
     Ex: formattedString = "10200", decimalSeparator = ".", thousandSeparator: ","
     returns 10,200
     **/
    class func getAmountFormatted(_ formattedString: String, thousandSeparator: String, decimalSeparator: String) -> String {

        let amount = self.getAmountDigits(formattedString, decimalSeparator: decimalSeparator)
        let length = amount.count
        if length <= 3 {
            return amount
        }
        var numberWithoutLastThreeDigits: String = ""
        if let amountString = Double(formattedString) {
            numberWithoutLastThreeDigits = String( CUnsignedLongLong(amountString/1000))
        }
        let lastThreeDigits = amount.lastCharacters(number: 3)

        return  getAmountFormatted(numberWithoutLastThreeDigits, thousandSeparator: thousandSeparator, decimalSeparator: thousandSeparator).appending(thousandSeparator).appending(lastThreeDigits)
    }

    /**
     Extract only amount digits
     Ex: formattedString = "1000.00" with decimalSeparator = "."
     returns 1000
     **/
    class func getAmountDigits(_ formattedString: String, decimalSeparator: String) -> String {
        let range = formattedString.range(of: decimalSeparator)
        if range != nil {
            return String(formattedString[..<range!.lowerBound])
        }
        if Double(formattedString) != nil {
            return formattedString
        }
        return ""
    }

    static internal func findPaymentMethodSearchItemInGroups(_ paymentMethodSearch: PaymentMethodSearch, paymentMethodId: String, paymentTypeId: PaymentTypeId?) -> PaymentMethodSearchItem? {
        guard paymentMethodSearch.groups != nil
            else {return nil}

        if let result = Utils.findPaymentMethodSearchItemById(paymentMethodSearch.groups, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return result
        }
        return nil
    }

    static internal func findCardInformationIn(customOptions: [CardInformation], paymentData: PaymentData, savedESCCardToken: SavedESCCardToken? = nil) -> CardInformation? {
        let customOptionsFound = customOptions.filter { (cardInformation: CardInformation) -> Bool in
            if paymentData.getPaymentMethod()!.isAccountMoney {
                return  cardInformation.getPaymentMethodId() == PaymentTypeId.ACCOUNT_MONEY.rawValue
            } else {
                if paymentData.hasToken() {
                    return paymentData.getToken()!.cardId == cardInformation.getCardId()
                } else if savedESCCardToken != nil {
                    return savedESCCardToken!.cardId == cardInformation.getCardId()
                }
            }
            return false
        }
        return !Array.isNullOrEmpty(customOptionsFound) ? customOptionsFound[0] : nil
    }

    static fileprivate func findPaymentMethodSearchItemById(_ paymentMethodSearchList: [PaymentMethodSearchItem], paymentMethodId: String, paymentTypeId: PaymentTypeId?) -> PaymentMethodSearchItem? {

        var filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg: PaymentMethodSearchItem) -> Bool in
            arg.idPaymentMethodSearchItem == paymentMethodId
        }

        if filterPaymentMethodSearchFound.count > 0 {
            return filterPaymentMethodSearchFound[0]
        } else if paymentTypeId != nil {
            filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg: PaymentMethodSearchItem) -> Bool in
                arg.idPaymentMethodSearchItem == paymentMethodId + "_" + paymentTypeId!.rawValue
            }

            if filterPaymentMethodSearchFound.count > 0 {
                return filterPaymentMethodSearchFound[0]
            }
        } else {
            filterPaymentMethodSearchFound = paymentMethodSearchList.filter { (arg: PaymentMethodSearchItem) -> Bool in
                arg.idPaymentMethodSearchItem.startsWith(paymentMethodId)
            }
            if filterPaymentMethodSearchFound.count > 0 {
                return filterPaymentMethodSearchFound[0]
            }
        }

        for item in paymentMethodSearchList {
            if let paymentMethodSearchItemFound = findPaymentMethodSearchItemById(item.children, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                return paymentMethodSearchItemFound
            }
        }

        if paymentMethodSearchList.count == 0 {
            return nil
        }
        return nil
    }

    static internal func findPaymentMethodTypeId(_ paymentMethodSearchItems: [PaymentMethodSearchItem], paymentTypeId: PaymentTypeId) -> PaymentMethodSearchItem? {

        var filterPaymentMethodSearchFound = paymentMethodSearchItems.filter { (arg: PaymentMethodSearchItem) -> Bool in
            arg.idPaymentMethodSearchItem == paymentTypeId.rawValue
        }

        if !Array.isNullOrEmpty(filterPaymentMethodSearchFound) {
            return filterPaymentMethodSearchFound[0]
        }

        for item in paymentMethodSearchItems {
            if let paymentMethodSearchItemFound = findPaymentMethodTypeId(item.children, paymentTypeId: paymentTypeId) {
                return paymentMethodSearchItemFound
            }
        }

        return nil
    }

    internal static func findPaymentMethod(_ paymentMethods: [PaymentMethod], paymentMethodId: String) -> PaymentMethod {
        var paymentTypeSelected = ""

        let paymentMethod = paymentMethods.filter({ (paymentMethod: PaymentMethod) -> Bool in
            if paymentMethodId.startsWith(paymentMethod.paymentMethodId) {
                let paymentTypeIdRange = paymentMethodId.range(of: paymentMethod.paymentMethodId)
                // Override paymentTypeId if neccesary
                if paymentTypeIdRange != nil {
                    paymentTypeSelected = String(paymentMethodId[paymentTypeIdRange!.upperBound...])
                    if !String.isNullOrEmpty(paymentTypeSelected) {
                        paymentTypeSelected.remove(at: paymentTypeSelected.startIndex)
                    }
                }
                return true

            }
            return false
        })

        if !String.isNullOrEmpty(paymentTypeSelected) {
            paymentMethod[0].paymentTypeId = paymentTypeSelected
        }

        return paymentMethod[0]
    }

    internal static func getExpirationYearFromLabelText(_ mmyy: String) -> Int {
        let stringMMYY = mmyy.replacingOccurrences(of: "/", with: "")
        let validInt = Int(stringMMYY)
        if validInt == nil || stringMMYY.count < 4 {
            return 0
        }
        let floatMMYY = Float( validInt! / 100 )
        let mm: Int = Int(floor(floatMMYY))
        let yy = Int(stringMMYY)! - (mm*100)
        return yy

    }

    internal static func getExpirationMonthFromLabelText(_ mmyy: String) -> Int {
        let stringMMYY = mmyy.replacingOccurrences(of: "/", with: "")
        let validInt = Int(stringMMYY)
        if validInt == nil {
            return 0
        }
        let floatMMYY = Float( validInt! / 100 )
        let mm: Int = Int(floor(floatMMYY))
        if mm >= 1 && mm <= 12 {
            return mm
        }
        return 0
    }

    internal static func getSetting<T>(identifier: String) -> T? {
        let path = MercadoPago.getBundle()!.path(forResource: Utils.kSdkSettingsFile, ofType: "plist")
        let dictPM = NSDictionary(contentsOfFile: path!)
        return dictPM![identifier] as? T
    }

    static func isTesting() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["testing"] != nil
    }

    static func getFormatedStringDate(_ date: Date) -> String {
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "dd"
        let formatterMonth = DateFormatter()
        formatterMonth.locale = NSLocale.current
        formatterMonth.dateFormat = "MMMM"
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "yyyy"

        var dayString = formatterDay.string(from: date)
        if dayString.first == "0" {
            dayString.removeFirst()
        }

        return dayString + " de ".localized + formatterMonth.string(from: date).localized.lowercased() + " de ".localized + formatterYear.string(from: date)
    }

    static func getShortFormatedStringDate(_ date: Date?) -> String? {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            return formatter.string(from: date)
        }
        return nil
    }

    static let imageCache = NSCache<NSString, AnyObject>()

    func loadImageFromURLWithCache(withUrl urlStr: String?, targetView: UIView, placeholderView: UIView?, fallbackView: UIView?, didFinish:((UIImage)-> Void)? = nil) {
        
        guard let urlString = urlStr else {
            if let fallbackView = fallbackView {
                targetView.removeAllSubviews()
                targetView.addSubviewAtFullSize(with: fallbackView)
            }
            return
        }

        //Set placeholder view
        if let placeholderView = placeholderView {
            targetView.removeAllSubviews()
            targetView.addSubviewAtFullSize(with: placeholderView)
        }

        //Check & Load cached image
        if let cachedImage = Utils.imageCache.object(forKey: urlString as NSString) as? UIImage {
            let imageView = self.createImageView(with: cachedImage, contentMode: targetView.contentMode)
            targetView.removeAllSubviews()
            targetView.addSubviewAtFullSize(with: imageView)
            didFinish?(cachedImage)
            return
        }

        if let url = URL(string: urlString) {
            // Request image.
            URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

                if error != nil {
                    DispatchQueue.main.async {
                        if let fallbackView = fallbackView {
                            targetView.removeAllSubviews()
                            targetView.addSubviewAtFullSize(with: fallbackView)
                        }
                    }
                    return
                }

                DispatchQueue.main.async {
                    if let remoteData = data, let image = UIImage(data: remoteData) {
                        //Save image to cache
                        Utils.imageCache.setObject(image, forKey: urlString as NSString)

                        //Add image
                        let imageView = self.createImageView(with: image, contentMode: targetView.contentMode)
                        targetView.removeAllSubviews()
                        targetView.addSubviewAtFullSize(with: imageView)
                        didFinish?(image)
                    } else if let fallbackView = fallbackView {
                        targetView.removeAllSubviews()
                        targetView.addSubviewAtFullSize(with: fallbackView)
                    }
                }
            }).resume()
        } else if let fallbackView = fallbackView {
            targetView.removeAllSubviews()
            targetView.addSubviewAtFullSize(with: fallbackView)
        }

        return
    }

    func createImageView(with image: UIImage?, contentMode: UIViewContentMode) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        return imageView
    }

    func loadImageWithCache(withUrl urlStr: String?, targetImageView: UIImageView, placeholderImage: UIImage?, fallbackImage: UIImage?) {
        let placeholderView = createImageView(with: placeholderImage, contentMode: targetImageView.contentMode)
        let fallbackView = createImageView(with: fallbackImage, contentMode: targetImageView.contentMode)
        loadImageFromURLWithCache(withUrl: urlStr, targetView: targetImageView, placeholderView: placeholderView, fallbackView: fallbackView)
    }
}
