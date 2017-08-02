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

let encodedGraph = try encoder.encode(graph)
for byte in encodedGraph {
	print(String(byte, radix:16))
}

let decoder = Decoder()

func roundtrip<T: Codable>(value: T) throws -> T {
	return try decoder.decode(T.self, from: encoder.encode(value))
}

var x: UInt64? = nil
try roundtrip(value: false)
