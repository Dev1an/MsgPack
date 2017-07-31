//: Playground - noun: a place where people can play

import MsgPack
import Foundation

let encoder = Encoder()

let integerData = try encoder.encode(0x0102030405060708)
String(integerData[0], radix: 16)

integerData[1]
integerData[2]
integerData[3]
integerData[4]
integerData[5]
integerData[6]
integerData[7]
integerData[8]

let doubleData = try encoder.encode("Hello there 123456789012345678901")
String(doubleData[0], radix: 16)

String(doubleData[1], radix: 16)
String(doubleData[2], radix: 16)
String(doubleData[3], radix: 16)
String(doubleData[4], radix: 16)
String(doubleData[5], radix: 16)
