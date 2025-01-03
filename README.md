# LightTableParser

A Swift package for a type `Parser<Subject: Collection>`.

## Description

The `Parser` type provides a simple parser that can be used to parse arbitrary collections.

```swift
var parser = Parser(subject: data)

guard let version = parser.read() else {
	throw DecodingError.missingVersion
}
guard let string = String(bytes: parser.read(while: { $0 != 0 }), encoding: .utf8),
      parser.read() == 0 else {
	throw DecodingError.invalidStringValue
}
```
