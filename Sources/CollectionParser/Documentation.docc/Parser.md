# ``Parser``

## Topics

### Creating Parsers

- ``Parser/init(subject:)``
- ``Parser/init(subject:position:)``

### Parser State

The position is the only mutable state of the parser.

- ``Parser/subject``
- ``Parser/position``

### Remaining Subject

- ``Parser/remainder()``
- ``Parser/isAtEnd``

### Peeking Ahead

Look ahead by peeking at the next elements without advancing the parser.

- ``Parser/peek()-1zib3``
- ``Parser/peek()-2q40y``
- ``Parser/peek()-76suw``

### Remainder Prefix

Look ahead by matching the prefix of the remainder without advancing the parser.

- ``Parser/hasPrefix(_:)-5sp1u``
- ``Parser/hasPrefix(_:)-71nio``
- ``Parser/hasPrefix(_:)-6dwmk``
- ``Parser/hasPrefix(_:)-215bz``

### Reading Elements

Read the current element, advancing the parser on success.

- ``Parser/pop()``
- ``Parser/pop(_:)``
- ``Parser/pop(where:)``

### Reading Subsequences

Read elements, advancing the parser on success.

- ``Parser/read(_:)-35dei``
- ``Parser/read(_:)-2o7et``
- ``Parser/read(count:)``
- ``Parser/read(while:)``
- ``Parser/read(_:)-23mio``

### Advancing the Parser

Advance the parser position without reading elements.

- ``Parser/advance()``
- ``Parser/advance(by:)``
- ``Parser/advance(while:)-22vnw``
- ``Parser/advance(while:)-414fk``
- ``Parser/advance(matching:)``

### Views

Work with different views of the subject.

- ``Parser/withView(_:_:)``
