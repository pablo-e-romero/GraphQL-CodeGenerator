//
//  Configuration.swift
//  GraphQL-CodeGenerator
//
//  Created by Pablo Romero on 28/1/22.
//

import Foundation
import Yams

/*
 swiftgraphql.yml

 ```yml
 scalars:
     Date: DateTime
 ```
 */

struct Configuration: Codable, Equatable {
    /// Key-Value dictionary of scalar mappings.
    let scalars: ScalarMap

    // MARK: - Initializers

    /// Creates an empty configuration instance.
    init() {
        scalars = ScalarMap()
    }

    /// Creates a new config instance from given parameters.
    init(scalars: ScalarMap) {
        self.scalars = scalars
    }

    /// Tries to decode the configuration from a string.
    init(from data: Data) throws {
        let decoder = YAMLDecoder()
        self = try decoder.decode(Configuration.self, from: data)
    }
}
