//
//  Generator.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation
import StencilSwiftKit
import Stencil
import PathKit

public struct Generator {
    private let environment: Environment

    // MARK: - Initializer

    public init(templatesPath: [Path]) {
        var environment = stencilSwiftEnvironment()
        environment.loader = FileSystemLoader(paths: templatesPath)
        self.environment = environment
    }

    // MARK: - Methods


    /// Generates a target SwiftGraphQL Selection file.
    ///
    /// - parameter from: GraphQL server endpoint.
//    public func generate(from endpoint: URL, withHeaders headers: [String: String] = [:]) throws -> String {
//        let schema = try Schema(from: endpoint, withHeaders: headers)
//        let code = try generate(schema: schema)
//        return code
//    }

    private func loadSchema(from path: Path) throws -> Schema {
        let data = try Data(contentsOf: path.url)
        let decoder = JSONDecoder()
        let result = try decoder.decode(Reponse<IntrospectionQuery>.self, from: data)
        return result.data.schema
    }

    private func buildContext(from schema: Schema) -> [String: Any] {
        let unions = schema.unions.map(Stencil.Union.init)
        let unionsPossibleObjectsName = Set(schema.unions.flatMap { $0.possibleTypes.map(\.name) })

        let objects = schema.objects
            // Objects that are part of an Union are excluded.
            .filter { !unionsPossibleObjectsName.contains($0.name) }
            .map(Stencil.Object.init)

        var unionObjectsByName: [String: Stencil.Object] = [:]
        schema.objects
            .filter { unionsPossibleObjectsName.contains($0.name) }
            .map(Stencil.Object.init)
            .forEach { unionObjectsByName[$0.name] = $0 }

        let interfaces = schema.interfaces.map(Stencil.Interface.init)

        var enums = schema.enums.map(Stencil.Enum.init)
        // For now all Unions are considered enums with assoicated values.
        // We have to have some annotation or configuration setting to mark
        // which Unions have to be treat like that.
        enums += unions.map { Stencil.Enum.init($0, unionObjectsByName: unionObjectsByName) }

//        let inputObjects = schema.inputObjects.map(Stencil.InputObject.init)

        return [
//            "operations": schema.operations,
            "objects": objects,
            "interfaces": interfaces,
            "unions": unions,
            "enums": enums,
//            "inputObjects": inputObjects
        ]
    }

    func generate(schemaPath: Path, templateName: String, outputPath: Path) throws {
        let schema = try loadSchema(from: schemaPath)
        let context = buildContext(from: schema)

        var rendered = try environment.renderTemplate(
            name: templateName,
            context: context)

//        rendered = try rendered.format()

        print(rendered)

        try rendered.write(
            toFile: outputPath.string,
            atomically: true,
            encoding: .utf8)
    }
}
