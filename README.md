# Swift Collection Parser

Swift Collection Parser is a package for a type `Parser<Subject: Collection>`.

- [Documentation](https://swiftpackageindex.com/Formkunft/swift-collection-parser/documentation/collectionparser)
- [Swift Package Index](https://swiftpackageindex.com/Formkunft/swift-collection-parser)

## Description

The `Parser` type provides a simple parser that can be used to parse arbitrary collections.

```swift
var parser = Parser(subject: data)

guard let version = parser.pop() else {
    throw DecodingError.missingVersion
}
guard let string = String(bytes: parser.read(while: { $0 != 0 }), encoding: .utf8),
      parser.pop(0) else {
    throw DecodingError.invalidStringValue
}
```

## Using Swift Collection Parser in your project

Add `swift-collection-parser` as a dependency to your package:

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/Formkunft/swift-collection-parser.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            // ...
            dependencies: [
                .product(name: "CollectionParser", package: "swift-collection-parser"),
            ]),
    ]
)
```

Then, import `CollectionParser` in your code:

```swift
import CollectionParser

// ...
```
