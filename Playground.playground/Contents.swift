//: Playground - noun: a place where people can play

import MsgPack

var number: UInt16 = 0x0906

let data = try Encoder().encode(number)
data[1]
data[2]
