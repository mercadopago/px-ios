import Foundation

@objc internal protocol CardData {
    var name: String { get set }
    var number: String { get set }
    var expiration: String { get set }
    var securityCode: String { get set }
}
