//
//  MercadoPagoServices+Reachability.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 03/09/2020.
//

import Foundation
// Se importa MLCardForm para reutilizar la clase de Reachability
import MLCardForm

protocol InternetConnectionProtocol: NSObjectProtocol {
    func hasInternetConnection() -> Bool
}

extension MercadoPagoServices: InternetConnectionProtocol {
    func hasInternetConnection() -> Bool {
        return hasInternet
    }

    func reachabilityChanged(_ isReachable: Bool) {
        hasInternet = isReachable
    }

    func addReachabilityObserver() {
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to add reachability observer")
        }

        reachability?.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }

        reachability?.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }

        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    func removeReachabilityObserver() {
        reachability?.stopNotifier()
        reachability = nil
    }
}
