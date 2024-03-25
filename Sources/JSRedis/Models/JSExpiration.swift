import Foundation

public enum JSExpiration {
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)
    case weeks(TimeInterval)
    case months(TimeInterval)
    case years(TimeInterval)

    public var duration: TimeInterval {
        switch self {
        case .seconds(let seconds): return seconds  * 1
        case .minutes(let minutes): return minutes  * s * 1
        case .hours(let hours):     return hours    * s * m * 1
        case .days(let days):       return days     * s * m * h * 1
        case .weeks(let weeks):     return weeks    * s * m * h * w * 1
        case .months(let months):   return months   * s * m * h * M * 1
        case .years(let years):     return years    * s * m * h * y * 1
        }
    }

    private var s: TimeInterval { 60 }
    private var m: TimeInterval { 60 }
    private var h: TimeInterval { 24 }
    private var w: TimeInterval { 7 }
    private var M: TimeInterval { 30 }
    private var y: TimeInterval { 365 }
}
