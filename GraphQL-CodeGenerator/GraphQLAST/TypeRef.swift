import Foundation

// MARK: - Types

public enum IntrospectionTypeKind: String, Codable, Equatable {
    case scalar = "SCALAR"
    case object = "OBJECT"
    case interface = "INTERFACE"
    case union = "UNION"
    case enumeration = "ENUM"
    case inputObject = "INPUT_OBJECT"
    case list = "LIST"
    case nonNull = "NON_NULL"
}

// MARK: - Reference Type

public protocol TypeDescription {
    var name: String {get}
    var isScalar: Bool {get}
}

/// Represents a GraphQL type reference.
public indirect enum TypeRef<T: TypeDescription> {
    case named(T)
    case list(TypeRef)
    case nonNull(TypeRef)
}

public extension TypeRef {
    /// Returns the bottom most named type in reference.
    var namedType: TypeDescription {
        switch self {
        case let .named(type):
            return type
        case let .nonNull(subRef), let .list(subRef):
            return subRef.namedType
        }
    }

    /// Returns the bottom most type name in reference.
    var name: String {
        switch self {
        case let .named(ref):
            return ref.name
        case let .list(ref):
            return ref.namedType.name
        case let .nonNull(ref):
            return ref.namedType.name
        }
    }
}

extension TypeRef: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(IntrospectionTypeKind.self, forKey: .kind)

        switch kind {
        case .list:
            let ref = try container.decode(TypeRef<T>.self, forKey: .ofType)
            self = .list(ref)
        case .nonNull:
            let ref = try container.decode(TypeRef<T>.self, forKey: .ofType)
            self = .nonNull(ref)
        case .scalar, .object, .interface, .union, .enumeration, .inputObject:
            let named = try T(from: decoder)
            self = .named(named)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case ofType
    }
}

extension TypeRef: Equatable where T: Equatable {}

// MARK: - NamedRef

public enum NamedRef: Equatable {
    case scalar(String)
    case object(String)
    case interface(String)
    case union(String)
    case `enum`(String)
    case inputObject(String)
}

extension NamedRef: TypeDescription {
    public var name: String {
        switch self {
        case let .scalar(name), let
            .object(name), let
            .interface(name), let
            .union(name), let
            .enum(name), let
            .inputObject(name):
            return name
        }
    }

    public var isScalar: Bool {
        guard case .scalar = self else { return false }
        return true
    }
}

extension NamedRef: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .object:
            self = .object(name)
        case .interface:
            self = .interface(name)
        case .union:
            self = .union(name)
        case .enumeration:
            self = .enum(name)
        case .inputObject:
            self = .inputObject(name)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

// MARK: - ObjectRef

public enum ObjectRef: Equatable {
    case object(String)
}

extension ObjectRef: TypeDescription {
    public var name: String {
        switch self {
        case let .object(name):
            return name
        }
    }

    public var isScalar: Bool { false }
}

extension ObjectRef: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .object:
            self = .object(name)
        default:
            throw DecodingError.typeMismatch(
                OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

// MARK: - InterfaceRef

public enum InterfaceRef: Equatable {
    case interface(String)
}

extension InterfaceRef: TypeDescription {
    public var name: String {
        switch self {
        case let .interface(name):
            return name
        }
    }

    public var isScalar: Bool { false }
}

extension InterfaceRef: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .interface:
            self = .interface(name)
        default:
            throw DecodingError.typeMismatch(
                OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

// MARK: - OutpufRef

public enum OutputRef: Equatable {
    case scalar(String)
    case object(String)
    case interface(String)
    case union(String)
    case `enum`(String)
}

extension OutputRef: TypeDescription {
    public var name: String {
        switch self {
        case let .scalar(name), let
            .object(name), let
            .interface(name), let
            .union(name), let
            .enum(name):
            return name
        }
    }

    public var isScalar: Bool {
        guard case .scalar = self else { return false }
        return true
    }
}

extension OutputRef: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .object:
            self = .object(name)
        case .interface:
            self = .interface(name)
        case .union:
            self = .union(name)
        case .enumeration:
            self = .enum(name)
        default:
            throw DecodingError.typeMismatch(
                OutputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}

// MARK: - InputRef

public enum InputRef: Equatable {
    case scalar(String)
    case `enum`(String)
    case inputObject(String)
}

extension InputRef: TypeDescription {
    public var name: String {
        switch self {
        case let .scalar(name), let .enum(name), let .inputObject(name):
            return name
        }
    }

    public var isScalar: Bool {
        guard case .scalar = self else { return false }
        return true
    }
}

extension InputRef: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(NamedTypeKind.self, forKey: .kind)
        let name = try container.decode(String.self, forKey: .name)

        switch kind {
        case .scalar:
            self = .scalar(name)
        case .enumeration:
            self = .enum(name)
        case .inputObject:
            self = .inputObject(name)
        default:
            throw DecodingError.typeMismatch(
                InputRef.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldn't decode output object."
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case name
    }
}
