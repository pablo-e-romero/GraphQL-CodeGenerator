//
//  Stencil+Objects.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 29/1/22.
//

import Foundation

public extension ScalarMap {
    func name(for type: TypeDescription) -> String {
        let typeName = type.name
        guard type.isScalar else { return typeName }
        return (try? scalar(typeName)) ?? typeName
    }
}

public extension Field {
    var stencilTypeName: String {
        switch self.type {
        case let .named(type): return "\(scalarMap.name(for: type))?"
        case let .list(ref): return "[\(scalarMap.name(for: ref.namedType))]"
        case let .nonNull(ref): return scalarMap.name(for: ref.namedType)
        }
    }
}

public struct StencilObject {
    public let name: String
    public let description: String?

    public let fields: [StencilField]
//    public let interfaces: [InterfaceTypeRef]?

    init(_ objectType: ObjectType) {
        self.name = objectType.name
        self.description = objectType.description
        self.fields = objectType.fields.map(StencilField.init)
    }
}

public struct StencilField {
    public let name: String
    public let description: String?
 //   public let args: [InputValue]
    public let typeName: String
    public let isDeprecated: Bool
    public let deprecationReason: String?

    init(_ field: Field) {
        self.name = field.name
        self.description = field.description
        self.typeName = field.stencilTypeName
        self.isDeprecated = field.isDeprecated
        self.deprecationReason = field.deprecationReason
    }
}

