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

private let emptyTypeAlias = "unused"

private func processDescriptionLines(_ value: String?) -> (hasDescription: Bool, lines: [String]) {
    guard let value = value, !value.isEmpty else { return (false, []) }
    let descriptionLines: [String] = value.split(separator: "\n").map(String.init)
    return (hasDescription: true, lines: descriptionLines)
}

private func processDeprecationReason(_ value: String?) -> (hasDescription: Bool, value: String?) {
    guard let value = value, !value.isEmpty else { return (false, nil) }
    return (hasDescription: true, value: value)
}

enum Stencil {

    public struct Union {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let possibleTypesName: [String]

        public init(_ unionType: UnionType) {
            self.name = unionType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(unionType.description)
            self.possibleTypesName = unionType.possibleTypes.map(\.name)
        }
    }

    public struct Interface {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let fields: [Stencil.Field]
        public let interfacesName: [String]?
        public let possibleTypesName: [String]

        public init(_ interfaceType: InterfaceType) {
            self.name = interfaceType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(interfaceType.description)
            self.fields = interfaceType.fields.map(Stencil.Field.init)
            self.interfacesName = interfaceType.interfaces.map { $0.map(\.name) }
            self.possibleTypesName = interfaceType.possibleTypes.map(\.name)
        }
    }

    public struct Object {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let fields: [Stencil.Field]
        public let conformsSomeInterface: Bool
        public let interfacesName: [String]

        public init(_ objectType: ObjectType) {
            self.name = objectType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(objectType.description)
            self.fields = objectType.fields.map(Stencil.Field.init)
            let interfaces = objectType.interfaces.map { $0.map(\.name) } ?? []
            self.conformsSomeInterface = !interfaces.isEmpty
            self.interfacesName = interfaces
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

        public init(_ fieldType: GraphQL_CodeGenerator.Field) {
            self.name = fieldType.name.normalize
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(fieldType.description)
            self.typeName = obtainTypeName(from: fieldType.type)
            self.isDeprecated = fieldType.isDeprecated
            (self.hasDeprecationReason, self.deprecationReason) = processDeprecationReason(fieldType.deprecationReason)
            self.isOptional = isTypeOptional(fieldType.type)
            self.isArray = isTypeArray(fieldType.type)
        }
    }

    public struct InputObject {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let inputFields: [Stencil.InputField]

        public init(_ inputObjectType: InputObjectType) {
            self.name = inputObjectType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(inputObjectType.description)
            self.inputFields = inputObjectType.inputFields.map(Stencil.InputField.init)
        }
    }

    public struct InputField {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let typeName: String
        public let isOptional: Bool
        public let isArray: Bool

        public init(_ inputType: InputValue) {
            self.name = inputType.name.normalize
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(inputType.description)
            self.typeName = obtainTypeName(from: inputType.type)
            self.isOptional = isTypeOptional(inputType.type)
            self.isArray = isTypeArray(inputType.type)
        }
    }

    public struct Enum {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]

        public let values: [EnumValue]

        public init(_ enumType: EnumType) {
            self.name = enumType.name
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(enumType.description)
            self.values = enumType.enumValues.map(EnumValue.init)
        }

        public init(_ union: Stencil.Union, unionObjectsByName: [String: Stencil.Object]) {
            self.name = union.name
            self.hasDescription = union.hasDescription
            self.descriptionLines = union.descriptionLines
            self.values = union.possibleTypesName
                .compactMap { unionObjectsByName[$0] }
                .map { EnumValue.init($0, prefix: union.name) }
        }
    }

    public struct EnumValue {
        public let name: String
        public let hasDescription: Bool
        public let descriptionLines: [String]
        public let isDeprecated: Bool
        public let hasDeprecationReason: Bool
        public let deprecationReason: String?
        public let hasAssociatedValues: Bool
        public let associatedValues: [EnumAssociatedValue]?

        public init(_ enumValueType: GraphQL_CodeGenerator.EnumValue) {
            self.name = enumValueType.name.normalize
            (self.hasDescription, self.descriptionLines) = processDescriptionLines(enumValueType.description)
            self.isDeprecated = enumValueType.isDeprecated
            (self.hasDeprecationReason, self.deprecationReason) = processDeprecationReason(enumValueType.deprecationReason)
            self.hasAssociatedValues = false
            self.associatedValues = nil
        }

        public init(_ object: Object, prefix: String) {
            self.name = object.name
                .replacingOccurrences(of: prefix, with: "")
                .camelCase
                .normalize
            
            self.hasDescription = object.hasDescription
            self.descriptionLines = object.descriptionLines

            self.isDeprecated = false
            self.hasDeprecationReason = false
            self.deprecationReason = nil

            let associatedValues = object.fields
                .filter { $0.name != emptyTypeAlias}
                .map(EnumAssociatedValue.init)
            self.associatedValues = associatedValues
            self.hasAssociatedValues = !associatedValues.isEmpty
        }
    }

    public struct EnumAssociatedValue {
        public let name: String
        public let typeName: String
        public let isOptional: Bool
        public let isArray: Bool

        init(_ field: Stencil.Field) {
            self.name = field.name
            self.typeName = field.typeName
            self.isOptional = field.isOptional
            self.isArray = field.isArray
        }
    }

}
