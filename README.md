# Swift Collection Parser

Swift Collection Parser is a package for a type `Parser<Subject: Collection>`.

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
