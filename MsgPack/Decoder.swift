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

	var dictionary = [String:(FormatID, Int)]()
	
	init(with data: Data) {
		storage = data
	}
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return KeyedDecodingContainer(try MsgPckKeyedDecodingContainer<Key>(referringTo: self, at: offset, with: []))
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}
	
	func singleValueContainer() throws -> SingleValueDecodingContainer {
		return MsgPckSingleValueDecodingContainer(decoder: self, base: 0, codingPath: [])
	}
}

struct MsgPckSingleValueDecodingContainer: SingleValueDecodingContainer {
	let decoder: IntermediateDecoder
	var base: Int

	var codingPath: [CodingKey]

	enum Error: Swift.Error {
		case invalidFormat(UInt8)
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
		let bitPattern: UInt32 = decoder.storage.bigEndianInteger(at: base + 1)
		return .init(bitPattern: bitPattern)
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		guard decoder.storage[base] == FormatID.float64.rawValue else {
			throw Error.invalidFormat(decoder.storage[base])
		}
		let bitPattern: UInt64 = decoder.storage.bigEndianInteger(at: base + 1)
		return .init(bitPattern: bitPattern)
	}
	
	mutating func decode(_ type: String.Type) throws -> String {
		return try Format.string(from: &decoder.storage, base: &base)
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		fatalError("not implemented")
	}
}

struct MsgPckKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
	var codingPath: [CodingKey]
	
	let decoder: IntermediateDecoder
	var base = 0

	var allKeys = [K]()
	
	init(referringTo decoder: IntermediateDecoder, at base: Int, with codingPath: [CodingKey]) throws {
		self.codingPath = codingPath
		self.decoder = decoder
		self.base = base
		
		let elementCount: Int
		switch decoder.storage[base] {
		case FormatID.fixMapRange:
			elementCount = Int(decoder.storage[base] - FormatID.fixMap.rawValue)
			self.base += 1
		case FormatID.map16.rawValue:
			elementCount = Int(decoder.storage.bigEndianInteger(at: base+1) as UInt16)
			self.base += 3
		case FormatID.map32.rawValue:
			elementCount = Int(decoder.storage.bigEndianInteger(at: base+1) as UInt32)
			self.base += 5
		default:
			throw DecodingError.typeMismatch(Dictionary<String,Any>.self, .init(codingPath: codingPath, debugDescription: "Expected a MsgPack map format, but found 0x\(String(decoder.storage[base], radix: 16))"))
		}
		for cursor in 0 ..< elementCount {
			let key = try Format.string(from: &decoder.storage, base: &self.base)
			
			let valueFormat: FormatID
			if let valueFormatLookup = FormatID(rawValue: decoder.storage[self.base]) {
				valueFormat = valueFormatLookup
			} else {
				switch decoder.storage[self.base] {
				case FormatID.fixMapRange:
					valueFormat = .fixMap
				case FormatID.fixStringRange:
					valueFormat = .fixString
				case FormatID.positiveInt7Range:
					valueFormat = .positiveInt7
				case FormatID.negativeInt5Range:
					valueFormat = .negativeInt5
				default:
					throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Unknown format: 0x\(String(decoder.storage[self.base], radix: 16))"))
				}
			}
			
			let length: Int
			switch valueFormat {
			case .positiveInt7, .negativeInt5, .fixArray, .fixMap, .fixString:
				length = Int(decoder.storage[self.base] - valueFormat.rawValue)
				self.base += length + 1
			case .uInt8, .int8, .string8:
				length = Int(decoder.storage[self.base+1])
				self.base += length + 2
			case .uInt16, .int16, .string16, .array16, .map16:
				length = Int(decoder.storage.bigEndianInteger(at: self.base + 1) as UInt16)
				self.base += length + 3
			case .uInt32, .int32, .string32, .array32, .map32, .float32:
				length = Int(decoder.storage.bigEndianInteger(at: self.base + 1) as UInt32)
				self.base += length + 5
			case .uInt64, .int64, .float64:
				length = Int(decoder.storage.bigEndianInteger(at: self.base + 1) as UInt64)
				self.base += length + 9
			case .nil, .false, .true:
				length = 0
				self.base += 1
			}
			decoder.dictionary[key] = (valueFormat, length)
		}
	}
	
	func contains(_ key: K) -> Bool {
		return decoder.dictionary[key.stringValue] != nil
	}
	
	func decodeNil(forKey key: K) throws -> Bool {
		return decoder.dictionary[key.stringValue]?.0 == FormatID.nil
	}
	
	func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
		let format = decoder.dictionary[key.stringValue]!.0
		switch format {
		case .true, .false:
			return format == .true
		default:
			throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected bool but found \(format)"))
		}
	}
	
	func decode(_ type: Int.Type, forKey key: K) throws -> Int {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
		fatalError("not implemented")
	}
	
	func decode(_ type: Float.Type, forKey key: K) throws -> Float {
		fatalError("not implemented")
	}
	
	func decode(_ type: Double.Type, forKey key: K) throws -> Double {
		fatalError("not implemented")
	}
	
	func decode(_ type: String.Type, forKey key: K) throws -> String {
		fatalError("not implemented")
	}
	
	func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
		fatalError("not implemented")
	}
	
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError("not implemented")
	}
	
	func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
		fatalError("not implemented")
	}
	
	func superDecoder() throws -> Swift.Decoder {
		fatalError("not implemented")
	}
	
	func superDecoder(forKey key: K) throws -> Swift.Decoder {
		fatalError("not implemented")
	}
	
	typealias Key = K
}
