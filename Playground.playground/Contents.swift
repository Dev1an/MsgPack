//: Playground - noun: a place where people can play

import MsgPack
import Foundation

let encoder = Encoder()

try encoder.encode(0x0102030405060708)

try encoder.encode("Hello")

try encoder.encode("😇")

var n: Int?
try encoder.encode(n)

struct Position: Encodable {
	let x: Int8
	let y: Int8
}

struct Circle: Encodable {
	let center: Position
	let radius: UInt
}

do {
	try encoder.encode(Circle(center: Position(x: -1, y: 2), radius: 50)).forEach { print(String($0, radix: 16)) }
} catch {
	error
}
