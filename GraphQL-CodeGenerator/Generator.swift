//
//  Generator.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation
import Stencil
import PathKit

public struct Generator {
    private let scalars: ScalarMap
    private let environment: Environment

    // MARK: - Initializer

    public init(scalars: ScalarMap, templatesPaths: [Path]) {
        self.scalars = ScalarMap.builtin.merging(
            scalars,
            uniquingKeysWith: { _, override in override }
        )

        self.environment = Environment(
            loader: FileSystemLoader(paths: templatesPaths),
            extensions: [],
            templateClass: Template.self)
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
        return [
            "operations": schema.operations,
            "objects": schema.objects,
            "interfaces": schema.interfaces,
            "unions": schema.unions,
            "enums": schema.enums,
            "inputObjects": schema.inputObjects
        ]
    }

    func generate(schemaPath: Path, templateName: String, outputPath: Path) throws {
        let schema = try loadSchema(from: schemaPath)
        let context = buildContext(from: schema)

        var rendered = try environment.renderTemplate(
            name: templateName,
            context: context)

        rendered = rendered.trimmingCharacters(in: CharacterSet.newlines)

        print(rendered)

        try rendered.write(
            toFile: outputPath.string,
            atomically: true,
            encoding: .utf8)
    }
}
