# Swog
Apple, I got a bone to pick with you

Swog is an opionated wrapper around OSLog that uses internal APIs (that frankly should be public since they allowed you to pass an array of CVarArg and a DSOHandle, working around the artificial limitations they leave).

It is mostly inlinable, and aims to be as lightweight of an abstraction as possible. You shouldn't have to type out hieroglyphics to get decent logging, and you shouldn't need to support iOS 14 and up to get logging systems we should've had at iOS 8.

Swog has a driver approach, allowing you to connect it to multiple outlets. It comes with an OSLog and Console driver, but you're welcome to add your own.

## LoggingDriver

The `LoggingDriver` lies at the heart of Swog, and allows you to quickly plug-n-play any logging outlets you need.

It currently has two outlet methods - one that formats string using traditional static strings and CVarArgs, and one that constructs a C string and CVarArgs from a backported implementation of OSLogMessage.

```swift
import Foundation

public protocol LoggingDriver {
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: StaticString, args: [CVarArg])
    func log(level: LoggingLevel, fileID: StaticString, line: Int, function: StaticString, dso: UnsafeRawPointer, category: StaticString, message: BackportedOSLogMessage)
}
```

LoggingDrivers can be installed by directly mutating the exported `LoggingDrivers` array. This is done for performance purposes, as all logging calls are inlined down to an iteration over this array.

Currently, there are two logging drivers that ship with `Swog`:

- `OSLogDriver`
- `ConsoleDriver`

The default value of LoggingDrivers in debug builds is `ConsoleDriver`, and `OSLogDriver` in production. Both can run concurrently as well, or with any other configuration.

## OSLogInterpolation
Swog has backported OSLogInterpolation/OSLogMessage to allow its usage before Big Sur. This is also supported for the Console driver, and it allows privacy specifier enforcement when printing to stdout.

Swog does it's best to maintain performance with this backport, and leverages low-level optimization strategies like `_transparent`,  `inline(__always)`, and `_optimize(speed)` wherever possible/rational. It is routinely checked in both a disassembler and benchmark tests to ensure thin code output and consistently minimal overhead.
