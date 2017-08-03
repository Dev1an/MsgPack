//: Playground - noun: a place where people can play

import MsgPack

let encoder = Encoder()

struct Graph: Encodable {
	let title: String
	let circles: [Circle]
}

struct Circle: Encodable {
	let radius: UInt
	let center: Position
}

struct Position: Encodable {
	let x: Int8
	let y: Int8
}

let graph = Graph(
	title: "My graph",
	circles: [
		Circle(
			radius: 0x0102030405060708,
			center: Position(x: -123, y: 2)
		),
		Circle(
			radius: 1000,
			center: Position(x: 116, y: 81)
		)
	]
)

try encoder.encode(graph)

let decoder = Decoder()

func roundtrip<T: Codable>(value: T) throws -> T {
	return try decoder.decode(T.self, from: encoder.encode(value))
}

struct Simple: Codable {
	let a: Bool
	let b: Bool
	let c: Bool?
	let d: Bool?
	let e: Bool?
}

try roundtrip(value: -56.4)
try roundtrip(value: Simple(a: true, b: false, c: true, d: false, e: nil))
