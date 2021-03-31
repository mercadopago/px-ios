//
//  DataExtensions.swift
//  ExampleSwift
//
//  Created by Matheus Leandro Martins on 31/03/21.
//  Copyright © 2021 Juan Sebastian Sanzone. All rights reserved.
//

import Foundation


extension Data {
    //MARK: - Support method, to debug requests
    func mapToJSON() throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            fatalError()
        }
    }
}
