//
//  Encoder.swift
//  MsgPack
//
//  Created by Damiaan on 29/07/17.
//  Copyright © 2017 dPro. All rights reserved.
//

import Foundation

class Encoder: Swift.Encoder {
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
	
	public func dataFor<T : Encodable>(_ value: T) throws -> Data {
		try value.encode(to: self)
		var data = Data()
		storage?.appendTo(data: &data)
		return data
	}
}

extension MsgPack.Encoder: SingleValueEncodingContainer {
	enum Error: Swift.Error {
		case notImplemented
	}
	
	func encodeNil() throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: Bool) throws {
		storage = .boolean(value)
	}
	
	func encode(_ value: Int) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: Int8) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: Int16) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: Int32) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: Int64) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: UInt) throws {
		throw Error.notImplemented
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
		throw Error.notImplemented
	}
	
	func encode(_ value: Double) throws {
		throw Error.notImplemented
	}
	
	func encode(_ value: String) throws {
		throw Error.notImplemented
	}
	
	func encode<T : Encodable>(_ value: T) throws {
		throw Error.notImplemented
	}
}
