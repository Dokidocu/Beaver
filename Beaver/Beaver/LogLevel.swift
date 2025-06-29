import os.log

public enum LogLevel: Int, CaseIterable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public var level: Int {
        return rawValue
    }
    
    public var osLogType: OSLogType {
        let result: OSLogType
        switch self {
        case .debug: result = OSLogType.debug
        case .info: result = OSLogType.info
        case .warning: result = OSLogType.default  // Changed from .fault for better mapping
        case .error: result = OSLogType.error
        }
        return result
    }
    
    public var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}
