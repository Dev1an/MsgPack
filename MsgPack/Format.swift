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
	case uInt(UInt)
	case uInt8(UInt8)
	case uInt16(UInt16)
	case uInt32(UInt32)
	case uInt64(UInt64)

	func appendTo(data: inout Data) {
		switch self {
			
		case .nil:
			data.append(0xC0)
		case .boolean(let boolean):
			data.append(boolean ? 0xC3 : 0xC2)
		case .positiveInt7(let value):
			data.append(value | 0b10000000)
		case .negativeInt5(let value):
			data.append(value | 0b11100000)
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
		}
	}
}
