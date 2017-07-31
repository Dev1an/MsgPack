//: Playground - noun: a place where people can play

import MsgPack
import Foundation

let encoder = Encoder()

let data = try encoder.encode(0x0102030405060708)

String(data[0], radix: 16)

data[1]
data[2]
data[3]
data[4]
data[5]
data[6]
data[7]
data[8]

try encoder.encode(Int8(6))[1]
