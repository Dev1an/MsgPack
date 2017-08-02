#  Usage

```swift
import MsgPack

let encoder = Encoder()
try encoder.encode("Hello world")
try encoder.encode("😇")
try encoder.encode(0x0102030405060708)
try encoder.encode(["Some strings", "in an array"])
```

Take a look at the [playground](Playground.playground/Contents.swift) for more examples.