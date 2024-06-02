import XCTest
@testable import DynamicDecodable

final class DynamicDecodableTests: XCTestCase {
    
    let json1 =
    """
    {
      "string": "exampleString",
      "bool": true,
      "boolAsInt": 1,
      "boolAsString": "true",
      "int": 123,
      "double": 123.45,
      "doubleAsString": "123.45",
      "dateAsTimeInterval": 1685903461,
      "dateAsISOString": "2024-06-01T12:31:01Z",
      "enumAsString": "buy"
    }
    """.data(using: .utf8)!
    
    let json2 =
    """
    {
      "items": [
        {
          "id": 1,
          "name": "Item One",
          "is_active": true
        },
        {
          "id": 2,
          "name": "Item Two",
          "is_active": false
        },
        {
          "id": 3,
          "name": "Item Three",
          "is_active": true
        }
      ]
    }
    """.data(using: .utf8)!
    
    enum Trade: String {
        case buy
        case sell
    }
    
    struct Item: Equatable {
        var text: String = ""
        var flag: Bool = false
        var value: Int = 0
        var amount: Decimal = 0
        var date: Date = .now
        var trade: Trade = .sell
    }
    
    func testPlainDictionary() throws {
        let data = try DynamicDecodable(json1)
        
        XCTAssertTrue(data.string == "exampleString")
        XCTAssertTrue(data.bool == true)
        XCTAssertTrue(data.boolAsInt == true)
        XCTAssertTrue(data.double == 123.45)
        XCTAssertTrue(data.doubleAsString == 123.45)
    }
    
    func testDecodeArray() throws {
        let data = try DynamicDecodable(json2)

        XCTAssertEqual(data.items?.array?.count, 3)
        XCTAssertTrue(data.items?[0]?.id == 1)
        XCTAssertTrue(data.items?[2]?.id == 3)
        XCTAssertTrue(data.items?[1]?.isActive == false)
        XCTAssertTrue(data.items?[1]?.name == "Item Two")
        XCTAssertTrue(data.items?[0]?.is_active == true)
    }
    
    func testMapping() throws {
        let data = try DynamicDecodable(json1)
        
        let sampleItem = Item(
            text: "exampleString",
            flag: true,
            value: 123,
            amount: 123.45,
            date: Date(timeIntervalSince1970: 1685903461),
            trade: .buy
        )
        
        var item1 = Item()
        item1.text <- data.string
        item1.flag <- data.boolAsInt
        item1.value <- data.int
        item1.amount <- data.double
        item1.trade <- data.enumAsString
        item1.date <- data.dateAsTimeInterval
        
        XCTAssertEqual(item1, sampleItem)
    }
    
    func testComparable() throws {
        let data = try DynamicDecodable(json1)
        
        XCTAssertTrue(data.double < 250)
        XCTAssertTrue(data.double > 100)
        
        let data2 = try DynamicDecodable(json2)
        let item1 = data2.items?.array?.first { $0.id == 2 }
        XCTAssertEqual(item1?.name?.stringValue, "Item Two")
        
    }
    
    func testDateFormats() throws {
        DynamicDecodable.dateFormats.append("yyyy-MM-dd")
        
        let json3 =
        """
        { 
            "date": "2000-01-01",
            "created_at": "2024-05-06T14:05:23.000000Z"
        }
        """.data(using: .utf8)!
        
        let testDate = DateComponents(year: 2000, month: 01, day: 01).date
        
        let item = try DynamicDecodable(json3)
        XCTAssertEqual(item.dateValue, testDate)
        XCTAssertNotNil(item.createdAt)
    }
}
