//
//  MsgPackTests.swift
//  MsgPackTests
//
//  Created by Damiaan on 29/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import XCTest
@testable import MsgPack

class MsgPackTests: XCTestCase {
	
	var encoder: MsgPack.Encoder!
	
	override func setUp() {
		super.setUp()
		
		encoder = Encoder()
	}
	
	//    override func tearDown() {
	//        // Put teardown code here. This method is called after the invocation of each test method in the class.
	//        super.tearDown()
	//    }
	
	func testEncodeTrue() {
		do {
			let data = try encoder.encode(true)
			XCTAssertEqual(data[0], 0xc3)
			XCTAssertEqual(data.count, 1, "Encoded data should contain only one byte")
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testEncodeFalse() {
		do {
			let data = try encoder.encode(false)
			XCTAssertEqual(data.count, 1, "Encoded data should contain only one byte, but contains \(data.count)")
			XCTAssertEqual(data[0], 0xc2)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testEncodeUInt8() {
		do {
			let number: UInt8 = 5
			let data = try encoder.encode(number)
			XCTAssertEqual(data.count, 2, "Encoded data should contain exactly two bytes, but contains \(data.count)")
			XCTAssertEqual(data[0], 0xCC)
			XCTAssertEqual(data[1], number)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testEncodeUInt16() {
		do {
			let data = try encoder.encode(UInt16(0x0506))
			XCTAssertEqual(data.count, 3, "Encoded data should contain exactly three bytes, but contains \(data.count)")
			XCTAssertEqual(data[0], 0xCD)
			XCTAssertEqual(data[1], 0x05)
			XCTAssertEqual(data[2], 0x06)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testEncodeUInt32() {
		do {
			let data = try encoder.encode(UInt32(0x05060708))
			XCTAssertEqual(data.count, 5, "Encoded data should contain exactly five bytes, but contains \(data.count)")
			XCTAssertEqual(data[0], 0xCE)
			XCTAssertEqual(data[1], 0x05)
			XCTAssertEqual(data[2], 0x06)
			XCTAssertEqual(data[3], 0x07)
			XCTAssertEqual(data[4], 0x08)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testEncodeUInt64() {
		do {
			let data = try encoder.encode(UInt64(0x0506070809101112))
			XCTAssertEqual(data.count, 9, "Encoded data should contain exactly nine bytes, but contains \(data.count)")
			XCTAssertEqual(data[0], 0xCF)
			XCTAssertEqual(data[1], 0x05)
			XCTAssertEqual(data[2], 0x06)
			XCTAssertEqual(data[3], 0x07)
			XCTAssertEqual(data[4], 0x08)
			XCTAssertEqual(data[5], 0x09)
			XCTAssertEqual(data[6], 0x10)
			XCTAssertEqual(data[7], 0x11)
			XCTAssertEqual(data[8], 0x12)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testPerformanceOf1MilionUInt32Encodings() {
		var d = Data()
		self.measure {
			for _ in 0 ..< 1000000 {
				Format.uInt32(136315908).appendTo(data: &d)
			}
		}
	}
}

