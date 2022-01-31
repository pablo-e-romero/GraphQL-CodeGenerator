//
//  Stencil+Objects.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 29/1/22.
//

import Foundation


private func stencilTypeName(for type: TypeRef<OutputRef>) -> String {
    let namedType = type.namedType
    var typeName = type.namedType.name

    if namedType.isScalar, let scalarName = try? scalarMap.scalar(typeName) {
        typeName = scalarName
    }

    switch type {
    case .named: return "\(typeName)?"
    case .list: return "[\(typeName)]"
    case .nonNull: return typeName
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
            self.name = fieldType.name.normalize
            self.description = fieldType.description
            self.typeName = stencilTypeName(for: fieldType.type)
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
            self.name = enumValueType.name.normalize
            self.description = enumValueType.description
            self.isDeprecated = enumValueType.isDeprecated
            self.deprecationReason = enumValueType.deprecationReason
        }
    }

}
