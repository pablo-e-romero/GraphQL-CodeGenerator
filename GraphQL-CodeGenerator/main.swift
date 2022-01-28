//
//  main.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import ArgumentParser
import Files
import Foundation

struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for doing some GraphQL magic 🦄.",
        subcommands: [Build.self, Instrospect.self],
        defaultSubcommand: Build.self)
}

extension Generate {
    struct Build: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Generates code from a local schame.")

//        @Argument(help: "Location to schema")
//        var schemaFile: String

        mutating func run() {
//            let config: Config
//
//            if let configPath = self.config {
//                let raw = try Folder.current.file(at: configPath).read()
//                config = try Config(from: raw)
//            } else {
//                config = Config()
//            }
//            print("build \(schemaFile)")
            let generator = Generator(scalars: Configuration().scalars)
            let file = try! Folder.current.file(named: "schema.json")
            let data = try! Data(contentsOf: file.url)
            let decoder = JSONDecoder()
            let result = try! decoder.decode(Reponse<IntrospectionQuery>.self, from: data)

            let code = try! generator.generate(schema: result.data.schema)
            print(code)
        }
    }

    struct Instrospect: ParsableCommand {
        static var configuration
            = CommandConfiguration(abstract: "Instrospects a schema from a given endpoint.")

        @Argument(help: "Endpoint to be Instrospected.")
        var endpoint: String

        mutating func run() {
            print("instrospect \(endpoint)")
        }
    }
}

Generate.main()
