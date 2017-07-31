//: Playground - noun: a place where people can play

import MsgPack
import Foundation

var number: UInt16? = 0x0906

let encoder = Encoder()

let data = try encoder.encode(number)
data[1]
data[2]

number = nil

let data2 = try encoder.encode(number)
data2[0]
