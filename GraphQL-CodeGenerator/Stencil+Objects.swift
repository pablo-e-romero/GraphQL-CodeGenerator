//
//  Stencil+Objects.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 29/1/22.
//

import Foundation

private func obtainTypeName<T: TypeDescription>(from type: TypeRef<T>) -> String {
    let namedType = type.namedType
    var typeName = type.namedType.name

    if namedType.isScalar, let scalarName = try? scalarMap.scalar(typeName) {
        typeName = scalarName
    }

    return typeName
}

private func isTypeOptional<T>(_ type: TypeRef<T>) -> Bool {
    guard case .nonNull = type else { return true }
    return false
}

private func isTypeArray<T>(_ type: TypeRef<T>) -> Bool {
    switch type {
    case .list: return true
    case .named: return false
    case let .nonNull(typeref):
        return isTypeArray(typeref)
    }
}

private func processDescriptionLines(_ value: String?) -> (isEmpty: Bool, lines: [String]) {
    guard let value = value else { return (true, []) }
    let descriptionLines: [String] = value.split(separator: "\n").map(String.init)
    return (isEmpty: descriptionLines.isEmpty, lines: descriptionLines)
}

private func processDeprecationReason(_ value: String?) -> (isEmpty: Bool, value: String?) {
    guard let value = value, !value.isEmpty else { return (true, nil) }
    return (isEmpty: false, value: value)
}

enum Stencil {

    public struct Object {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]

        public let fields: [Stencil.Field]
        //    public let interfaces: [InterfaceTypeRef]?

        init(_ objectType: ObjectType) {
            self.name = objectType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(objectType.description)
            self.fields = objectType.fields.map(Stencil.Field.init)
        }
    }

    public struct Field {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        //   public let args: [InputValue]
        public let typeName: String
        public let isDeprecated: Bool
        public let hasDeprecationReason: Bool
        public let deprecationReason: String?
        public let isOptional: Bool
        public let isArray: Bool

        init(_ fieldType: GraphQL_CodeGenerator.Field) {
            self.name = fieldType.name.normalize

            (self.hasDescription, self.descriptionLines) = processDescriptionLines(fieldType.description)
            self.typeName = obtainTypeName(from: fieldType.type)

            self.isDeprecated = fieldType.isDeprecated
            (self.hasDeprecationReason, self.deprecationReason) = processDeprecationReason(fieldType.deprecationReason)

            self.isOptional = isTypeOptional(fieldType.type)
            self.isArray = isTypeArray(fieldType.type)
        }
    }

    public struct Enum {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]

        public let values: [EnumValue]

        init(_ enumType: EnumType) {
            self.name = enumType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(enumType.description)
            self.values = enumType.enumValues.map(EnumValue.init)
        }
    }

    public struct EnumValue {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let isDeprecated: Bool
        public let hasDeprecationReason: Bool
        public let deprecationReason: String?

        init(_ enumValueType: GraphQL_CodeGenerator.EnumValue) {
            self.name = enumValueType.name.normalize
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(enumValueType.description)
            self.isDeprecated = enumValueType.isDeprecated
            (self.hasDeprecationReason, self.deprecationReason) = processDeprecationReason(enumValueType.deprecationReason)
        }
    }

}
