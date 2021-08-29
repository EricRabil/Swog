
public enum LoggingLevel: UInt8, Codable {
    case info = 1
    case warn = 0
    case error = 16
    case fault = 17
    case debug = 2
}

// MARK: - Old API

@_transparent
public func CLInfo(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: StaticString,
    _ args: CVarArg...
) {
    CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@_transparent
public func CLWarn(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: StaticString,
    _ args: CVarArg...
) {
    CLLog(level: .warn, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@_transparent
public func CLError(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: StaticString,
    _ args: CVarArg...
) {
    CLLog(level: .error, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@_transparent
public func CLFault(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: StaticString,
    _ args: CVarArg...
) {
    CLLog(level: .fault, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}

@_transparent
public func CLDebug(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: StaticString,
    _ args: CVarArg...
) {
    CLLog(level: .debug, fileID: fileID, line: line, function: function, dso: dso, category, message, args)
}


// MARK: - New API

@_transparent
@_optimize(speed)
public func CLInfo(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: BackportedOSLogMessage
) {
    CLLog(level: .info, fileID: fileID, line: line, function: function, dso: dso, category, message)
}

@_transparent
@_optimize(speed)
public func CLWarn(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: BackportedOSLogMessage
) {
    CLLog(level: .warn, fileID: fileID, line: line, function: function, dso: dso, category, message)
}

@_transparent
@_optimize(speed)
public func CLError(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: BackportedOSLogMessage
) {
    CLLog(level: .error, fileID: fileID, line: line, function: function, dso: dso, category, message)
}

@_transparent
@_optimize(speed)
public func CLFault(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: BackportedOSLogMessage
) {
    CLLog(level: .fault, fileID: fileID, line: line, function: function, dso: dso, category, message)
}

@_transparent
@_optimize(speed)
public func CLDebug(
    _ category: StaticString,
    fileID: StaticString = #fileID,
    line: Int = #line,
    function: StaticString = #function,
    dso: UnsafeRawPointer = #dsohandle,
    _ message: BackportedOSLogMessage
) {
    CLLog(level: .debug, fileID: fileID, line: line, function: function, dso: dso, category, message)
}
