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
    private let environment: Environment

    // MARK: - Initializer

    public init(templatesPaths: [Path]) {
        // TODO: add extensions
        self.environment = Environment(
            loader: FileSystemLoader(paths: templatesPaths),
            templateClass: StencilSwiftTemplate.self)
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
//            "operations": schema.operations,
            "objects": schema.objects.map(Stencil.Object.init),
//            "interfaces": schema.interfaces,
//            "unions": schema.unions,
            "enums": schema.enums.map(Stencil.Enum.init),
//            "inputObjects": schema.inputObjects
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
