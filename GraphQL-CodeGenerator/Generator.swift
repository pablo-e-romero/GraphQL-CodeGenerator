//
//  Generator.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation

public struct Generator {
    private let scalars: ScalarMap

    // MARK: - Initializer

    public init(scalars: ScalarMap) {
        self.scalars = ScalarMap.builtin.merging(
            scalars,
            uniquingKeysWith: { _, override in override }
        )
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

/*
    ```
    import Stencil

    struct Article {
      let title: String
      let author: String
    }

    let context = [
      "articles": [
        Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
        Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
      ]
    ]

    let environment = Environment(loader: FileSystemLoader(paths: ["templates/"]))
    let rendered = try environment.renderTemplate(name: "article_list.html", context: context)

    print(rendered)
    ```
 */

    /// Generates the code that can be used to define selections.
    func generate(schema: Schema) throws -> String {
        let code = """
        // This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
        import SwiftGraphQL

        // MARK: - Operations
        enum Operations {}
        \(schema.operations.map { $0 })

        // MARK: - Objects
        enum Objects {}
        \(schema.objects.map { $0 })

        // MARK: - Interfaces
        enum Interfaces {}
        \(schema.interfaces.map { $0 })

        // MARK: - Unions
        enum Unions {}
        \(schema.unions.map { $0 })

        // MARK: - Enums
        enum Enums {}
        \(schema.enums.map { $0 })

        // MARK: - Input Objects
        enum InputObjects {}
        \(schema.inputObjects.map { $0 })
        """

//        let source = try code.format()
//        return source
        return code
    }
}
