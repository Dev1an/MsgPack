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

enum MsgPackEncodingError: Swift.Error {
	case stringNotConvertibleToUTF8(String), valueDidNotAskForContainer
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
		let unkeyedContainer = MsgPackUnkeyedEncodingContainer()
		container = unkeyedContainer
		return unkeyedContainer
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		let singleValueContainer = MsgPackSingleValueEncodingContainer()
		container = singleValueContainer
		return singleValueContainer
	}
}

class MessagePackEncodingContainer: Swift.Encoder {
	var userInfo = [CodingUserInfoKey : Any]()
	var codingPath: [CodingKey] = []
	
	var temporaryContainer: MessagePackEncodingContainer?

	func getFormat() throws -> Format {
		fatalError("subclasses should implement this method")
	}
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		let keyedContainer = MsgPackKeyedEncodingContainer<Key>()
		temporaryContainer = keyedContainer
		return KeyedEncodingContainer(keyedContainer)
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		let unkeyedContainer = MsgPackUnkeyedEncodingContainer()
		temporaryContainer = unkeyedContainer
		return unkeyedContainer
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		let singleValueContainer = MsgPackSingleValueEncodingContainer()
		temporaryContainer = singleValueContainer
		return singleValueContainer
	}

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
		fatalError("Not implemented")
	}
}

class MsgPackKeyedEncodingContainer<K: CodingKey>: MessagePackEncodingContainer, KeyedEncodingContainerProtocol {
	
	let storageReference: KeyedStorageContainer
	
	init(storage: KeyedStorageContainer = KeyedStorageContainer()) {
		storageReference = storage
	}
	
	override func getFormat() throws -> Format {
		return try Format.from(keyValuePairs: storageReference.storage.map {
			(try Format.from(string: $0.key), try $0.value.getFormat())
		})
	}

	func encodeNil(forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .nil)
	}
	
	func encode(_ value: Bool, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .boolean(value) )
	}
	
	func encode(_ value: Int, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .from(int: value) )
	}
	
	func encode(_ value: Int8, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int8(value) )
	}
	
	func encode(_ value: Int16, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int16(value) )
	}
	
	func encode(_ value: Int32, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int32(value) )
	}
	
	func encode(_ value: Int64, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .int64(value) )
	}
	
	func encode(_ value: UInt, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .from(uInt: value) )
	}
	
	func encode(_ value: UInt8, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt8(value) )
	}
	
	func encode(_ value: UInt16, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt16(value) )
	}
	
	func encode(_ value: UInt32, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt32(value) )
	}
	
	func encode(_ value: UInt64, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .uInt64(value) )
	}
	
	func encode(_ value: Float, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .float32(value) )
	}
	
	func encode(_ value: Double, forKey key: K) throws {
		storageReference.storage[key.stringValue] = MsgPackSingleValueEncodingContainer(with: .float64(value) )
	}
	
	func encode(_ value: String, forKey key: K) throws {
		storageReference.storage[key.stringValue] = try MsgPackSingleValueEncodingContainer(with: .from(string: value) )
	}
	
	func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
		try value.encode(to: self)
		guard let container = temporaryContainer else {
			throw MsgPackEncodingError.valueDidNotAskForContainer
		}
		storageReference.storage[key.stringValue] = container
	}
	
	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		let keyedContainer = MsgPackKeyedEncodingContainer<NestedKey>()
		storageReference.storage[key.stringValue] = keyedContainer
		return KeyedEncodingContainer(keyedContainer)
	}
	
	func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
		let unkeyedContainer = MsgPackUnkeyedEncodingContainer()
		storageReference.storage[key.stringValue] = unkeyedContainer
		return unkeyedContainer
	}
	
	func superEncoder() -> Swift.Encoder {
		return KeyedEncoder(referencing: storageReference)
	}
	
	func superEncoder(forKey key: K) -> Swift.Encoder {
		fatalError("not implemented")
	}
}

class KeyedStorageContainer: Reference<[String: MessagePackEncodingContainer]> {
	init() {
		super.init(to: [:])
	}
}

class KeyedEncoder: Swift.Encoder {
	var codingPath = [CodingKey]()

	var userInfo = [CodingUserInfoKey : Any]()

	let storageReference: KeyedStorageContainer
	
	init(referencing storage: KeyedStorageContainer) {
		storageReference = storage
	}

	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		return KeyedEncodingContainer(MsgPackKeyedEncodingContainer())
	}

	func unkeyedContainer() -> UnkeyedEncodingContainer {
		preconditionFailure("impossible to give an unkeyed container")
	}

	func singleValueContainer() -> SingleValueEncodingContainer {
		preconditionFailure("impossible to give a single value container")
	}
}

class MsgPackUnkeyedEncodingContainer: MessagePackEncodingContainer, UnkeyedEncodingContainer {
	var count: Int { return storage.count }
	
	var storage = [MessagePackEncodingContainer]()
	
	override func getFormat() throws -> Format {
		return try .from(array: storage.map {try $0.getFormat()} )
	}
	
	func encodeNil() throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .nil))
	}
	
	func encode(_ value: Bool) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .boolean(value)))
	}
	
	func encode(_ value: Int) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .from(int: value)))
	}
	
	func encode(_ value: Int8) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .int8(value)))
	}
	
	func encode(_ value: Int16) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .int16(value)))
	}
	
	func encode(_ value: Int32) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .int32(value)))
	}
	
	func encode(_ value: Int64) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .int64(value)))
	}
	
	func encode(_ value: UInt) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .from(uInt: value)))
	}
	
	func encode(_ value: UInt8) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .uInt8(value)))
	}
	
	func encode(_ value: UInt16) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .uInt16(value)))
	}
	
	func encode(_ value: UInt32) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .uInt32(value)))
	}
	
	func encode(_ value: UInt64) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .uInt64(value)))
	}
	
	func encode(_ value: Float) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .float32(value)))
	}
	
	func encode(_ value: Double) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: .float64(value)))
	}
	
	func encode(_ value: String) throws {
		storage.append(MsgPackSingleValueEncodingContainer(with: try .from(string: value)))
	}
	
	func encode<T : Encodable>(_ value: T) throws {
		try value.encode(to: self)
		guard let container = temporaryContainer else { throw MsgPackEncodingError.valueDidNotAskForContainer }
		storage.append(container)
	}

	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		let container = MsgPackKeyedEncodingContainer<NestedKey>()
		storage.append(container)
		return KeyedEncodingContainer(container)
	}
	
	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		let container = MsgPackUnkeyedEncodingContainer()
		storage.append(container)
		return container
	}
	
	func superEncoder() -> Swift.Encoder {
		return UnkeyedEncoder(referencing: self)
	}
}

class UnkeyedEncoder: Swift.Encoder {
	var codingPath = [CodingKey]()
	
	var userInfo = [CodingUserInfoKey : Any]()
	
	let container: MsgPackUnkeyedEncodingContainer
	
	init(referencing container: MsgPackUnkeyedEncodingContainer) {
		self.container = container
	}
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		let keyedContainer = MsgPackKeyedEncodingContainer<Key>()
		container.storage.append(keyedContainer)
		return KeyedEncodingContainer(keyedContainer)
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		let unkeyedContainer = MsgPackUnkeyedEncodingContainer()
		container.storage.append(unkeyedContainer)
		return unkeyedContainer
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		let singleValueContainer = MsgPackSingleValueEncodingContainer()
		container.storage.append(singleValueContainer)
		return singleValueContainer
	}
}
