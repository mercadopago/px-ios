//
//  UIImageView+Extension.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/07/2020.
//

import Foundation

extension UIImageView {
    func setRemoteImage(imageUrl: String, customCache: URLCache? = nil, placeHolderColor: UIColor = .clear, success: ((UIImage) -> Void)? = nil) {
        guard let url = URL(string: imageUrl) else { return }
        let cache = customCache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
            success?(image)
            printDebug("Retrieve image from Cache")
        } else {
            self.backgroundColor = placeHolderColor
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    printDebug("Retrieve image from Network")
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                            guard let self = self else { return }
                            self.backgroundColor = .clear
                            self.image = image
                        }, completion: { _ in
                            success?(image)
                        })
                    }
                }
            }).resume()
        }
    }
}
