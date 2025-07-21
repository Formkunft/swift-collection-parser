//
//  Copyright 2025 Florian Pircher
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// A parser for accessing the elements of a collection.
public struct Parser<Subject: Collection> {
	public typealias Index = Subject.Index
	public typealias Element = Subject.Element
	public typealias SubSequence = Subject.SubSequence
	
	/// The collection that is parsed by the parser.
	public let subject: Subject
	/// The index of the current element, which is the next element to be parsed.
	public var position: Index
	
	/// Creates a parser for parsing the given collection.
	///
	/// The initial position is set to the start index of the collection.
	@inlinable
	public init(subject: Subject) {
		self.subject = subject
		self.position = subject.startIndex
	}
	
	/// Creates a parser for parsing the given collection from the given position.
	@inlinable
	public init(subject: Subject, position: Index) {
		self.subject = subject
		self.position = position
	}
	
	// MARK: State
	
	/// Whether the parser is at the end of the subject and no more elements can be read.
	@inlinable
	public var isAtEnd: Bool {
		self.position == self.subject.endIndex
	}
	
	/// Returns the currently unparsed part of the subject, or an empty subsequence if the parser is at the end of the subject.
	@inlinable
	public func remainder() -> SubSequence {
		guard !self.isAtEnd else {
			return self.subject[self.subject.endIndex ..< self.subject.endIndex] // at end: return empty subsequence
		}
		return self.subject[self.position ..< self.subject.endIndex]
	}
	
	// MARK: Advance
	
	/// Advances the parser by one element.
	///
	/// > Important: Only call this method if the parser is not at the end.
	/// > Otherwise, the call will result in a fatal error.
	@inlinable
	public mutating func advance() {
		self.position = self.subject.index(after: self.position)
	}
	
	/// Advances the parser by the given number of elements.
	///
	/// > Important: Only call this method if advancing the parser by the given distance does not move past the start or end of the subject.
	/// > Otherwise, the call will result in a fatal error.
	@inlinable
	public mutating func advance(by distance: Int) {
		self.position = self.subject.index(self.position, offsetBy: distance)
	}
	
	/// Advances the parser while `predicate` returns `true`.
	///
	/// If the parser reaches the end of the subject, it will stop advancing.
	///
	/// ## Examples
	///
	/// Skip whitespace:
	///
	/// ```swift
	/// parser.advance(while: \.isWhitespace)
	/// ```
	///
	/// Skip letters until an `x` is encountered:
	///
	/// ```swift
	/// parser.advance(while: { $0.isLetter && $0 != "x" })
	/// ```
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element.
	@inlinable
	public mutating func advance<E>(while predicate: (Element) throws(E) -> Bool) throws(E) {
		while let element = self.peek(), try predicate(element) {
			self.advance()
		}
	}
	
	/// Advances the parser while `predicate` returns `true`, providing the parser for inspection.
	///
	/// If the parser reaches the end of the subject, it will stop advancing.
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element. The second parameter is the parser itself, borrowed for further inspection of the subject.
	@inlinable
	public mutating func advance<E>(
		while predicate: (
			_ element: Element,
			_ parser: borrowing Self
		) throws(E) -> Bool
	) throws(E) {
		while let element = self.peek(), try predicate(element, self) {
			self.advance()
		}
	}
	
	#if !$Embedded
	/// Advances the parser by matching the given regex against the prefix of the remainder of the subject.
	///
	/// If the regex does not match the prefix of the remainder of the subject, the parser will not be advanced.
	///
	/// - Parameter regex: The regex to match.
	/// - Throws: This method can throw an error if this regex includes a transformation closure that throws an error.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@inlinable
	public mutating func advance(matching regex: some RegexComponent) throws where SubSequence == Substring {
		guard let match = try regex.regex.prefixMatch(in: self.remainder()) else {
			return
		}
		self.position = match.range.upperBound
	}
	#endif
	
	// MARK: Peek
	
	/// Returns the current element, or `nil` if the parser is at the end of the subject.
	@inlinable
	public func peek() -> Element? {
		guard !self.isAtEnd else {
			return nil
		}
		return self.subject[self.position]
	}
	
	/// Returns the next two elements, if available.
	@_disfavoredOverload
	@inlinable
	public func peek() -> (Element, Element)? {
		guard let a = self.peek() else {
			return nil
		}
		let bIndex = self.subject.index(after: self.position)
		guard bIndex < self.subject.endIndex else {
			return nil
		}
		return (a, self.subject[bIndex])
	}
	
	/// Returns the next three elements, if available.
	@_disfavoredOverload
	@inlinable
	public func peek() -> (Element, Element, Element)? {
		guard let a = self.peek() else {
			return nil
		}
		let bIndex = self.subject.index(after: self.position)
		guard bIndex < self.subject.endIndex else {
			return nil
		}
		let cIndex = self.subject.index(after: bIndex)
		guard cIndex < self.subject.endIndex else {
			return nil
		}
		return (a, self.subject[bIndex], self.subject[cIndex])
	}
	
	// MARK: Has Prefix
	
	/// Returns whether the current element is equal to the given element.
	@inlinable
	public func hasPrefix(_ element: Element) -> Bool where Element: Equatable {
		self.peek() == element
	}
	
	/// Returns whether the remainder of the subject starts with the given prefix.
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ prefix: some StringProtocol) -> Bool where Subject: StringProtocol {
		self.remainder().hasPrefix(prefix)
	}
	
	/// Returns whether the remainder of the subject starts with the given prefix.
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ prefix: SubSequence) -> Bool where SubSequence: Equatable {
		self.remainder().prefix(prefix.count) == prefix
	}
	
	#if !$Embedded
	/// Returns whether the prefix of the remainder of the subject matches the given regex.
	///
	/// If the regex includes a transformation closure that throws an error, the error will be ignored and `false` will be returned.
	///
	/// - Parameter regex: The regex to match.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ regex: some RegexComponent) -> Bool where SubSequence == Substring {
		self.remainder().prefixMatch(of: regex) != nil
	}
	#endif
	
	// MARK: Pop
	
	/// Returns the current element and advances the parser, or returns `nil` if the parser is at the end of the subject.
	@inlinable
	public mutating func pop() -> Element? {
		guard let element = self.peek() else {
			return nil
		}
		self.advance()
		return element
	}
	
	/// Returns whether the current element is equal to the given element, and advances the parser by that element if so.
	@inlinable
	public mutating func pop(_ element: Element) -> Bool where Element: Equatable {
		if self.hasPrefix(element) {
			self.advance()
			return true
		}
		return false
	}
	
	/// Returns the current element if it matches the given predicate, and advances the parser by that element if so.
	///
	/// - Returns: The current element if it matches the given predicate, or `nil` if the parser is at the end of the subject or the current element does not match the given predicate.
	@inlinable
	public mutating func pop<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Element? {
		guard let element = self.peek(), try predicate(element) else {
			return nil
		}
		self.advance()
		return element
	}
	
	// MARK: Read
	
	/// Returns a prefix of the remainder of the subject matching the given element count and advances the parser, or `nil`, if the remainder is shorter then the count.
	@inlinable
	public mutating func read(count: UInt) -> SubSequence? {
		let count = Int(count)
		let sliceStartIndex = self.position
		guard let sliceEndIndex = self.subject.index(sliceStartIndex, offsetBy: count, limitedBy: self.subject.endIndex) else {
			return nil
		}
		self.advance(by: count)
		return self.subject[sliceStartIndex ..< sliceEndIndex]
	}
	
	/// Returns whether the remainder of the subject starts with the given prefix, and advances the parser by that prefix if so.
	@inlinable
	public mutating func read(_ subsequence: SubSequence) -> Bool where SubSequence: Equatable {
		if self.hasPrefix(subsequence) {
			self.advance(by: subsequence.count)
			return true
		}
		return false
	}
	
	/// Returns whether the remainder of the subject starts with the given prefix, and advances the parser by that prefix if so.
	@_disfavoredOverload
	@inlinable
	public mutating func read(_ string: some StringProtocol) -> Bool where Subject: StringProtocol {
		if self.hasPrefix(string) {
			self.advance(by: string.count)
			return true
		}
		return false
	}
	
	/// Returns a prefix containing the elements until `predicate` returns `false`, and advances the parser by that prefix if so.
	///
	/// If the parser reaches the end of the subject, it will stop reading.
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element.
	@inlinable
	public mutating func read<E>(while predicate: (Element) throws(E) -> Bool) throws(E) -> SubSequence {
		let prefix: SubSequence
		do {
			prefix = try self.remainder().prefix(while: predicate)
		}
		catch let error as E {
			throw error
		}
		catch {
			preconditionFailure("unreachable")
		}
		self.advance(by: prefix.count)
		return prefix
	}
	
	#if !$Embedded
	/// Returns the match of the given regex if it matches the prefix of the remainder of the subject, and advances the parser by the match if so.
	///
	/// - Parameter regex: The regex to match.
	/// - Throws: This method can throw an error if this regex includes a transformation closure that throws an error.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@_disfavoredOverload
	@inlinable
	public mutating func read<R: RegexComponent>(_ regex: R) throws -> Regex<R.RegexOutput>.Match? where SubSequence == Substring {
		guard let match = try regex.regex.prefixMatch(in: self.remainder()) else {
			return nil
		}
		self.position = match.range.upperBound
		return match
	}
	#endif
	
	// MARK: View
	
	/// Creates a nested parser that operates on a view of the subject.
	///
	/// The view must share indices with the subject.
	/// Most importantly, the current parser position must be valid for the view as it will be used as the initial position of the nested parser.
	///
	/// The nested parser is provided to the given function.
	/// The return value and thrown errors are returned/rethrown by this function.
	/// After returning or throwing, the position of the nested parser is set as the position of the original parser.
	///
	/// ## Examples
	///
	/// ```swift
	/// let string = "café."
	/// var parser = Parser(subject: string.utf8)
	/// let word = parser.withView(string.unicodeScalars) { parser in
	///     String(parser.read(while: { $0.properties.isAlphabetic }))
	/// }
	/// assert(word == "café")
	/// ```
	@inlinable
	public mutating func withView<E, R, View>(
		_ view: View,
		_ code: (inout Parser<View>) throws(E) -> R
	) throws(E) -> R where View: Collection, View.Index == Index {
		var subParser = Parser<View>(subject: view, position: self.position)
		
		defer {
			self.position = subParser.position
		}
		
		return try code(&subParser)
	}
}
