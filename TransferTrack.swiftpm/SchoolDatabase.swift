import SwiftUI
import CoreLocation

// MARK: - school database

struct SchoolDatabase {

    // MARK: state to school mapping

    static let stateData: [String: (ccs: [String], unis: [String])] = [
        "Florida": (
            ccs: ["Valencia College", "Miami Dade College", "Seminole State", "Polk State", "Santa Fe College"],
            unis: ["UCF", "Univ. of Florida", "FSU", "USF", "FIU"]
        ),
        "California": (
            ccs: ["Santa Monica College", "De Anza College", "Pasadena City College", "Diablo Valley College", "Orange Coast College"],
            unis: ["UCLA", "UC Berkeley", "UC Davis", "CSU LA", "San Jose State"]
        ),
        "Texas": (
            ccs: ["Austin CC", "Houston CC", "Lone Star College", "Dallas College", "Alamo Colleges"],
            unis: ["UT Austin", "Texas A&M", "Univ. of Houston", "UTSA", "Texas State"]
        ),
        "Virginia": (
            ccs: ["NOVA", "Tidewater CC", "Virginia Western CC", "Reynolds CC"],
            unis: ["UVA", "Virginia Tech", "JMU", "George Mason", "VCU"]
        ),
        "Washington": (
            ccs: ["Seattle Central", "Bellevue College", "Spokane CC", "Green River College"],
            unis: ["Univ. of Washington", "WSU", "Central Washington", "Eastern Washington"]
        ),
        "North Carolina": (
            ccs: ["Central Piedmont CC", "Wake Tech", "Guilford Tech", "Cape Fear CC"],
            unis: ["UNC Chapel Hill", "NC State", "App State", "ECU", "UNC Charlotte"]
        ),
        "New Jersey": (
            ccs: ["Bergen CC", "Middlesex College", "Camden County College", "Union College"],
            unis: ["Rutgers", "Rowan Univ.", "Montclair State", "NJIT", "Stockton Univ."]
        )
    ]

    static var states: [String] { Array(stateData.keys).sorted() }

    // MARK: university coordinate for MapKit

    static let universityCoordinates: [String: CLLocationCoordinate2D] = [
        // Florida
        "Valencia College":     CLLocationCoordinate2D(latitude: 28.5218, longitude: -81.4641),
        "Miami Dade College":   CLLocationCoordinate2D(latitude: 25.7778, longitude: -80.1902),
        "Seminole State":       CLLocationCoordinate2D(latitude: 28.7472, longitude: -81.3102),
        "Polk State":           CLLocationCoordinate2D(latitude: 28.0557, longitude: -81.9498),
        "Santa Fe College":     CLLocationCoordinate2D(latitude: 29.6820, longitude: -82.3710),
        "UCF":                  CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001),
        "Univ. of Florida":     CLLocationCoordinate2D(latitude: 29.6436, longitude: -82.3549),
        "FSU":                  CLLocationCoordinate2D(latitude: 30.4415, longitude: -84.2985),
        "USF":                  CLLocationCoordinate2D(latitude: 28.0587, longitude: -82.4139),
        "FIU":                  CLLocationCoordinate2D(latitude: 25.7562, longitude: -80.3755),
        // California
        "Santa Monica College":     CLLocationCoordinate2D(latitude: 34.0156, longitude: -118.4713),
        "De Anza College":          CLLocationCoordinate2D(latitude: 37.3197, longitude: -122.0454),
        "Pasadena City College":    CLLocationCoordinate2D(latitude: 34.1410, longitude: -118.1258),
        "Diablo Valley College":    CLLocationCoordinate2D(latitude: 37.9686, longitude: -122.0713),
        "Orange Coast College":     CLLocationCoordinate2D(latitude: 33.6687, longitude: -117.9134),
        "UCLA":                     CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
        "UC Berkeley":              CLLocationCoordinate2D(latitude: 37.8719, longitude: -122.2585),
        "UC Davis":                 CLLocationCoordinate2D(latitude: 38.5382, longitude: -121.7617),
        "CSU LA":                   CLLocationCoordinate2D(latitude: 34.0662, longitude: -118.1684),
        "San Jose State":           CLLocationCoordinate2D(latitude: 37.3352, longitude: -121.8811),
        // Texas
        "Austin CC":        CLLocationCoordinate2D(latitude: 30.3900, longitude: -97.7268),
        "Houston CC":       CLLocationCoordinate2D(latitude: 29.7188, longitude: -95.3431),
        "Lone Star College": CLLocationCoordinate2D(latitude: 30.0485, longitude: -95.4385),
        "Dallas College":   CLLocationCoordinate2D(latitude: 32.8198, longitude: -96.8499),
        "Alamo Colleges":   CLLocationCoordinate2D(latitude: 29.4685, longitude: -98.5254),
        "UT Austin":        CLLocationCoordinate2D(latitude: 30.2849, longitude: -97.7341),
        "Texas A&M":        CLLocationCoordinate2D(latitude: 30.6187, longitude: -96.3365),
        "Univ. of Houston": CLLocationCoordinate2D(latitude: 29.7199, longitude: -95.3422),
        "UTSA":             CLLocationCoordinate2D(latitude: 29.5831, longitude: -98.6199),
        "Texas State":      CLLocationCoordinate2D(latitude: 29.8884, longitude: -97.9384),
        // Virginia
        "NOVA":                 CLLocationCoordinate2D(latitude: 38.8306, longitude: -77.3056),
        "Tidewater CC":         CLLocationCoordinate2D(latitude: 36.8373, longitude: -76.1970),
        "Virginia Western CC":  CLLocationCoordinate2D(latitude: 37.2718, longitude: -79.9706),
        "Reynolds CC":          CLLocationCoordinate2D(latitude: 37.5927, longitude: -77.5621),
        "UVA":                  CLLocationCoordinate2D(latitude: 38.0336, longitude: -78.5080),
        "Virginia Tech":        CLLocationCoordinate2D(latitude: 37.2296, longitude: -80.4139),
        "JMU":                  CLLocationCoordinate2D(latitude: 38.4341, longitude: -78.8693),
        "George Mason":         CLLocationCoordinate2D(latitude: 38.8316, longitude: -77.3091),
        "VCU":                  CLLocationCoordinate2D(latitude: 37.5479, longitude: -77.4529),
        // Washington
        "Seattle Central":      CLLocationCoordinate2D(latitude: 47.6164, longitude: -122.3215),
        "Bellevue College":     CLLocationCoordinate2D(latitude: 47.5979, longitude: -122.1502),
        "Spokane CC":           CLLocationCoordinate2D(latitude: 47.6716, longitude: -117.3860),
        "Green River College":  CLLocationCoordinate2D(latitude: 47.3295, longitude: -122.2620),
        "Univ. of Washington":  CLLocationCoordinate2D(latitude: 47.6553, longitude: -122.3035),
        "WSU":                  CLLocationCoordinate2D(latitude: 46.7319, longitude: -117.1542),
        "Central Washington":   CLLocationCoordinate2D(latitude: 46.9965, longitude: -120.5477),
        "Eastern Washington":   CLLocationCoordinate2D(latitude: 47.4892, longitude: -117.5813),
        // North Carolina
        "Central Piedmont CC":  CLLocationCoordinate2D(latitude: 35.2068, longitude: -80.8455),
        "Wake Tech":            CLLocationCoordinate2D(latitude: 35.7173, longitude: -78.5755),
        "Guilford Tech":        CLLocationCoordinate2D(latitude: 36.0228, longitude: -79.8862),
        "Cape Fear CC":         CLLocationCoordinate2D(latitude: 34.2299, longitude: -77.8717),
        "UNC Chapel Hill":      CLLocationCoordinate2D(latitude: 35.9049, longitude: -79.0469),
        "NC State":             CLLocationCoordinate2D(latitude: 35.7847, longitude: -78.6821),
        "App State":            CLLocationCoordinate2D(latitude: 36.2154, longitude: -81.6846),
        "ECU":                  CLLocationCoordinate2D(latitude: 35.6050, longitude: -77.3714),
        "UNC Charlotte":        CLLocationCoordinate2D(latitude: 35.3074, longitude: -80.7331),
        // New Jersey
        "Bergen CC":            CLLocationCoordinate2D(latitude: 40.9506, longitude: -74.0767),
        "Middlesex College":    CLLocationCoordinate2D(latitude: 40.4514, longitude: -74.3775),
        "Camden County College": CLLocationCoordinate2D(latitude: 39.7885, longitude: -74.9656),
        "Union College":        CLLocationCoordinate2D(latitude: 40.6615, longitude: -74.3057),
        "Rutgers":              CLLocationCoordinate2D(latitude: 40.5008, longitude: -74.4474),
        "Rowan Univ.":          CLLocationCoordinate2D(latitude: 39.7092, longitude: -75.1189),
        "Montclair State":      CLLocationCoordinate2D(latitude: 40.8624, longitude: -74.1998),
        "NJIT":                 CLLocationCoordinate2D(latitude: 40.7425, longitude: -74.1793),
        "Stockton Univ.":       CLLocationCoordinate2D(latitude: 39.4785, longitude: -74.5634),
    ]

    // MARK: logo asset Names

    static let logoMap: [String: String] = [
        "Valencia College": "valencia-college", "Miami Dade College": "miami-dade-college",
        "Seminole State": "seminole-state", "Polk State": "polk-state", "Santa Fe College": "santa-fe-college",
        "UCF": "ucf", "Univ. of Florida": "univ-of-florida", "FSU": "fsu", "USF": "usf", "FIU": "fiu",
        "Santa Monica College": "santa-monica-college", "De Anza College": "de-anza-college",
        "Pasadena City College": "pasadena-city-college", "Diablo Valley College": "diablo-valley-college",
        "Orange Coast College": "orange-coast-college",
        "UCLA": "ucla", "UC Berkeley": "uc-berkeley", "UC Davis": "uc-davis", "CSU LA": "csu-la", "San Jose State": "san-jose-state",
        "Austin CC": "austin-cc", "Houston CC": "houston-cc", "Lone Star College": "lone-star-college",
        "Dallas College": "dallas-college", "Alamo Colleges": "alamo-colleges",
        "UT Austin": "ut-austin", "Texas A&M": "texas-am", "Univ. of Houston": "univ-of-houston",
        "UTSA": "utsa", "Texas State": "texas-state",
        "NOVA": "nova", "Tidewater CC": "tidewater-cc", "Virginia Western CC": "virginia-western-cc", "Reynolds CC": "reynolds-cc",
        "UVA": "uva", "Virginia Tech": "virginia-tech", "JMU": "jmu", "George Mason": "george-mason", "VCU": "vcu",
        "Seattle Central": "seattle-central", "Bellevue College": "bellevue-college",
        "Spokane CC": "spokane-cc", "Green River College": "green-river-college",
        "Univ. of Washington": "univ-of-washington", "WSU": "wsu",
        "Central Washington": "central-washington", "Eastern Washington": "eastern-washington",
        "Central Piedmont CC": "central-piedmont-cc", "Wake Tech": "wake-tech",
        "Guilford Tech": "guilford-tech", "Cape Fear CC": "cape-fear-cc",
        "UNC Chapel Hill": "unc-chapel-hill", "NC State": "nc-state", "App State": "app-state",
        "ECU": "ecu", "UNC Charlotte": "unc-charlotte",
        "Bergen CC": "bergen-cc", "Middlesex College": "middlesex-college",
        "Camden County College": "camden-county-college", "Union College": "union-college",
        "Rutgers": "rutgers", "Rowan Univ.": "rowan-univ", "Montclair State": "montclair-state",
        "NJIT": "njit", "Stockton Univ.": "stockton-univ",
    ]

    // MARK: tuition data

    static let ccTuition: [String: Int] = [
        "Valencia College": 3120, "Miami Dade College": 3400, "Seminole State": 3100,
        "Polk State": 2900, "Santa Fe College": 2800,
        "Santa Monica College": 1400, "De Anza College": 1500, "Pasadena City College": 1400,
        "Diablo Valley College": 1500, "Orange Coast College": 1400,
        "Austin CC": 2700, "Houston CC": 2600, "Lone Star College": 2500,
        "Dallas College": 2400, "Alamo Colleges": 2500,
        "NOVA": 5600, "Tidewater CC": 5200, "Virginia Western CC": 4800, "Reynolds CC": 5000,
        "Seattle Central": 4100, "Bellevue College": 3900, "Spokane CC": 4000, "Green River College": 3800,
        "Central Piedmont CC": 2800, "Wake Tech": 2900, "Guilford Tech": 2700, "Cape Fear CC": 2600,
        "Bergen CC": 5200, "Middlesex College": 4800, "Camden County College": 4600, "Union College": 5000,
    ]

    static let uniTuition: [String: Int] = [
        "UCF": 6368, "Univ. of Florida": 6380, "FSU": 5656, "USF": 6410, "FIU": 6558,
        "UCLA": 13804, "UC Berkeley": 14312, "UC Davis": 14495, "CSU LA": 6920, "San Jose State": 7852,
        "UT Austin": 11448, "Texas A&M": 12034, "Univ. of Houston": 11164, "UTSA": 10100, "Texas State": 11200,
        "UVA": 19414, "Virginia Tech": 14620, "JMU": 12426, "George Mason": 12564, "VCU": 14672,
        "Univ. of Washington": 12076, "WSU": 11584, "Central Washington": 8565, "Eastern Washington": 8142,
        "UNC Chapel Hill": 8998, "NC State": 9101, "App State": 7296, "ECU": 7287, "UNC Charlotte": 7108,
        "Rutgers": 15804, "Rowan Univ.": 13880, "Montclair State": 13288, "NJIT": 18096, "Stockton Univ.": 13558,
    ]

    // MARK: housing

    struct Apartment {
        let name: String
        let distance: String
        let beds: Int
        let baths: Int
        let rent: Int
        let odds: String
        let oddsDetail: String
    }

    static func housing(for university: String) -> [Apartment] {
        switch university {
        case "UCF":
            return [
                Apartment(name: "Knights Landing", distance: "0.5 mi", beds: 2, baths: 2, rent: 1200, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "University House", distance: "1.2 mi", beds: 1, baths: 1, rent: 950, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "The Pointe at Central", distance: "0.8 mi", beds: 2, baths: 2, rent: 1450, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Tivoli Apartments", distance: "2.1 mi", beds: 1, baths: 1, rent: 800, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Northgate Lakes", distance: "0.3 mi", beds: 4, baths: 4, rent: 780, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Arden Villas", distance: "1.5 mi", beds: 3, baths: 3, rent: 680, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        case "Univ. of Florida":
            return [
                Apartment(name: "Gainesville Place", distance: "0.7 mi", beds: 2, baths: 2, rent: 950, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "The Estates", distance: "1.3 mi", beds: 1, baths: 1, rent: 1100, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Lexington Crossing", distance: "0.5 mi", beds: 4, baths: 4, rent: 650, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Campus Lodge", distance: "1.8 mi", beds: 2, baths: 2, rent: 880, odds: "High Odds", oddsDetail: "No Credit Check"),
            ]
        case "FSU":
            return [
                Apartment(name: "Stadium Centre", distance: "0.4 mi", beds: 2, baths: 2, rent: 1050, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "The Osceola", distance: "1.0 mi", beds: 1, baths: 1, rent: 900, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "College Town", distance: "0.2 mi", beds: 3, baths: 3, rent: 750, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        case "USF":
            return [
                Apartment(name: "The Venue", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Avalon Heights", distance: "1.4 mi", beds: 1, baths: 1, rent: 850, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "42 North", distance: "0.3 mi", beds: 4, baths: 2, rent: 720, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        case "FIU":
            return [
                Apartment(name: "109 Tower", distance: "0.6 mi", beds: 2, baths: 2, rent: 1350, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Student Housing FIU", distance: "Adjacent", beds: 1, baths: 1, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "The Flats at CityPlace", distance: "2.0 mi", beds: 2, baths: 2, rent: 1600, odds: "Low Odds", oddsDetail: "Guarantor Required"),
            ]
        case "UCLA":
            return [
                Apartment(name: "Westwood Palms", distance: "0.8 mi", beds: 2, baths: 2, rent: 2800, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Kelton Towers", distance: "0.5 mi", beds: 1, baths: 1, rent: 2200, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Weyburn Terrace", distance: "0.3 mi", beds: 2, baths: 1, rent: 2400, odds: "Medium Odds", oddsDetail: "UCLA Housing"),
                Apartment(name: "Gayley Heights", distance: "0.4 mi", beds: 1, baths: 1, rent: 1900, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "UC Berkeley":
            return [
                Apartment(name: "Hillside Village", distance: "0.6 mi", beds: 2, baths: 1, rent: 2600, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Durant Square", distance: "0.3 mi", beds: 1, baths: 1, rent: 2100, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Panoramic", distance: "0.2 mi", beds: 1, baths: 1, rent: 1800, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "UC Davis":
            return [
                Apartment(name: "The Ramble", distance: "0.7 mi", beds: 2, baths: 2, rent: 1600, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "West Village", distance: "Adjacent", beds: 1, baths: 1, rent: 1350, odds: "High Odds", oddsDetail: "UC Housing"),
                Apartment(name: "Aggie Square", distance: "1.0 mi", beds: 2, baths: 1, rent: 1400, odds: "High Odds", oddsDetail: "No Credit Check"),
            ]
        case "CSU LA":
            return [
                Apartment(name: "Cal State Village", distance: "Adjacent", beds: 2, baths: 2, rent: 1200, odds: "High Odds", oddsDetail: "Student Housing"),
                Apartment(name: "El Sereno Flats", distance: "1.5 mi", beds: 1, baths: 1, rent: 1050, odds: "High Odds", oddsDetail: "No Credit Check"),
            ]
        case "San Jose State":
            return [
                Apartment(name: "South Campus", distance: "0.3 mi", beds: 2, baths: 2, rent: 1800, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Spartan Village", distance: "0.5 mi", beds: 1, baths: 1, rent: 1500, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "UT Austin":
            return [
                Apartment(name: "West Campus Lofts", distance: "0.4 mi", beds: 2, baths: 2, rent: 1500, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "The Callaway", distance: "0.6 mi", beds: 1, baths: 1, rent: 1200, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Riverside Terrace", distance: "1.5 mi", beds: 2, baths: 1, rent: 1050, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "26 West", distance: "0.3 mi", beds: 4, baths: 4, rent: 950, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        case "Texas A&M":
            return [
                Apartment(name: "The Stack", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "College Station Crossing", distance: "1.2 mi", beds: 1, baths: 1, rent: 850, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Park West", distance: "0.8 mi", beds: 4, baths: 4, rent: 650, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        default:
            return [
                Apartment(name: "Campus View Apartments", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "University Commons", distance: "1.0 mi", beds: 1, baths: 1, rent: 900, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "College Park", distance: "1.5 mi", beds: 2, baths: 1, rent: 800, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Student Living", distance: "0.3 mi", beds: 4, baths: 4, rent: 650, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        }
    }

    static func averageRent(for university: String) -> Int {
        let apts = housing(for: university)
        guard !apts.isEmpty else { return 1000 }
        return apts.reduce(0) { $0 + $1.rent } / apts.count
    }

    // MARK: course transfer

    struct CourseTransfer {
        let name: String
        let code: String
        let credits: Int
        let grade: String
        let transfers: Bool
        let costIfWasted: Int
    }

    static func courses(from cc: String, to uni: String) -> [CourseTransfer] {
        var transferable: [CourseTransfer] = [
            CourseTransfer(name: "English Composition I", code: "ENC 1101", credits: 3, grade: "A-", transfers: true, costIfWasted: 0),
            CourseTransfer(name: "College Algebra", code: "MAC 1105", credits: 3, grade: "B+", transfers: true, costIfWasted: 0),
            CourseTransfer(name: "General Psychology", code: "PSY 2012", credits: 3, grade: "B", transfers: true, costIfWasted: 0),
            CourseTransfer(name: "Statistics", code: "STA 2023", credits: 3, grade: "A", transfers: true, costIfWasted: 0),
            CourseTransfer(name: "Microeconomics", code: "ECO 2023", credits: 3, grade: "B+", transfers: true, costIfWasted: 0),
        ]

        if ["UCF", "UT Austin", "UCLA", "UC Berkeley", "Georgia Tech", "Virginia Tech"].contains(uni) {
            transferable.append(contentsOf: [
                CourseTransfer(name: "Intro to Programming", code: "COP 2000", credits: 3, grade: "A", transfers: true, costIfWasted: 0),
                CourseTransfer(name: "Calculus I", code: "MAC 2311", credits: 4, grade: "B+", transfers: true, costIfWasted: 0),
                CourseTransfer(name: "Data Structures", code: "COP 3530", credits: 3, grade: "A-", transfers: true, costIfWasted: 0),
                CourseTransfer(name: "Physics I", code: "PHY 2048", credits: 4, grade: "B", transfers: true, costIfWasted: 0),
            ])
        } else {
            transferable.append(contentsOf: [
                CourseTransfer(name: "Biology I", code: "BSC 1010", credits: 4, grade: "B", transfers: true, costIfWasted: 0),
                CourseTransfer(name: "Public Speaking", code: "SPC 1608", credits: 3, grade: "A", transfers: true, costIfWasted: 0),
            ])
        }

        let wasted: [CourseTransfer] = [
            CourseTransfer(name: "Art Appreciation", code: "ARH 1000", credits: 3, grade: "A", transfers: false, costIfWasted: 600),
            CourseTransfer(name: "Music of the World", code: "MUH 2012", credits: 3, grade: "B+", transfers: false, costIfWasted: 600),
            CourseTransfer(name: "Humanities Elective", code: "HUM 2230", credits: 3, grade: "B", transfers: false, costIfWasted: 600),
        ]

        return transferable + wasted
    }

    // MARK: solutions

    struct Solution {
        let title: String
        let description: String
        let points: Int
        let icon: String
        let color: Color
    }

    static func solutions(for uni: String, from cc: String, state: String) -> [Solution] {
        var items: [Solution] = []

        switch state {
        case "Florida":
            items.append(Solution(title: "Apply for DirectConnect", description: "Guaranteed admission from \(cc) to \(uni) with 2.0+ GPA", points: 8, icon: "link", color: .blue))
            items.append(Solution(title: "Apply for Bright Futures", description: "State scholarship covering up to 100% tuition", points: 7, icon: "star.fill", color: .yellow))
        case "California":
            items.append(Solution(title: "Use TAG Agreement", description: "Transfer Admission Guarantee to \(uni)", points: 8, icon: "link", color: .blue))
            items.append(Solution(title: "Apply for Cal Grant", description: "State financial aid for CA residents", points: 7, icon: "star.fill", color: .yellow))
        case "Texas":
            items.append(Solution(title: "Use Texas Core Curriculum", description: "42-credit guaranteed transfer block to \(uni)", points: 8, icon: "link", color: .blue))
            items.append(Solution(title: "Apply for TEXAS Grant", description: "State need-based financial aid", points: 7, icon: "star.fill", color: .yellow))
        case "Virginia":
            items.append(Solution(title: "Use GAA Transfer", description: "Guaranteed Admission Agreement to \(uni)", points: 8, icon: "link", color: .blue))
        case "Washington":
            items.append(Solution(title: "Use DTA Degree", description: "Direct Transfer Agreement guarantees junior standing", points: 8, icon: "link", color: .blue))
        case "North Carolina":
            items.append(Solution(title: "Use CAA Transfer", description: "Comprehensive Articulation Agreement to UNC system", points: 8, icon: "link", color: .blue))
        case "New Jersey":
            items.append(Solution(title: "Use NJ Transfer", description: "Statewide transfer agreement to \(uni)", points: 8, icon: "link", color: .blue))
        default:
            break
        }

        items.append(contentsOf: [
            Solution(title: "Submit FAFSA Renewal", description: "Financial aid must be renewed for \(uni)", points: 10, icon: "doc.text.fill", color: .green),
            Solution(title: "Appeal Credit Transfer", description: "Contest at-risk credits with syllabus docs", points: 5, icon: "arrow.uturn.backward", color: .red),
            Solution(title: "Find a Roommate", description: "Split rent costs to reduce monthly gap", points: 6, icon: "person.2.fill", color: .purple),
            Solution(title: "Apply for Transfer Scholarships", description: "\(uni) offers transfer-specific awards", points: 7, icon: "dollarsign.circle.fill", color: .orange),
            Solution(title: "Set Up Emergency Fund", description: "Save 3 months of projected gap before transfer", points: 3, icon: "banknote.fill", color: .cyan),
            Solution(title: "Get a Campus Job", description: "\(uni) Federal Work-Study covers ~$200/mo", points: 4, icon: "briefcase.fill", color: .brown),
        ])

        return items
    }
}
