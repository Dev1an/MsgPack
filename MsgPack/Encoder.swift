//
//  Encoder.swift
//  MsgPack
//
//  Created by Damiaan on 29/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

public class Encoder {
	let intermediate = IntermediateEncoder()
	
	public init() {}
	
	public func encode<T : Encodable>(_ value: T) throws -> Data {
		try value.encode(to: intermediate)
		var data = Data()
		try intermediate.container?.getFormat().appendTo(data: &data)
		return data
	}
}

class IntermediateEncoder: Swift.Encoder {
	
	var codingPath = [CodingKey]()
	var userInfo = [CodingUserInfoKey : Any]()
	
	var container: MessagePackEncodingContainer?
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		let keyedContainer = MsgPackKeyedEncodingContainer<Key>()
		container = keyedContainer
		return KeyedEncodingContainer(keyedContainer)
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		preconditionFailure()
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		let singleValueContainer = MsgPackSingleValueEncodingContainer()
		container = singleValueContainer
		return singleValueContainer
	}
}

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

class MessagePackEncodingContainer {
	var codingPath: [CodingKey] = []
	
	func getFormat() throws -> Format {
		preconditionFailure()
	}
}

enum MsgPackEncodingError: Swift.Error {
	case notImplemented, stringNotConvertibleToUTF8(String)
}

class MsgPackSingleValueEncodingContainer: MessagePackEncodingContainer, SingleValueEncodingContainer {
	
	var storage: Format?
	
	enum Error: Swift.Error {
		case noValue
	}
	
	override func getFormat() throws -> Format {
		guard let format = storage else {throw Error.noValue}
		return format
	}

	init(with storage: Format? = nil) {
		self.storage = storage
	}
	
	func encodeNil() throws {
		storage = .nil
	}

	func encode(_ value: Bool) throws {
		storage = .boolean(value)
	}

	func encode(_ value: Int) throws {
		storage = .from(int: value)
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
		storage = .from(uInt: value)
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
		storage = try .from(string: value)
	}

	func encode<T : Encodable>(_ value: T) throws {
		throw MsgPackEncodingError.notImplemented
	}
}

class MsgPackKeyedEncodingContainer<K: CodingKey>: MessagePackEncodingContainer, KeyedEncodingContainerProtocol {
	var userInfo = [CodingUserInfoKey : Any]()

	var storage = [String: MessagePackEncodingContainer]()
	
	override func getFormat() throws -> Format {
		return try Format.from(keyValuePairs: storage.map {
			(try Format.from(string: $0.key), try $0.value.getFormat())
		})
	}

	func encodeNil(forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .nil)
	}
	
	func encode(_ value: Bool, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .boolean(value) )
	}
	
	func encode(_ value: Int, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .from(int: value) )
	}
	
	func encode(_ value: Int8, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int8(value) )
	}
	
	func encode(_ value: Int16, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int16(value) )
	}
	
	func encode(_ value: Int32, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int32(value) )
	}
	
	func encode(_ value: Int64, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int64(value) )
	}
	
	func encode(_ value: UInt, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .from(uInt: value) )
	}
	
	func encode(_ value: UInt8, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt8(value) )
	}
	
	func encode(_ value: UInt16, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt16(value) )
	}
	
	func encode(_ value: UInt32, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt32(value) )
	}
	
	func encode(_ value: UInt64, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt64(value) )
	}
	
	func encode(_ value: Float, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .float32(value) )
	}
	
	func encode(_ value: Double, forKey key: K) throws {
		storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .float64(value) )
	}
	
	func encode(_ value: String, forKey key: K) throws {
		storage[key.stringValue] = try MsgPackSingleValueEncodingContainer(with: .from(string: value) )
	}
	
	func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
		throw MsgPackEncodingError.notImplemented
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		let keyedContainer = MsgPackKeyedEncodingContainer<NestedKey>()
		storage[key.stringValue] = keyedContainer
		return KeyedEncodingContainer(keyedContainer)
	}
	
	func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
		preconditionFailure("not implemented")
	}
	
	func superEncoder() -> Swift.Encoder {
		preconditionFailure("not implemented")
	}
	
	func superEncoder(forKey key: K) -> Swift.Encoder {
		preconditionFailure("not implemented")
	}
}
