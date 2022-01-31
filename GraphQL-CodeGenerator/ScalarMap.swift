//
//  Scalar.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation

public var scalarMap = ScalarMap()

public struct ScalarMap: Codable, Equatable {
    private var builtin: [String: String] = [
        "ID": "String",
        "String": "String",
        "Int": "Int",
        "Boolean": "Bool",
        "Float": "Double",
    ]

    public mutating func merge(with scalarMap: ScalarMap) {
        self.builtin = self.builtin.merging(
            scalarMap.builtin,
            uniquingKeysWith: { _, override in override }
        )
    }

    public func scalar(_ name: String) throws -> String {
        if let mapping = builtin[name] {
            return mapping
        }
        throw GraphQLCodegenError.unknownScalar(name)
    }
}
