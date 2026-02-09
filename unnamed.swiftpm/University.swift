import SwiftData
import Foundation

@available(iOS 17.0, *)
@Model
final class University {
    var name: String
    var tuitionRate: Double
    var colorHex: String

    init(name: String, tuitionRate: Double, colorHex: String) {
        self.name = name
        self.tuitionRate = tuitionRate
        self.colorHex = colorHex
    }
}
