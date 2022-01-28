//
//  Scalar.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation

public typealias ScalarMap = [String: String]

extension ScalarMap {
    func scalar(_ name: String) throws -> String {
        if let mapping = self[name] {
            return mapping
        }
        throw GraphQLCodegenError.unknownScalar(name)
    }
}

extension ScalarMap {
    /// A map of built-in scalars.
    static var builtin: ScalarMap {
        [
            "ID": "String",
            "String": "String",
            "Int": "Int",
            "Boolean": "Bool",
            "Float": "Double",
        ]
    }
}
