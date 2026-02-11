import SwiftData
import Foundation
import CoreLocation

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

@available(iOS 17.0, *)
extension University {
    // hardcoded coordinates for the challenge demo
    var location: CLLocationCoordinate2D {
        switch name {
        case "Valencia College": return CLLocationCoordinate2D(latitude: 28.5218, longitude: -81.4641)
        case "UCF": return CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
        case "Univ. of Florida": return CLLocationCoordinate2D(latitude: 29.6436, longitude: -82.3549)
        case "FIU": return CLLocationCoordinate2D(latitude: 25.7562, longitude: -80.3755)
        case "UCLA": return CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452)
        default: return CLLocationCoordinate2D(latitude: 28.5383, longitude: -81.3792) // default to orlando
        }
    }
}
