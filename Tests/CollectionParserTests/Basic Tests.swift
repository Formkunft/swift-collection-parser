import Testing
import CollectionParser

@Test
func parseEmptyArray() {
	let parser = Parser(subject: [])
	
	let isAtEnd = parser.isAtEnd
	#expect(isAtEnd)
	
	let head = parser.peek()
	#expect(head == nil)
}

@Test
func parseSingleElement() {
	var parser = Parser(subject: CollectionOfOne(5))
	let head = parser.peek()
	#expect(head == 5)
	
	parser.advance()
	
	let isAtEnd = parser.isAtEnd
	#expect(isAtEnd)
	
	let head2 = parser.peek()
	#expect(head2 == nil)
}
