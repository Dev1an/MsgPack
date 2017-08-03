//
//  Formats.swift
//  MsgPack
//
//  Created by Damiaan on 30/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

import Foundation

enum Format {	
	case `nil`
	
	case boolean(Bool)

	case positiveInt7(UInt8)
	case negativeInt5(UInt8)
	
	case uInt8 (UInt8)
	case uInt16(UInt16)
	case uInt32(UInt32)
	case uInt64(UInt64)
	
	case int8 (Int8)
	case int16(Int16)
	case int32(Int32)
	case int64(Int64)
	
	case float32(Float)
	case float64(Double)
	
	case fixString(Data)
	case string8  (Data)
	case string16 (Data)
	case string32 (Data)
	
	case fixArray([Format])
	case array16 ([Format])
	case array32 ([Format])

	case fixMap([(key: Format, value: Format)])
	case map16 ([(key: Format, value: Format)])
	case map32 ([(key: Format, value: Format)])	
}

public enum FormatID: UInt8 {
	// Do not reorder the cases because their raw values are infered based on the ordering
	case `nil` = 0xC0
	
	case `false` = 0xC2
	case `true`
	
//	case bin8
//	case bin16
//	case bin32
//
//	case ext8
//	case ext16
//	case ext32
	
	case float32 = 0xCA
	case float64

	case positiveInt7 = 0b00000000
	case negativeInt5 = 0b11100000

	case uInt8 = 0xCC
	case uInt16
	case uInt32
	case uInt64
	
	case int8
	case int16
	case int32
	case int64
	
//	case fixExt1
//	case fixExt2
//	case fixExt4
//	case fixExt8
//	case fixExt16

	case fixString = 0b10100000
	case string8 = 0xD9
	case string16
	case string32
	
	case fixArray = 0b10010000
	case array16 = 0xDC
	case array32
	
	case fixMap = 0b10000000
	case map16 = 0xDE
	case map32
	
	static let positiveInt7Range = FormatID.positiveInt7.rawValue ..< FormatID.fixMap.rawValue
	static let negativeInt5Range = FormatID.negativeInt5.rawValue ..< 0b11111111
	
	static let fixMapRange = FormatID.fixMap.rawValue ..< FormatID.fixArray.rawValue
	static let fixArrayRange = FormatID.fixArray.rawValue ..< FormatID.fixString.rawValue
	static let fixStringRange = FormatID.fixString.rawValue ..< FormatID.nil.rawValue
	
	var length: Int {
		switch self {
		
		case .nil:
			return 0
		case .false:
			return 0
		case .true:
			return 0
		case .float32:
			return 1
		case .float64:
			return 1
		case .positiveInt7:
			return 0
		case .negativeInt5:
			return 0
		case .uInt8:
			return 1
		case .uInt16:
			return 1
		case .uInt32:
			return 1
		case .uInt64:
			return 1
		case .int8:
			return 1
		case .int16:
			return 1
		case .int32:
			return 1
		case .int64:
			return 1
		case .fixString:
			return 1
		case .string8:
			return 2
		case .string16:
			return 3
		case .string32:
			return 5
		case .fixArray:
			return 1
		case .array16:
			return 3
		case .array32:
			return 5
		case .fixMap:
			return 1
		case .map16:
			return 3
		case .map32:
			return 5
		}
	}
}

extension Format {
	func appendTo(data: inout Data) {
		switch self {
			
		// MARK: Optional
		case .nil:
			data.append(FormatID.nil.rawValue)
			
		// MARK: Boolean
		case .boolean(let boolean):
			data.append(boolean ? FormatID.true.rawValue : FormatID.false.rawValue)
			
		// MARK: Small integers (< 8 bit)
		case .positiveInt7(let value):
			data.append(value | FormatID.positiveInt7.rawValue)
		case .negativeInt5(let value):
			data.append(value | FormatID.negativeInt5.rawValue)
			
		// MARK: Unsigned integers
		case .uInt8(let value):
			data.append(contentsOf: [
				FormatID.uInt8.rawValue,
				value
			])
		case .uInt16(let value):
			var newData = Data(count: 3)
			newData[0] = FormatID.uInt16.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .uInt32(let value):
			var newData = Data(count: 5)
			newData[0] = FormatID.uInt32.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .uInt64(let value):
			var newData = Data(count: 9)
			newData[0] = FormatID.uInt64.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Signed integers
		case .int8(let value):
			var newData = Data(count: 2)
			newData[0] = FormatID.int8.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int16(let value):
			var newData = Data(count: 3)
			newData[0] = FormatID.int16.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int32(let value):
			var newData = Data(count: 5)
			newData[0] = FormatID.int32.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int64(let value):
			var newData = Data(count: 9)
			newData[0] = FormatID.int64.rawValue
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Floats
		case .float32(let value):
			var newData = Data(count: 5)
			newData[0] = FormatID.float32.rawValue
			newData.write(value: value.bitPattern.bigEndian, offset: 1)
			data.append(newData)
		case .float64(let value):
			var newData = Data(count: 9)
			newData[0] = FormatID.float64.rawValue
			newData.write(value: value.bitPattern.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Strings
		case .fixString(let utf8Data):
			precondition(utf8Data.count < 32, "fix strings cannot contain more than 31 bytes")
			data.append( UInt8(utf8Data.count) | FormatID.fixString.rawValue)
			data.append(utf8Data)
		case .string8(let utf8Data):
			data.append(contentsOf: [FormatID.string8.rawValue, UInt8(utf8Data.count)])
			data.append(utf8Data)
		case .string16(let utf8Data):
			var prefix = Data(count: 3)
			prefix[0] = FormatID.string16.rawValue
			prefix.write(value: UInt16(utf8Data.count).bigEndian, offset: 1)
			data.append(prefix)
			data.append(utf8Data)
		case .string32(let utf8Data):
			var prefix = Data(count: 5)
			prefix[0] = FormatID.string32.rawValue
			prefix.write(value: UInt32(utf8Data.count).bigEndian, offset: 1)
			data.append(prefix)
			data.append(utf8Data)
			
		// MARK: Arrays
		case .fixArray(let array):
			precondition(array.count < 16, "fix arrays cannot contain more than 15 elements")
			data.append( UInt8(array.count) | FormatID.fixArray.rawValue)
			for element in array {
				element.appendTo(data: &data)
			}
		case .array16(let array):
			var prefix = Data(count: 3)
			prefix[0] = FormatID.array16.rawValue
			prefix.write(value: UInt16(array.count).bigEndian, offset: 1)
			data.append(prefix)
			for element in array {
				element.appendTo(data: &data)
			}
		case .array32(let array):
			var prefix = Data(count: 5)
			prefix[0] = FormatID.array32.rawValue
			prefix.write(value: UInt32(array.count).bigEndian, offset: 1)
			data.append(prefix)
			for element in array {
				element.appendTo(data: &data)
			}

		// MARK: Maps
		case .fixMap(let pairs):
			precondition(pairs.count < 16, "fix maps cannot contain more than 15 key-value pairs")
			data.append( UInt8(pairs.count) | FormatID.fixMap.rawValue)
			for (key, value) in pairs {
				key.appendTo(data: &data)
				value.appendTo(data: &data)
			}
		case .map16(let pairs):
			var prefix = Data(count: 3)
			prefix[0] = FormatID.map16.rawValue
			prefix.write(value: UInt16(pairs.count).bigEndian, offset: 1)
			data.append(prefix)
			for (key, value) in pairs {
				key.appendTo(data: &data)
				value.appendTo(data: &data)
			}
		case .map32(let pairs):
			var prefix = Data(count: 5)
			prefix[0] = FormatID.map32.rawValue
			prefix.write(value: UInt32(pairs.count).bigEndian, offset: 1)
			data.append(prefix)
			for (key, value) in pairs {
				key.appendTo(data: &data)
				value.appendTo(data: &data)
			}
		}
	}
}

extension Data {
	mutating func write<T>(value: T, offset: Int) {
		withUnsafeMutableBytes {(byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
			byteContainer.advanced(by: offset).withMemoryRebound(to: T.self, capacity: 1) {
				$0.pointee = value
			}
		}
	}
	
	func read<T>(at offset: Int) -> T {
		return withUnsafeBytes {(byteContainer: UnsafePointer<UInt8>) -> T in
			byteContainer.advanced(by: offset).withMemoryRebound(to: T.self, capacity: 1) {$0.pointee}
		}
	}
	
	func bigEndianInteger<T: FixedWidthInteger>(at offset: Int) -> T {
		return withUnsafeBytes {(byteContainer: UnsafePointer<UInt8>) -> T in
			byteContainer.advanced(by: offset).withMemoryRebound(to: T.self, capacity: 1) {T.init(bigEndian: $0.pointee)}
		}
	}	
}

// MARK: encoding helpers
extension Format {
	static func from(string: String) throws -> Format {
		guard let data = string.data(using: .utf8) else {throw MsgPackEncodingError.stringNotConvertibleToUTF8(string)}
		switch data.count {
		case 1..<32:
			return .fixString(data)
		case 32..<256:
			return .string8(data)
		case 256..<65536:
			return .string16(data)
		default:
			return .string32(data)
		}
	}
	
	static func from(keyValuePairs: [(Format, Format)]) -> Format {
		switch keyValuePairs.count {
		case 1..<16:
			return .fixMap(keyValuePairs)
		case 16..<65536:
			return .map16(keyValuePairs)
		default:
			return .map32(keyValuePairs)
		}
	}
	
	static func from(array: [Format]) -> Format {
		switch array.count {
		case 1..<16:
			return .fixArray(array)
		case 16..<65536:
			return .array16(array)
		default:
			return .array32(array)
		}
	}
	
	static func from(int: Int) -> Format {
		#if arch(arm) || arch(i386)
			return .int32(Int32(int))
		#else
			return .int64(Int64(int))
		#endif
	}
	
	static func from(uInt: UInt) -> Format {
		#if arch(arm) || arch(i386)
			return .uInt32(UInt32(uInt))
		#else
			return .uInt64(UInt64(uInt))
		#endif
	}
}

extension Format {
	static func string(from data: inout Data, base: inout Int) throws -> String {
		switch data[base] {
		case FormatID.fixStringRange:
			let length = Int(data[base] & 0b00011111)
			base += 1
			guard let string = data.withUnsafeMutableBytes({
				String(bytesNoCopy: $0.advanced(by: base), length: length, encoding: .utf8, freeWhenDone: false)
			}) else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "not a valid string"))
			}
			base += length
			return string
		case FormatID.string8.rawValue:
			let length = Int(data[base + 1])
			base += 2
			guard let string = data.withUnsafeMutableBytes({
				String(bytesNoCopy: $0.advanced(by: base), length: length, encoding: .utf8, freeWhenDone: false)
			}) else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "not a valid string"))
			}
			base += length
			return string
		case FormatID.string16.rawValue:
			let length = Int(data.bigEndianInteger(at: base + 1) as UInt16)
			base += 3
			guard let string = data.withUnsafeMutableBytes({
				String(bytesNoCopy: $0.advanced(by: base), length: length, encoding: .utf8, freeWhenDone: false)
			}) else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "not a valid string"))
			}
			base += length
			return string
		case FormatID.string32.rawValue:
			let length = Int(data.bigEndianInteger(at: base + 1) as UInt16)
			base += 5
			guard let string = data.withUnsafeMutableBytes({
				String(bytesNoCopy: $0.advanced(by: base), length: length, encoding: .utf8, freeWhenDone: false)
			}) else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "not a valid string"))
			}
			base += length
			return string
		default:
			throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: "Wrong string format: \(data[base])"))
		}
	}
}
