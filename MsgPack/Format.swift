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


extension Format {
	func appendTo(data: inout Data) {
		switch self {
			
		// MARK: Optional
		case .nil:
			data.append(0xC0)
			
		// MARK: Boolean
		case .boolean(let boolean):
			data.append(boolean ? 0xC3 : 0xC2)
			
		// MARK: Small integers (< 8 bit)
		case .positiveInt7(let value):
			data.append(value | 0b10000000)
		case .negativeInt5(let value):
			data.append(value | 0b11100000)
			
		// MARK: Unsigned integers
		case .uInt8(let value):
			data.append(0xCC)
			data.append(value)
		case .uInt16(let value):
			var newData = Data(count: 3)
			newData[0] = 0xCD
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .uInt32(let value):
			var newData = Data(count: 5)
			newData[0] = 0xCE
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .uInt64(let value):
			var newData = Data(count: 9)
			newData[0] = 0xCF
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Signed integers
		case .int8(let value):
			var newData = Data(count: 2)
			newData[0] = 0xD0
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int16(let value):
			var newData = Data(count: 3)
			newData[0] = 0xD1
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int32(let value):
			var newData = Data(count: 5)
			newData[0] = 0xD2
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
		case .int64(let value):
			var newData = Data(count: 9)
			newData[0] = 0xD3
			newData.write(value: value.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Floats
		case .float32(let value):
			var newData = Data(count: 5)
			newData[0] = 0xCA
			newData.write(value: value.bitPattern.bigEndian, offset: 1)
			data.append(newData)
		case .float64(let value):
			var newData = Data(count: 9)
			newData[0] = 0xCB
			newData.write(value: value.bitPattern.bigEndian, offset: 1)
			data.append(newData)
			
		// MARK: Strings
		case .fixString(let utf8Data):
			precondition(utf8Data.count < 32, "fix strings cannot contain more than 31 bytes")
			data.append( UInt8(utf8Data.count) | 0b10100000)
			data.append(utf8Data)
		case .string8(let utf8Data):
			data.append(contentsOf: [0xD9, UInt8(utf8Data.count)])
			data.append(utf8Data)
		case .string16(let utf8Data):
			var prefix = Data(count: 3)
			prefix[0] = 0xDA
			prefix.write(value: UInt16(utf8Data.count).bigEndian, offset: 1)
			data.append(prefix)
			data.append(utf8Data)
		case .string32(let utf8Data):
			var prefix = Data(count: 5)
			prefix[0] = 0xDB
			prefix.write(value: UInt32(utf8Data.count).bigEndian, offset: 1)
			data.append(prefix)
			data.append(utf8Data)
			
		// MARK: Arrays
		case .fixArray(let array):
			precondition(array.count < 16, "fix arrays cannot contain more than 15 elements")
			data.append( UInt8(array.count) | 0b10010000)
			for element in array {
				element.appendTo(data: &data)
			}
		case .array16(let array):
			var prefix = Data(count: 3)
			prefix[0] = 0xDC
			prefix.write(value: UInt16(array.count).bigEndian, offset: 1)
			data.append(prefix)
			for element in array {
				element.appendTo(data: &data)
			}
		case .array32(let array):
			var prefix = Data(count: 5)
			prefix[0] = 0xDD
			prefix.write(value: UInt32(array.count).bigEndian, offset: 1)
			data.append(prefix)
			for element in array {
				element.appendTo(data: &data)
			}

		// MARK: Maps
		case .fixMap(let pairs):
			precondition(pairs.count < 16, "fix maps cannot contain more than 15 key-value pairs")
			data.append( UInt8(pairs.count) | 0b10000000)
			for (key, value) in pairs {
				key.appendTo(data: &data)
				value.appendTo(data: &data)
			}
		case .map16(let pairs):
			var prefix = Data(count: 3)
			prefix[0] = 0xDE
			prefix.write(value: UInt16(pairs.count).bigEndian, offset: 1)
			data.append(prefix)
			for (key, value) in pairs {
				key.appendTo(data: &data)
				value.appendTo(data: &data)
			}
		case .map32(let pairs):
			var prefix = Data(count: 5)
			prefix[0] = 0xDE
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
}
