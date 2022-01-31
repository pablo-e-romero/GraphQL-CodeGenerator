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

enum Stencil {

    public struct Object {
        public let name: String
        public let description: String?

        public let fields: [Stencil.Field]
        //    public let interfaces: [InterfaceTypeRef]?

        init(_ objectType: ObjectType) {
            self.name = objectType.name
            self.description = objectType.description
            self.fields = objectType.fields.map(Stencil.Field.init)
        }
    }

    public struct Field {
        public let name: String
        public let description: String?
        //   public let args: [InputValue]
        public let typeName: String
        public let isDeprecated: Bool
        public let deprecationReason: String?

        init(_ fieldType: GraphQL_CodeGenerator.Field) {
            self.name = fieldType.name
            self.description = fieldType.description
            self.typeName = fieldType.stencilTypeName
            self.isDeprecated = fieldType.isDeprecated
            self.deprecationReason = fieldType.deprecationReason
        }
    }

    public struct Enum {
        public let name: String
        public let description: String?

        public let values: [EnumValue]

        init(_ enumType: EnumType) {
            self.name = enumType.name
            self.description = enumType.description
            self.values = enumType.enumValues.map(EnumValue.init)
        }
    }

    public struct EnumValue {
        public let name: String
        public let description: String?
        public let isDeprecated: Bool
        public let deprecationReason: String?

        init(_ enumValueType: GraphQL_CodeGenerator.EnumValue) {
            self.name = enumValueType.name
            self.description = enumValueType.description
            self.isDeprecated = enumValueType.isDeprecated
            self.deprecationReason = enumValueType.deprecationReason
        }
    }

}
