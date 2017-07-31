//
//  Encoder.swift
//  MsgPack
//
//  Created by Damiaan on 29/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

public class Encoder {
	let serialiser = Serialiser()
	
	public init() {}
	
	public func encode<T : Encodable>(_ value: T) throws -> Data {
		try value.encode(to: serialiser)
		var data = Data()
		try serialiser.storage?.appendTo(data: &data)
		return data
	}
}

class Serialiser: Swift.Encoder {
	var codingPath = [CodingKey]()
	var userInfo = [CodingUserInfoKey : Any]()
	
	var storage: Format?
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		preconditionFailure()
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		preconditionFailure()
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		return self
	}
}

extension MsgPack.Serialiser: SingleValueEncodingContainer {
	enum Error: Swift.Error {
		case notImplemented, stringNotConvertibleToUTF8
	}
	
	func encodeNil() throws {
		storage = .nil
	}
	
	func encode(_ value: Bool) throws {
		storage = .boolean(value)
	}
	
	func encode(_ value: Int) throws {
		#if arch(arm) || arch(i386)
			storage = .int32(Int32(value))
		#else
			storage = .int64(Int64(value))
		#endif
	}
	
	func encode(_ value: Int8) throws {
		storage = .int8(value)
	}
	
	func encode(_ value: Int16) throws {
		storage = .int16(value)
	}
	
	func encode(_ value: Int32) throws {
		storage = .int32(value)
	}
	
	func encode(_ value: Int64) throws {
		storage = .int64(value)
	}
	
	func encode(_ value: UInt) throws {
		#if arch(arm) || arch(i386)
			storage = .uInt32(UInt32(value))
		#else
			storage = .uInt64(UInt64(value))
		#endif
	}
	
	func encode(_ value: UInt8) throws {
		storage = .uInt8(value)
	}
	
	func encode(_ value: UInt16) throws {
		storage = .uInt16(value)
	}
	
	func encode(_ value: UInt32) throws {
		storage = .uInt32(value)
	}
	
	func encode(_ value: UInt64) throws {
		storage = .uInt64(value)
	}
	
	func encode(_ value: Float) throws {
		storage = .float32(value)
	}
	
	func encode(_ value: Double) throws {
		storage = .float64(value)
	}
	
	func encode(_ value: String) throws {
		guard let data = value.data(using: .utf8) else {throw Error.stringNotConvertibleToUTF8}
		switch data.count {
		case 1..<32:
			storage = .fixString(data)
		case 32..<256:
			storage = .string8(data)
		case 256..<65536:
			storage = .string16(data)
		default:
			storage = .string32(data)
		}
	}
	
	func encode<T : Encodable>(_ value: T) throws {
		throw Error.notImplemented
	}
}
