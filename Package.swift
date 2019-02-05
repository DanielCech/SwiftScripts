// swift-tools-version:4.0

/**
 *  SwiftScripts
 *  Copyright (c) Daniel Cech 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "SwiftScripts",
    products: [
        .library(name: "SwiftScripts", targets: ["SwiftScripts"])
    ],
    targets: [
        .target(
            name: "SwiftScripts",
            path: "Sources"
        )
    ]
)
