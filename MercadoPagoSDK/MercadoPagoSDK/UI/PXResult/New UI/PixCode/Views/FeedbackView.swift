//
//  FeedbackView.swift
//  MercadoPagoSDKV4
//
//  Created by Matheus Leandro Martins on 13/05/21.
//

import UIKit
import AndesUI

final class FeedbackView: UIView {
    // MARK: - Private properties
    private let feedbackMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ml_regularSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Initialization
    private init(feedbackMessage: String) {
        super.init(frame: .zero)
        setupViewConfiguration()
        feedbackMessageLabel.text = feedbackMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func showFeedbackView(show feedbackMessage: String, in view: UIView) {
        let feedbackView = FeedbackView(feedbackMessage: feedbackMessage)
        view.addSubviews(views: [feedbackView])
        view.bringSubviewToFront(feedbackView)
        
        NSLayoutConstraint.activate([
            feedbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            feedbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            feedbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            feedbackView.layoutIfNeeded()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.3, animations: {
                feedbackView.alpha = 0
                feedbackView.layoutIfNeeded()
            })
        }
    }
}

extension FeedbackView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [feedbackMessageLabel])
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            feedbackMessageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            feedbackMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            feedbackMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            feedbackMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func viewConfigure() {
        self.backgroundColor = .black
        layer.cornerRadius = 6
    }
}
