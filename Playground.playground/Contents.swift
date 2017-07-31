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

let doubleData = try encoder.encode(2.5)
String(doubleData[0], radix: 16)
doubleData[1]
doubleData[2]
doubleData[3]
doubleData[4]
doubleData[5]
doubleData[6]
doubleData[7]
doubleData[8]
