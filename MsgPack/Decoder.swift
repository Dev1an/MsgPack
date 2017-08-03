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

class PartiallyDecodedDictionary: Reference<[String:PartiallyDecodedValue]> {
	let pointer: Int
	var byteCount = 0
	init(pointer: Int) {
		self.pointer = pointer
		super.init(to: [:])
	}
}

enum PartiallyDecodedValue {
	case constant(FormatID)
	case fixedWidth(FormatID, pointer: Int)
	case variableWidth(FormatID, pointer: Int, length: Int)
	case array([PartiallyDecodedValue], pointer: Int, byteCount: Int)
	case dictionary(PartiallyDecodedDictionary)
}

class IntermediateDecoder: Swift.Decoder {
	var codingPath = [CodingKey]()
	
	var userInfo = [CodingUserInfoKey : Any]()
	
	var storage: Data

	let dictionary: PartiallyDecodedDictionary
	var cursor = 0
	
	init(with data: Data) {
		storage = data
		dictionary = PartiallyDecodedDictionary(pointer: 0)
	}
	
	init(withUnsafeDataFrom otherDecoder: IntermediateDecoder, start: Int, length: Int) {
		storage = otherDecoder.storage.withUnsafeMutableBytes {
			Data(bytesNoCopy: $0.advanced(by: start), count: length, deallocator: .none)
		}
		dictionary = otherDecoder.dictionary
	}
	
	convenience init(withUnsafeDataFrom otherDecoder: IntermediateDecoder, start: Int) {
		self.init(withUnsafeDataFrom: otherDecoder, start: start, length: otherDecoder.storage.count - start)
	}

	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return KeyedDecodingContainer(try MsgPckKeyedDecodingContainer<Key>(referringTo: self, with: codingPath))
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
	let base: Int

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
	
	func decode(_ type: String.Type) throws -> String {
		var base = self.base
		return try Format.string(from: &decoder.storage, base: &base)
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		fatalError("not implemented")
	}
}

struct TemporaryCodingKey: CodingKey {
	let stringValue: String
	let intValue: Int? = nil

	init?(stringValue: String) {
		self.stringValue = stringValue
	}
	
	init?(intValue: Int) {
		return nil
	}
}

struct MsgPckKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
	var codingPath: [CodingKey]
	
	let relativeDictionary: PartiallyDecodedDictionary
	
	let decoder: IntermediateDecoder

	var allKeys = [K]()
	
	init(referringTo decoder: IntermediateDecoder, with codingPath: [CodingKey]) throws {
		self.codingPath = codingPath
		self.decoder = decoder

		var link = decoder.dictionary
		for x in codingPath.dropLast() {
			guard case let .dictionary(newLink) = link.storage[x.stringValue]! else {fatalError()}
			link = newLink
		}
		if let lastCodingKey = codingPath.last, let lastReference = link.storage[lastCodingKey.stringValue] {
			guard case .dictionary(let newLink) = lastReference else {fatalError()}
			relativeDictionary = newLink
		} else {
			var cursor = decoder.cursor
			if let lastCodingKey = codingPath.last {
				relativeDictionary = PartiallyDecodedDictionary(pointer: cursor)
				link.storage[lastCodingKey.stringValue] = .dictionary(relativeDictionary)
			} else {
				relativeDictionary = link
			}

			let elementCount: Int
			switch decoder.storage[cursor] {
			case FormatID.fixMapRange:
				elementCount = Int(decoder.storage[cursor] - FormatID.fixMap.rawValue)
				cursor += 1
			case FormatID.map16.rawValue:
				elementCount = Int(decoder.storage.bigEndianInteger(at: cursor+1) as UInt16)
				cursor += 3
			case FormatID.map32.rawValue:
				elementCount = Int(decoder.storage.bigEndianInteger(at: cursor+1) as UInt32)
				cursor += 5
			default:
				throw DecodingError.typeMismatch(Dictionary<String,Any>.self, .init(codingPath: codingPath, debugDescription: "Expected a MsgPack map format, but found 0x\(String(decoder.storage[cursor], radix: 16))"))
			}
			for _ in 0 ..< elementCount {
				let key = try Format.string(from: &decoder.storage, base: &cursor)
				let valueFormat: FormatID
				if let valueFormatLookup = FormatID(rawValue: decoder.storage[cursor]) {
					valueFormat = valueFormatLookup
				} else {
					switch decoder.storage[cursor] {
					case FormatID.fixMapRange:
						valueFormat = .fixMap
					case FormatID.fixArrayRange:
						fatalError("array decoding not implemented")
					case FormatID.fixStringRange:
						valueFormat = .fixString
					case FormatID.positiveInt7Range:
						valueFormat = .positiveInt7
					case FormatID.negativeInt5Range:
						valueFormat = .negativeInt5
					default:
						throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Unknown format: 0x\(String(decoder.storage[cursor], radix: 16))"))
					}
				}
				
				switch valueFormat {
				case .nil, .false, .true:
					relativeDictionary.storage[key] = .constant(valueFormat)
					cursor += 1
				case .positiveInt7, .negativeInt5:
					relativeDictionary.storage[key] = .fixedWidth(valueFormat, pointer: cursor)
					cursor += 1
				case .uInt8, .int8, .string8:
					relativeDictionary.storage[key] = .fixedWidth(valueFormat, pointer: cursor + 1)
					cursor += 2
				case .uInt16, .int16:
					relativeDictionary.storage[key] = .fixedWidth(valueFormat, pointer: cursor + 1)
					cursor += 3
				case .uInt32, .int32, .float32:
					relativeDictionary.storage[key] = .fixedWidth(valueFormat, pointer: cursor + 1)
					cursor += 5
				case .uInt64, .int64, .float64:
					relativeDictionary.storage[key] = .fixedWidth(valueFormat, pointer: cursor + 1)
					cursor += 9
				case .fixString:
					let length = Int(decoder.storage[cursor] - valueFormat.rawValue)
					cursor += 1
					relativeDictionary.storage[key] = .variableWidth(valueFormat, pointer: cursor, length: length)
					cursor += length
				case .string16:
					let length = Int(decoder.storage.bigEndianInteger(at: cursor + 1) as UInt16)
					cursor += 3
					relativeDictionary.storage[key] = .variableWidth(valueFormat, pointer: cursor, length: length)
					cursor += length
				case .string32:
					let length = Int(decoder.storage.bigEndianInteger(at: cursor + 1) as UInt16)
					cursor += 5
					relativeDictionary.storage[key] = .variableWidth(valueFormat, pointer: cursor, length: length)
					cursor += length
				case .fixArray, .array16, .array32:
					fatalError("not implemented")
				case .fixMap, .map16, .map32:
					decoder.cursor = cursor
					let container = try MsgPckKeyedDecodingContainer<TemporaryCodingKey>(referringTo: decoder, with: codingPath + [TemporaryCodingKey(stringValue: key)!])
					cursor += container.relativeDictionary.byteCount
				}
			}
			relativeDictionary.byteCount = cursor - relativeDictionary.pointer
		}
	}
	
	func contains(_ key: K) -> Bool {
		return relativeDictionary.storage[key.stringValue] != nil
	}
	
	func decodeNil(forKey key: K) throws -> Bool {
		switch relativeDictionary.storage[key.stringValue]! {
		case .constant(let format):
			return format == .nil
		default:
			return false
		}
	}
	
	func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
		guard let value = relativeDictionary.storage[key.stringValue] else {
			throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Key not found: \(key.stringValue)"))
		}
		guard case let .constant(format) = value else {
			throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected bool but found \(value)"))
		}
		switch format {
		case .true, .false:
			return format == .true
		default:
			throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected bool but found \(format)"))
		}
	}
	
	func formattedPointer<T>(for key: K, format expectedFormat: FormatID, type: T.Type) throws -> Int {
		guard let value = relativeDictionary.storage[key.stringValue] else {
			throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Key not found: \(key.stringValue)"))
		}
		guard case let .fixedWidth(format, pointer) = value else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected fixed width value but found \(value)")
		}
		guard format == expectedFormat else {
			throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected \(expectedFormat) but found \(format)"))
		}
		return pointer
	}
	
	func decode(_ type: Int.Type, forKey key: K) throws -> Int {
		fatalError("not implemented")
	}
	
	func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
		return decoder.storage.read(at: try formattedPointer(for: key, format: .int8, type: type))
	}
	
	func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .int16, type: type))
	}
	
	func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .int32, type: type))
	}
	
	func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .int64, type: type))
	}
	
	func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
		fatalError("not implemented")
	}
	
	func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
		return decoder.storage[try formattedPointer(for: key, format: .uInt8, type: type)]
	}
	
	func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .uInt16, type: type))
	}
	
	func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .uInt32, type: type))
	}
	
	func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
		return decoder.storage.bigEndianInteger(at: try formattedPointer(for: key, format: .uInt64, type: type))
	}
	
	func decode(_ type: Float.Type, forKey key: K) throws -> Float {
		let pointer = try formattedPointer(for: key, format: .float32, type: type)
		return Float(bitPattern: decoder.storage.bigEndianInteger(at: pointer) as UInt32)
	}
	
	func decode(_ type: Double.Type, forKey key: K) throws -> Double {
		let pointer = try formattedPointer(for: key, format: .float64, type: type)
		return Double(bitPattern: decoder.storage.bigEndianInteger(at: pointer) as UInt64)
	}
	
	func decode(_ type: String.Type, forKey key: K) throws -> String {
		guard let value = relativeDictionary.storage[key.stringValue] else {
			throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Key not found: \(key.stringValue)"))
		}
		guard case let .variableWidth(format, base, length) = value else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected variable width value but found \(value)")
		}
		guard [.string8, .string16, .string32, .fixString].contains(format) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected a string but found \(format)"))
		}
		guard let string = decoder.storage.withUnsafeMutableBytes({
			String(bytesNoCopy: $0.advanced(by: base), length: length, encoding: .utf8, freeWhenDone: false)
		}) else {
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "not a valid string"))
		}
		return string
	}
	
	func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
		let sliceDecoder = try superDecoder(forKey: key)
		return try T(from: sliceDecoder)
	}
	
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		return KeyedDecodingContainer(try MsgPckKeyedDecodingContainer<NestedKey>(referringTo: decoder, with: codingPath + [key]))
	}
	
	func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
		fatalError("not implemented")
	}
	
	func superDecoder() throws -> Swift.Decoder {
		return decoder
	}
	
	func superDecoder(forKey key: K) throws -> Swift.Decoder {
		guard let value = relativeDictionary.storage[key.stringValue] else {
			throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Key not found: \(key.stringValue)"))
		}
		let sliceDecoder: IntermediateDecoder
		switch value {
			
		case .constant(let format):
			sliceDecoder = IntermediateDecoder(with: Data([format.rawValue]))
		case let .fixedWidth(format, pointer):
			sliceDecoder = IntermediateDecoder(withUnsafeDataFrom: decoder, start: pointer - format.length)
		case let .variableWidth(format, pointer, length):
			sliceDecoder = IntermediateDecoder(withUnsafeDataFrom: decoder, start: pointer - format.length, length: length + format.length)
		case .array(_):
			fatalError("not implemented")
		case let .dictionary(reference):
			sliceDecoder = IntermediateDecoder(withUnsafeDataFrom: decoder, start: reference.pointer, length: reference.byteCount)
		}
		sliceDecoder.codingPath = codingPath + [key]
		return sliceDecoder
	}
	
	typealias Key = K
}
