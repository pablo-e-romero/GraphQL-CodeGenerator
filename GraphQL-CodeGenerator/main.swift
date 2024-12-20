//
//  main.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation
import ArgumentParser
import PathKit

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

            let configuration = Configuration()

            scalarMap.merge(with: configuration.scalars)

            let generator = Generator(
                templatesPath: ["templates/"])
           
            try! generator.generate(
                schemaPath: "schema.json",
                templateName: "template.stencil",
                outputPath: "AutoGenerated.swift"
            )
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
