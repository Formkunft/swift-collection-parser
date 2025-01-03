# ``Parser``

## Topics

### Parsing a Subject

- ``init(subject:)``
- ``headIndex``
- ``subject``

### Accessing the Subject

These methods and properties report the current state of the parser.

- ``isAtEnd``
- ``head()``
- ``rest()``

### Advancing the Parser

These methods advance the parser by moving the head index further along the collection.

- ``advance()``
- ``advance(by:)``
- ``advance(matching:)``
- ``advance(while:)-6haou``
- ``advance(while:)-1zv5r``

### Reading Elements and Subsequences

These methods advance the parser if a predicate matches and return the match.

- ``read()``
- ``read(_:)-56a25``
- ``read(_:)-60ab9``
- ``read(_:)-1edd2``
- ``read(_:)-6jmak``
- ``read(count:)``
- ``read(where:)``
- ``read(while:)``

### Checking the Rest Prefix

These methods check the remaining elements (“rest”) for a given prefix.

- ``hasPrefix(_:)-aqzz``
- ``hasPrefix(_:)-7f4h9``
- ``hasPrefix(_:)-6v5wx``
- ``hasPrefix(_:)-3q3q``

### Checking the Tail Prefix

These methods inspect the elements after the head element.

- ``tailPrefix()-9crvl``
- ``tailPrefix()-10fyc``
