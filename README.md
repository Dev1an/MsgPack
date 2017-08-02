#  Usage

```swift
import MsgPack

// Encode standard types
let encoder = Encoder()
try encoder.encode("Hello world")
try encoder.encode("😇")
try encoder.encode(0x0102030405060708)
try encoder.encode(["Some strings", "in an array"])

// Encode custom types with Encodable 🎉
struct Point: Encodable {
  let x: Int
  let y: Int
}
try encoder.encode(Point(x: 90, y: 45))
```

Take a look at the [playground](Playground.playground/Contents.swift) for more examples.