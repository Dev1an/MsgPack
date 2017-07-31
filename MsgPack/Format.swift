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
	
	case uInt  (UInt)
	case uInt8 (UInt8)
	case uInt16(UInt16)
	case uInt32(UInt32)
	case uInt64(UInt64)
	
	case int  (Int)
	case int8 (Int8)
	case int16(Int16)
	case int32(Int32)
	case int64(Int64)
	
	case float32(Float)
	case float64(Double)

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
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xCD
				byteContainer.advanced(by: 1).withMemoryRebound(to: UInt16.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .uInt32(let value):
			var newData = Data(count: 5)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xCE
				byteContainer.advanced(by: 1).withMemoryRebound(to: UInt32.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .uInt64(let value):
			var newData = Data(count: 9)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xCF
				byteContainer.advanced(by: 1).withMemoryRebound(to: UInt64.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .uInt(let value):
			#if arch(arm) || arch(i386)
				Format.uInt32(UInt32(value)).appendTo(data: &data)
			#else
				Format.uInt64(UInt64(value)).appendTo(data: &data)
			#endif
			
		// MARK: Signed integers
		case .int8(let value):
			var newData = Data(count: 2)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xD1
				byteContainer.advanced(by: 1).withMemoryRebound(to: Int8.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .int16(let value):
			var newData = Data(count: 3)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xD2
				byteContainer.advanced(by: 1).withMemoryRebound(to: Int16.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .int32(let value):
			var newData = Data(count: 5)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xD2
				byteContainer.advanced(by: 1).withMemoryRebound(to: Int32.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .int64(let value):
			var newData = Data(count: 9)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xD3
				byteContainer.advanced(by: 1).withMemoryRebound(to: Int64.self, capacity: 1) {
					$0.pointee = value.bigEndian
				}
			})
			data.append(newData)
		case .int(let value):
			#if arch(arm) || arch(i386)
				Format.int32(Int32(value)).appendTo(data: &data)
			#else
				Format.int64(Int64(value)).appendTo(data: &data)
			#endif
			
		// MARK: Floats
		case .float32(let value):
			var newData = Data(count: 5)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xCA
				byteContainer.advanced(by: 1).withMemoryRebound(to: UInt32.self, capacity: 1) {
					$0.pointee = value.bitPattern.bigEndian
				}
			})
			data.append(newData)
		case .float64(let value):
			var newData = Data(count: 9)
			newData.withUnsafeMutableBytes({ (byteContainer: UnsafeMutablePointer<UInt8>) -> Void in
				byteContainer.pointee = 0xCB
				byteContainer.advanced(by: 1).withMemoryRebound(to: UInt64.self, capacity: 1) {
					$0.pointee = value.bitPattern.bigEndian
				}
			})
			data.append(newData)
		}
	}
}
