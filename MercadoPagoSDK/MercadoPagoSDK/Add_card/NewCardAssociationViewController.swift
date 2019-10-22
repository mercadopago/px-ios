//
//  NewCardAssociationViewController.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 21/10/2019.
//

import Foundation
import UIKit

protocol PXAddCardProtocol: NSObjectProtocol {
    func didAddCard(cardInfo: [String: String])
}

class NewCardAssociationViewController: MercadoPagoUIViewController {

    private let model: String
    private var callback: (([String: String]) -> Void)?
    weak var delegate: PXAddCardProtocol?


    init(model: String, callback: @escaping ([String: String]) -> Void) {
        self.model = model
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }

    init(model: String) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nueva alta de tarjeta"
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 300)
        ])

        let labelOK = UILabel()
        labelOK.translatesAutoresizingMaskIntoConstraints = false
        labelOK.text = "Alta de tarjeta finalizada OK"
        labelOK.textAlignment = .center
        labelOK.textColor = .blue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addCard))
        labelOK.addGestureRecognizer(tapGesture)
        labelOK.isUserInteractionEnabled = true
        view.addSubview(labelOK)
        NSLayoutConstraint.activate([
            labelOK.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelOK.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            labelOK.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension NewCardAssociationViewController {
    @objc func addCard() {
        print("Estoy agregando la tarjeta")
        var cardInfo = [String: String]()
        cardInfo["cardId"] = "123456"
//        if let callback = callback {
//            callback(cardInfo)
//        }
        delegate?.didAddCard(cardInfo: cardInfo)
    }
}
