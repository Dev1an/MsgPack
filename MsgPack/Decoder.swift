//
//  Decoder.swift
//  MsgPack
//
//  Created by Damiaan on 29/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

public class Decoder {
	public func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
		let decoder = IntermediateDecoder(with: data)
		return try T(from: decoder)
	}
	
	public init() {}
}

class IntermediateDecoder: Swift.Decoder {
	var codingPath = [CodingKey]()
	
	var userInfo = [CodingUserInfoKey : Any]()
	
	var storage: Data
	var offset = 0
	
	init(with data: Data) {
		storage = data
	}
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		fatalError()
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}
	
	func singleValueContainer() throws -> SingleValueDecodingContainer {
		return MsgPckSingleValueDecodingContainer(refferingTo: self)
	}
}

struct MsgPckSingleValueDecodingContainer: SingleValueDecodingContainer {
	var codingPath = [CodingKey]()
	var decoder: IntermediateDecoder
	var base = 0

	enum Error: Swift.Error {
		case invalidFormat(UInt8)
	}
	
	init(refferingTo decoder: IntermediateDecoder) {
		self.decoder = decoder
	}
	
	func decodeNil() -> Bool {
		return decoder.storage[base] == FormatID.nil.rawValue
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		let byte = decoder.storage[base]
		guard byte & 0b11111110 == FormatID.false.rawValue else {
			throw Error.invalidFormat(byte)
		}
		return byte == FormatID.true.rawValue
	}
	
	func decode(_ type: Int.Type) throws -> Int {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int8.Type) throws -> Int8 {
		guard decoder.storage[base] == FormatID.int8.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.read(at: base+1)
	}
	
	func decode(_ type: Int16.Type) throws -> Int16 {
		guard decoder.storage[base] == FormatID.int16.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: Int32.Type) throws -> Int32 {
		guard decoder.storage[base] == FormatID.int32.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: Int64.Type) throws -> Int64 {
		guard decoder.storage[base] == FormatID.int64.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: UInt.Type) throws -> UInt {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		guard decoder.storage[base] == FormatID.uInt8.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.read(at: base+1)
	}
	
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		guard decoder.storage[base] == FormatID.uInt16.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		guard decoder.storage[base] == FormatID.uInt32.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		guard decoder.storage[base] == FormatID.uInt64.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.bigEndianInteger(at: base+1)
	}
	
	func decode(_ type: Float.Type) throws -> Float {
		guard decoder.storage[base] == FormatID.float32.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		return decoder.storage.read(at: base + 1)
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		guard decoder.storage[base] == FormatID.float64.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		let bitPattern: UInt64 = decoder.storage.bigEndianInteger(at: base + 1)
		return .init(bitPattern: bitPattern)
	}
	
	func decode(_ type: String.Type) throws -> String {
		fatalError("not implemented")
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		fatalError("not implemented")
	}
}
