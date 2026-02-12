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
        SchoolDatabase.universityCoordinates[name]
            ?? CLLocationCoordinate2D(latitude: 28.5383, longitude: -81.3792)
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
