import SwiftData
import Foundation
import CoreLocation
import SwiftUI

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
    var location: CLLocationCoordinate2D {
        switch name {
        case "Valencia College": return CLLocationCoordinate2D(latitude: 28.5218, longitude: -81.4641)
        case "UCF": return CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
        case "Univ. of Florida": return CLLocationCoordinate2D(latitude: 29.6436, longitude: -82.3549)
        case "FIU": return CLLocationCoordinate2D(latitude: 25.7562, longitude: -80.3755)
        case "Miami Dade College": return CLLocationCoordinate2D(latitude: 25.7778, longitude: -80.1902)
        case "UCLA": return CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452)
        default: return CLLocationCoordinate2D(latitude: 28.5383, longitude: -81.3792)
        }
    }
    
    var iconName: String {
        switch name {
        case "Valencia College": return "book.fill"
        case "UCF": return "star.fill"
        case "Univ. of Florida": return "lizard.fill"
        case "FIU": return "pawprint.fill"
        case "Miami Dade College": return "building.columns.fill"
        case "UCLA": return "film.fill"
        default: return "graduationcap.fill"
        }
    }
}

@available(iOS 17.0, *)
@Model
final class Course {
    var code: String
    var title: String
    var credits: Int

    init(code: String, title: String, credits: Int) {
        self.code = code
        self.title = title
        self.credits = credits
    }
}

@available(iOS 17.0, *)
@Model
final class SimulationState {
    var userSavings: Double
    var rentCost: Double
    var tuitionGap: Double

    init(userSavings: Double, rentCost: Double, tuitionGap: Double) {
        self.userSavings = userSavings
        self.rentCost = rentCost
        self.tuitionGap = tuitionGap
    }
}
