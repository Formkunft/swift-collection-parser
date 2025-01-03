//
//  Parsing.swift
//  Light Table
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
///
/// - The **advance** methods advance the parser, moving the head index further along the collection.
/// - The **read** methods advance the parser if a predicate matches and return the match.
/// - The **hasPrefix** methods check the remaining elements (“rest”) for a given prefix.
/// - The **tailPrefix** methods inspect the elements after the head element.
///
/// ```
///          rest
///      |-----------|
/// [ A, B, C, D, E, F ]
///      ↑  |--------|
///     head   tail
/// ```
///
/// The parser moves linearly through the collection by advancing a head index into the subject collection.
/// Backtracking is supported by setting the head index to a previous value.
public struct Parser<Subject: Collection>: ~Copyable {
	public typealias Index = Subject.Index
	public typealias Element = Subject.Element
	public typealias SubSequence = Subject.SubSequence
	
	/// The collection that is parsed by the parser.
	public let subject: Subject
	/// The index of the current element, which is the next element to be parsed.
	///
	/// Prefer using the methods of the parser over mutating this index directly.
	/// They provide a more descriptive API that manages the head index for you.
	///
	/// However, mutating this index is also acceptable as it is the only state of the parser.
	/// Getting and setting the index manually is needed for backtracking.
	public var headIndex: Index
	
	/// Creates a parser for parsing the given collection.
	///
	/// The head index is set to the start index of the collection.
	public init(subject: Subject) {
		self.subject = subject
		self.headIndex = subject.startIndex
	}
	
	// MARK: - Low-Level API
	
	/// Whether the parser is at the end of the subject and no more elements can be read.
	@inlinable
	public var isAtEnd: Bool {
		self.headIndex == self.subject.endIndex
	}
	
	/// Advances the parser by one element.
	///
	/// > Important: Only call this method if the parser is not at the end.
	/// > Otherwise, the call will result in a fatal error.
	@inlinable
	public mutating func advance() {
		self.headIndex = self.subject.index(after: self.headIndex)
	}
	
	/// Advances the parser by the given number of elements.
	///
	/// > Important: Only call this method if advancing the parser by the given distance does not move past the start or end of the subject.
	/// > Otherwise, the call will result in a fatal error.
	@inlinable
	public mutating func advance(by distance: Int) {
		self.headIndex = self.subject.index(self.headIndex, offsetBy: distance)
	}
	
	/// Returns the current element, or `nil` if the parser is at the end of the subject.
	@inlinable
	public func head() -> Element? {
		guard !self.isAtEnd else {
			return nil
		}
		return self.subject[self.headIndex]
	}
	
	/// Returns the currently unparsed part of the subject, or an empty subsequence if the parser is at the end of the subject.
	@inlinable
	public func rest() -> SubSequence {
		guard !self.isAtEnd else {
			return self.subject[self.subject.endIndex ..< self.subject.endIndex] // at end: return empty subsequence
		}
		return self.subject[self.headIndex ..< self.subject.endIndex]
	}
	
	// MARK: - High-Level API
	
	/// Returns whether the current element is equal to the given element.
	@inlinable
	public func hasPrefix(_ element: Element) -> Bool where Element: Equatable {
		self.head() == element
	}
	
	/// Returns whether the rest of the subject starts with the given prefix.
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ prefix: some StringProtocol) -> Bool where Subject: StringProtocol {
		self.rest().hasPrefix(prefix)
	}
	
	/// Returns whether the rest of the subject starts with the given prefix.
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ prefix: SubSequence) -> Bool where SubSequence: Equatable {
		self.rest().prefix(prefix.count) == prefix
	}
	
	/// Returns the current element and advances the parser, or returns `nil` if the parser is at the end of the subject.
	@inlinable
	public mutating func read() -> Element? {
		guard let head = self.head() else {
			return nil
		}
		self.advance()
		return head
	}
	
	/// Returns a prefix of the rest of the subject matching the given element count and advances the parser, or `nil`, if the rest is shorter then the count.
	@inlinable
	public mutating func read(count: UInt) -> SubSequence? {
		let count = Int(count)
		let sliceStartIndex = self.headIndex
		guard let sliceEndIndex = self.subject.index(sliceStartIndex, offsetBy: count, limitedBy: self.subject.endIndex) else {
			return nil
		}
		self.advance(by: count)
		return self.subject[sliceStartIndex ..< sliceEndIndex]
	}
	
	/// Returns whether the current element is equal to the given element, and advances the parser by that element if so.
	@inlinable
	public mutating func read(_ element: Element) -> Bool where Element: Equatable {
		if self.hasPrefix(element) {
			self.advance()
			return true
		}
		return false
	}
	
	/// Returns whether the rest of the subject starts with the given prefix, and advances the parser by that prefix if so.
	@_disfavoredOverload
	@inlinable
	public mutating func read(_ string: some StringProtocol) -> Bool where Subject: StringProtocol {
		if self.hasPrefix(string) {
			self.advance(by: string.count)
			return true
		}
		return false
	}
	
	/// Returns whether the rest of the subject starts with the given prefix, and advances the parser by that prefix if so.
	@_disfavoredOverload
	@inlinable
	public mutating func read(_ subsequence: SubSequence) -> Bool where SubSequence: Equatable {
		if self.hasPrefix(subsequence) {
			self.advance(by: subsequence.count)
			return true
		}
		return false
	}
	
	/// Returns the current element if it matches the given predicate, and advances the parser by that element if so.
	///
	/// - Returns: The current element if it matches the given predicate, or `nil` if the parser is at the end of the subject or the current element does not match the given predicate.
	@inlinable
	public mutating func read(where predicate: (Element) throws -> Bool) rethrows -> Element? {
		guard let head = self.head(), try predicate(head) else {
			return nil
		}
		self.advance()
		return head
	}
	
	/// Returns a prefix containing the elements until `predicate` returns `false`, and advances the parser by that prefix if so.
	///
	/// If the parser reaches the end of the subject, it will stop reading.
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element.
	@inlinable
	public mutating func read(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
		let prefix = try self.rest().prefix(while: predicate)
		self.advance(by: prefix.count)
		return prefix
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
	public mutating func advance(while predicate: (Element) throws -> Bool) rethrows {
		while let head = self.head(), try predicate(head) {
			self.advance()
		}
	}
	
	/// Advances the parser while `predicate` returns `true`, providing the parser for inspection.
	///
	/// If the parser reaches the end of the subject, it will stop advancing.
	///
	/// ## Examples
	///
	/// ```swift
	/// parser.advance { char, parser
	///     // U+2028 LINE SEPARATOR or U+2029 PARAGRAPH SEPARATOR
	///     char == 0xE2 && case (0x80, 0xA8)? = parser.tailPrefix()
	/// }
	/// ```
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element. The second parameter is the parser itself, borrowed for further inspection of the subject.
	@inlinable
	public mutating func advance(
		while predicate: (
			_ element: Element,
			_ parser: borrowing Self
		) throws -> Bool
	) rethrows {
		while let head = self.head(), try predicate(head, self) {
			self.advance()
		}
	}
	
	/// Returns the element after the head element, if available.
	@inlinable
	public func tailPrefix() -> Element? {
		guard self.headIndex < self.subject.endIndex else {
			return nil
		}
		let aIndex = self.subject.index(after: self.headIndex)
		guard aIndex < self.subject.endIndex else {
			return nil
		}
		return self.subject[aIndex]
	}
	
	/// Returns the next two elements after the head element, if available.
	@_disfavoredOverload
	@inlinable
	public func tailPrefix() -> (Element, Element)? {
		guard self.headIndex < self.subject.endIndex else {
			return nil
		}
		let aIndex = self.subject.index(after: self.headIndex)
		guard aIndex < self.subject.endIndex else {
			return nil
		}
		let bIndex = self.subject.index(after: aIndex)
		guard bIndex < self.subject.endIndex else {
			return nil
		}
		return (self.subject[aIndex], self.subject[bIndex])
	}
	
	// MARK: - Regex
	
	/// Returns whether the prefix of the rest of the subject matches the given regex.
	///
	/// If the regex includes a transformation closure that throws an error, the error will be ignored and `false` will be returned.
	///
	/// - Parameter regex: The regex to match.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@_disfavoredOverload
	@inlinable
	public func hasPrefix(_ regex: some RegexComponent) -> Bool where SubSequence == Substring {
		self.rest().prefixMatch(of: regex) != nil
	}
	
	/// Returns the match of the given regex if it matches the prefix of the rest of the subject, and advances the parser by the match if so.
	///
	/// - Parameter regex: The regex to match.
	/// - Throws: This method can throw an error if this regex includes a transformation closure that throws an error.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@_disfavoredOverload
	@inlinable
	public mutating func read<R: RegexComponent>(_ regex: R) throws -> Regex<R.RegexOutput>.Match? where SubSequence == Substring {
		guard let match = try regex.regex.prefixMatch(in: self.rest()) else {
			return nil
		}
		self.headIndex = match.range.upperBound
		return match
	}
	
	/// Advances the parser by matching the given regex against the prefix of the rest of the subject.
	///
	/// If the regex does not match the prefix of the rest of the subject, the parser will not be advanced.
	///
	/// - Parameter regex: The regex to match.
	/// - Throws: This method can throw an error if this regex includes a transformation closure that throws an error.
	@available(macOS 13.0, *, iOS 16.0, *, tvOS 16.0, *, watchOS 9.0, *)
	@inlinable
	public mutating func advance(matching regex: some RegexComponent) throws where SubSequence == Substring {
		guard let match = try regex.regex.prefixMatch(in: self.rest()) else {
			return
		}
		self.headIndex = match.range.upperBound
	}
}
