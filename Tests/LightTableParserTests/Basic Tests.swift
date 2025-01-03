import Testing
import LightTableParser

@Test
func parseEmptyArray() {
	let parser = Parser(subject: [])
	
	let isAtEnd = parser.isAtEnd
	#expect(isAtEnd)
	
	let head = parser.head()
	#expect(head == nil)
}

@Test
func parseSingleElement() {
	var parser = Parser(subject: CollectionOfOne(5))
	let head = parser.head()
	#expect(head == 5)
	
	parser.advance()
	
	let isAtEnd = parser.isAtEnd
	#expect(isAtEnd)
	
	let head2 = parser.head()
	#expect(head2 == nil)
}
