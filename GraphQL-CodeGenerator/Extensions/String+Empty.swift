//
//  String+Empty.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 31/1/22.
//

import Foundation

extension Optional where Wrapped == String {
    var nilIfEmpty: Wrapped? {
        return flatMap { $0.isEmpty ? nil : $0 }
    }
}
