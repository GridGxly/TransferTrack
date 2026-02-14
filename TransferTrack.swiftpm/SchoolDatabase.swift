import SwiftUI
import CoreLocation

struct SchoolDatabase {

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

    static let universityCoordinates: [String: CLLocationCoordinate2D] = [
        "Valencia College": CLLocationCoordinate2D(latitude: 28.5218, longitude: -81.4641),
        "Miami Dade College": CLLocationCoordinate2D(latitude: 25.7778, longitude: -80.1902),
        "Seminole State": CLLocationCoordinate2D(latitude: 28.7472, longitude: -81.3102),
        "Polk State": CLLocationCoordinate2D(latitude: 28.0557, longitude: -81.9498),
        "Santa Fe College": CLLocationCoordinate2D(latitude: 29.6820, longitude: -82.3710),
        "UCF": CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001),
        "Univ. of Florida": CLLocationCoordinate2D(latitude: 29.6436, longitude: -82.3549),
        "FSU": CLLocationCoordinate2D(latitude: 30.4415, longitude: -84.2985),
        "USF": CLLocationCoordinate2D(latitude: 28.0587, longitude: -82.4139),
        "FIU": CLLocationCoordinate2D(latitude: 25.7562, longitude: -80.3755),
        "Santa Monica College": CLLocationCoordinate2D(latitude: 34.0156, longitude: -118.4713),
        "De Anza College": CLLocationCoordinate2D(latitude: 37.3197, longitude: -122.0454),
        "Pasadena City College": CLLocationCoordinate2D(latitude: 34.1410, longitude: -118.1258),
        "Diablo Valley College": CLLocationCoordinate2D(latitude: 37.9686, longitude: -122.0713),
        "Orange Coast College": CLLocationCoordinate2D(latitude: 33.6687, longitude: -117.9134),
        "UCLA": CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
        "UC Berkeley": CLLocationCoordinate2D(latitude: 37.8719, longitude: -122.2585),
        "UC Davis": CLLocationCoordinate2D(latitude: 38.5382, longitude: -121.7617),
        "CSU LA": CLLocationCoordinate2D(latitude: 34.0662, longitude: -118.1684),
        "San Jose State": CLLocationCoordinate2D(latitude: 37.3352, longitude: -121.8811),
        "Austin CC": CLLocationCoordinate2D(latitude: 30.3900, longitude: -97.7268),
        "Houston CC": CLLocationCoordinate2D(latitude: 29.7188, longitude: -95.3431),
        "Lone Star College": CLLocationCoordinate2D(latitude: 30.0485, longitude: -95.4385),
        "Dallas College": CLLocationCoordinate2D(latitude: 32.8198, longitude: -96.8499),
        "Alamo Colleges": CLLocationCoordinate2D(latitude: 29.4685, longitude: -98.5254),
        "UT Austin": CLLocationCoordinate2D(latitude: 30.2849, longitude: -97.7341),
        "Texas A&M": CLLocationCoordinate2D(latitude: 30.6187, longitude: -96.3365),
        "Univ. of Houston": CLLocationCoordinate2D(latitude: 29.7199, longitude: -95.3422),
        "UTSA": CLLocationCoordinate2D(latitude: 29.5831, longitude: -98.6199),
        "Texas State": CLLocationCoordinate2D(latitude: 29.8884, longitude: -97.9384),
        "NOVA": CLLocationCoordinate2D(latitude: 38.8306, longitude: -77.3056),
        "Tidewater CC": CLLocationCoordinate2D(latitude: 36.8373, longitude: -76.1970),
        "Virginia Western CC": CLLocationCoordinate2D(latitude: 37.2718, longitude: -79.9706),
        "Reynolds CC": CLLocationCoordinate2D(latitude: 37.5927, longitude: -77.5621),
        "UVA": CLLocationCoordinate2D(latitude: 38.0336, longitude: -78.5080),
        "Virginia Tech": CLLocationCoordinate2D(latitude: 37.2296, longitude: -80.4139),
        "JMU": CLLocationCoordinate2D(latitude: 38.4341, longitude: -78.8693),
        "George Mason": CLLocationCoordinate2D(latitude: 38.8316, longitude: -77.3091),
        "VCU": CLLocationCoordinate2D(latitude: 37.5479, longitude: -77.4529),
        "Seattle Central": CLLocationCoordinate2D(latitude: 47.6164, longitude: -122.3215),
        "Bellevue College": CLLocationCoordinate2D(latitude: 47.5979, longitude: -122.1502),
        "Spokane CC": CLLocationCoordinate2D(latitude: 47.6716, longitude: -117.3860),
        "Green River College": CLLocationCoordinate2D(latitude: 47.3295, longitude: -122.2620),
        "Univ. of Washington": CLLocationCoordinate2D(latitude: 47.6553, longitude: -122.3035),
        "WSU": CLLocationCoordinate2D(latitude: 46.7319, longitude: -117.1542),
        "Central Washington": CLLocationCoordinate2D(latitude: 46.9965, longitude: -120.5477),
        "Eastern Washington": CLLocationCoordinate2D(latitude: 47.4892, longitude: -117.5813),
        "Central Piedmont CC": CLLocationCoordinate2D(latitude: 35.2068, longitude: -80.8455),
        "Wake Tech": CLLocationCoordinate2D(latitude: 35.7173, longitude: -78.5755),
        "Guilford Tech": CLLocationCoordinate2D(latitude: 36.0228, longitude: -79.8862),
        "Cape Fear CC": CLLocationCoordinate2D(latitude: 34.2299, longitude: -77.8717),
        "UNC Chapel Hill": CLLocationCoordinate2D(latitude: 35.9049, longitude: -79.0469),
        "NC State": CLLocationCoordinate2D(latitude: 35.7847, longitude: -78.6821),
        "App State": CLLocationCoordinate2D(latitude: 36.2154, longitude: -81.6846),
        "ECU": CLLocationCoordinate2D(latitude: 35.6050, longitude: -77.3714),
        "UNC Charlotte": CLLocationCoordinate2D(latitude: 35.3074, longitude: -80.7331),
        "Bergen CC": CLLocationCoordinate2D(latitude: 40.9506, longitude: -74.0767),
        "Middlesex College": CLLocationCoordinate2D(latitude: 40.4514, longitude: -74.3775),
        "Camden County College": CLLocationCoordinate2D(latitude: 39.7885, longitude: -74.9656),
        "Union College": CLLocationCoordinate2D(latitude: 40.6615, longitude: -74.3057),
        "Rutgers": CLLocationCoordinate2D(latitude: 40.5008, longitude: -74.4474),
        "Rowan Univ.": CLLocationCoordinate2D(latitude: 39.7092, longitude: -75.1189),
        "Montclair State": CLLocationCoordinate2D(latitude: 40.8624, longitude: -74.1998),
        "NJIT": CLLocationCoordinate2D(latitude: 40.7425, longitude: -74.1793),
        "Stockton Univ.": CLLocationCoordinate2D(latitude: 39.4785, longitude: -74.5634),
    ]

    static let logoMap: [String: String] = [
        "Valencia College": "valencia-college", "Miami Dade College": "miami-dade-college",
        "Seminole State": "seminole-state", "Polk State": "polk-state", "Santa Fe College": "santa-fe-college",
        "UCF": "ucf", "Univ. of Florida": "univ-of-florida", "FSU": "FSU", "USF": "usf", "FIU": "fiu",
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

    struct Apartment: Identifiable {
        let id = UUID()
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
                Apartment(name: "Windsor Park", distance: "2.0 mi", beds: 3, baths: 2, rent: 750, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "FSU":
            return [
                Apartment(name: "Stadium Centre", distance: "0.4 mi", beds: 2, baths: 2, rent: 1050, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "The Osceola", distance: "1.0 mi", beds: 1, baths: 1, rent: 900, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "College Town", distance: "0.2 mi", beds: 3, baths: 3, rent: 750, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Seminole Flatts", distance: "1.5 mi", beds: 2, baths: 1, rent: 820, odds: "High Odds", oddsDetail: "No Credit Check"),
            ]
        case "USF":
            return [
                Apartment(name: "The Venue", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Avalon Heights", distance: "1.4 mi", beds: 1, baths: 1, rent: 850, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "42 North", distance: "0.3 mi", beds: 4, baths: 2, rent: 720, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Province Tampa", distance: "0.8 mi", beds: 2, baths: 2, rent: 980, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "FIU":
            return [
                Apartment(name: "109 Tower", distance: "0.6 mi", beds: 2, baths: 2, rent: 1350, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Student Housing FIU", distance: "0.1 mi", beds: 1, baths: 1, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "The Flats at CityPlace", distance: "2.0 mi", beds: 2, baths: 2, rent: 1600, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Bayview Student Living", distance: "1.2 mi", beds: 3, baths: 2, rent: 900, odds: "High Odds", oddsDetail: "Per-bed Lease"),
            ]
        case "UCLA":
            return [
                Apartment(name: "Westwood Palms", distance: "0.8 mi", beds: 2, baths: 2, rent: 2800, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Kelton Towers", distance: "0.5 mi", beds: 1, baths: 1, rent: 2200, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Weyburn Terrace", distance: "0.3 mi", beds: 2, baths: 1, rent: 2400, odds: "Medium Odds", oddsDetail: "UCLA Housing"),
                Apartment(name: "Gayley Heights", distance: "0.4 mi", beds: 1, baths: 1, rent: 1900, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Levering Terrace", distance: "0.2 mi", beds: 2, baths: 2, rent: 2600, odds: "Medium Odds", oddsDetail: "UCLA Housing"),
            ]
        case "UC Berkeley":
            return [
                Apartment(name: "Hillside Village", distance: "0.6 mi", beds: 2, baths: 1, rent: 2600, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Durant Square", distance: "0.3 mi", beds: 1, baths: 1, rent: 2100, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Panoramic", distance: "0.2 mi", beds: 1, baths: 1, rent: 1800, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Channing Bowditch", distance: "0.4 mi", beds: 2, baths: 2, rent: 2350, odds: "Medium Odds", oddsDetail: "UC Housing"),
                Apartment(name: "Northside Cooperative", distance: "0.5 mi", beds: 1, baths: 1, rent: 1200, odds: "High Odds", oddsDetail: "Co-op Housing"),
            ]
        case "UC Davis":
            return [
                Apartment(name: "The Ramble", distance: "0.7 mi", beds: 2, baths: 2, rent: 1600, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "West Village", distance: "0.1 mi", beds: 1, baths: 1, rent: 1350, odds: "High Odds", oddsDetail: "UC Housing"),
                Apartment(name: "Aggie Square", distance: "1.0 mi", beds: 2, baths: 1, rent: 1400, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Tandem Properties", distance: "0.8 mi", beds: 1, baths: 1, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "UT Austin":
            return [
                Apartment(name: "West Campus Lofts", distance: "0.4 mi", beds: 2, baths: 2, rent: 1500, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "The Callaway", distance: "0.6 mi", beds: 1, baths: 1, rent: 1200, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Riverside Terrace", distance: "1.5 mi", beds: 2, baths: 1, rent: 1050, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "26 West", distance: "0.3 mi", beds: 4, baths: 4, rent: 950, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Dobie Center", distance: "0.1 mi", beds: 1, baths: 1, rent: 1350, odds: "High Odds", oddsDetail: "Student Housing"),
            ]
        case "Texas A&M":
            return [
                Apartment(name: "The Stack", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "College Station Crossing", distance: "1.2 mi", beds: 1, baths: 1, rent: 850, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Park West", distance: "0.8 mi", beds: 4, baths: 4, rent: 650, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "The Junction", distance: "0.3 mi", beds: 2, baths: 2, rent: 1000, odds: "High Odds", oddsDetail: "Student-Friendly"),
            ]
        case "Univ. of Houston":
            return [
                Apartment(name: "Cougar Place", distance: "0.2 mi", beds: 2, baths: 2, rent: 1050, odds: "High Odds", oddsDetail: "Student Housing"),
                Apartment(name: "Bayou Oaks", distance: "0.5 mi", beds: 1, baths: 1, rent: 900, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Cambridge Oaks", distance: "1.5 mi", beds: 2, baths: 1, rent: 850, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Wheeler Transit", distance: "0.8 mi", beds: 1, baths: 1, rent: 780, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
            ]
        default:
            return [
                Apartment(name: "Campus View", distance: "0.5 mi", beds: 2, baths: 2, rent: 1100, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "University Commons", distance: "1.0 mi", beds: 1, baths: 1, rent: 900, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "College Park", distance: "1.5 mi", beds: 2, baths: 1, rent: 800, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "Student Living", distance: "0.3 mi", beds: 4, baths: 4, rent: 650, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Downtown Lofts", distance: "2.0 mi", beds: 1, baths: 1, rent: 750, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
            ]
        }
    }

    static func averageRent(for university: String) -> Int {
        let apts = housing(for: university)
        guard !apts.isEmpty else { return 1000 }
        return apts.reduce(0) { $0 + $1.rent } / apts.count
    }

    struct CourseTransfer: Identifiable {
        let id = UUID()
        let name: String
        let code: String
        let credits: Int
        let grade: String
        let transfers: Bool
        let costIfWasted: Int
        let reason: String
    }

    static func courses(from cc: String, to uni: String) -> [CourseTransfer] {
        var transferable: [CourseTransfer] = [
            CourseTransfer(name: "English Composition I", code: "ENC 1101", credits: 3, grade: "A-", transfers: true, costIfWasted: 0, reason: "Satisfies general education writing requirement"),
            CourseTransfer(name: "College Algebra", code: "MAC 1105", credits: 3, grade: "B+", transfers: true, costIfWasted: 0, reason: "Core math requirement fulfilled"),
            CourseTransfer(name: "General Psychology", code: "PSY 2012", credits: 3, grade: "B", transfers: true, costIfWasted: 0, reason: "Counts toward social science elective"),
            CourseTransfer(name: "Statistics", code: "STA 2023", credits: 3, grade: "A", transfers: true, costIfWasted: 0, reason: "Required for most STEM and business majors"),
            CourseTransfer(name: "Microeconomics", code: "ECO 2023", credits: 3, grade: "B+", transfers: true, costIfWasted: 0, reason: "Accepted as equivalent to \(uni) ECO requirement"),
        ]

        if ["UCF", "UT Austin", "UCLA", "UC Berkeley", "Virginia Tech", "NC State", "NJIT", "Rutgers"].contains(uni) {
            transferable.append(contentsOf: [
                CourseTransfer(name: "Intro to Programming", code: "COP 2000", credits: 3, grade: "A", transfers: true, costIfWasted: 0, reason: "Maps to \(uni) intro CS course"),
                CourseTransfer(name: "Calculus I", code: "MAC 2311", credits: 4, grade: "B+", transfers: true, costIfWasted: 0, reason: "Direct equivalent accepted"),
                CourseTransfer(name: "Data Structures", code: "COP 3530", credits: 3, grade: "A-", transfers: true, costIfWasted: 0, reason: "Accepted with syllabus review"),
                CourseTransfer(name: "Physics I", code: "PHY 2048", credits: 4, grade: "B", transfers: true, costIfWasted: 0, reason: "Lab credit included in transfer"),
            ])
        } else {
            transferable.append(contentsOf: [
                CourseTransfer(name: "Biology I", code: "BSC 1010", credits: 4, grade: "B", transfers: true, costIfWasted: 0, reason: "Satisfies lab science requirement"),
                CourseTransfer(name: "Public Speaking", code: "SPC 1608", credits: 3, grade: "A", transfers: true, costIfWasted: 0, reason: "Oral communication requirement met"),
            ])
        }

        let wasted: [CourseTransfer] = [
            CourseTransfer(name: "Art Appreciation", code: "ARH 1000", credits: 3, grade: "A", transfers: false, costIfWasted: 600, reason: "Fulfills humanities at CC, but \(uni) requires upper-level arts for this major"),
            CourseTransfer(name: "Music of the World", code: "MUH 2012", credits: 3, grade: "B+", transfers: false, costIfWasted: 600, reason: "No equivalent course exists at \(uni); elective credit only, doesn't count toward degree"),
            CourseTransfer(name: "Humanities Elective", code: "HUM 2230", credits: 3, grade: "B", transfers: false, costIfWasted: 600, reason: "\(uni) requires HUM 3000+ level; this lower-level course is not accepted"),
        ]

        return transferable + wasted
    }

    struct Solution: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let points: Int
        let icon: String
        let color: Color
        let monthlyImpact: Int
    }



    static func solutions(for uni: String, from cc: String, state: String) -> [Solution] {
        var items: [Solution] = []

        switch state {
        case "Florida":
            items.append(Solution(
                title: "Lock In DirectConnect",
                description: "Your \(cc) AA degree guarantees \(uni) admission — but only if you finish the AA first. Don't transfer with 55 credits thinking you'll finish later. Complete it, then transfer. That guarantee is worth more than any early start.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
            items.append(Solution(
                title: "File for Bright Futures Before July 1",
                description: "If you had Bright Futures in high school, it transfers with you — but you have to reactivate it through your \(uni) financial aid office. Miss the renewal window and you lose it permanently. Check your status at floridastudentfinancialaid.org right now.",
                points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 300
            ))
        case "California":
            items.append(Solution(
                title: "Submit TAG Application (Sept 1–30 only)",
                description: "TAG locks in your \(uni) admission — but the window is literally one month in September. Miss it by a day and you're in the regular pool with 80,000 other applicants. Set a calendar reminder for September 1st now.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
            items.append(Solution(
                title: "File Cal Grant by March 2",
                description: "Free money from the state — up to $14K/year at UCs. Requires FAFSA + GPA verification from \(cc). Your CC financial aid office sends the GPA automatically, but only if you tell them to. Walk in and ask. Takes 5 minutes.",
                points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 400
            ))
        case "Texas":
            items.append(Solution(
                title: "Complete the Texas Core (42 credits)",
                description: "The 42-credit Texas Core Curriculum transfers as a BLOCK to any public university. That means if you finish it at \(cc), \(uni) has to accept all 42 credits — no questions, no 'we don't offer that equivalent.' Finish the block.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
            items.append(Solution(
                title: "Apply for TEXAS Grant Right Now",
                description: "Need-based grant up to $10K/year. Most students don't know it exists because it's not advertised like financial aid. File FAFSA → mark \(uni) as your school → TEXAS Grant eligibility is automatic. No separate application.",
                points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 350
            ))
        case "Virginia":
            items.append(Solution(
                title: "Confirm Your GAA Status",
                description: "The Guaranteed Admission Agreement from \(cc) to \(uni) has GPA minimums that vary by major. Engineering at Virginia Tech needs a 3.4, not the 3.0 on the flyer. Log into the VA transfer portal and confirm YOUR major's actual cutoff.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
        case "Washington":
            items.append(Solution(
                title: "Finish Your DTA Degree",
                description: "The Direct Transfer Agreement degree from \(cc) guarantees junior standing at \(uni). Without it, they evaluate you course-by-course and you'll lose credits. The DTA is the single most important thing you can do before transferring.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
        case "North Carolina":
            items.append(Solution(
                title: "Use the CAA Transfer Path",
                description: "The Comprehensive Articulation Agreement maps every \(cc) course to a UNC system equivalent. Print your degree audit, cross-reference it against the CAA transfer list on cfnc.org, and make sure every remaining course is on there. One random elective can cost you a semester.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
        case "New Jersey":
            items.append(Solution(
                title: "Run Your NJ Transfer Evaluation",
                description: "Go to njtransfer.org and run a course-by-course evaluation from \(cc) to \(uni) right now. It shows exactly which credits transfer and which don't. Advisors at \(cc) sometimes use outdated equivalency charts — the website is the source of truth.",
                points: 8, icon: "link", color: .blue, monthlyImpact: 0
            ))
        default: break
        }

        items.append(contentsOf: [
            Solution(
                title: "Renew Your FAFSA (Deadline: June 30)",
                description: "Your FAFSA from \(cc) does NOT auto-transfer. You have to refile it and add \(uni)'s school code (search it on studentaid.gov). Do this the week you get accepted — don't wait for orientation. Late filers get less aid.",
                points: 10, icon: "doc.text.fill", color: .green, monthlyImpact: 250
            ),
            Solution(
                title: "Fight Your Wasted Credits",
                description: "Don't just accept the rejection. Email the \(uni) department chair for each rejected course, attach your syllabus plus the course description, and request a manual equivalency review. I've seen students recover 6–9 credits this way. Polite persistence works.",
                points: 5, icon: "arrow.uturn.backward", color: .red, monthlyImpact: 0
            ),
            Solution(
                title: "Lock Down a Roommate Now",
                description: "Don't wait until move-in week. Post in the \(uni) housing Facebook group and r/\(uni.replacingOccurrences(of: " ", with: "").lowercased()) subreddit now. A roommate doesn't just split rent — it splits utilities, internet, and renter's insurance. That's 30%+ off your monthly housing cost.",
                points: 6, icon: "person.2.fill", color: .purple, monthlyImpact: 0
            ),
            Solution(
                title: "Apply for the \(uni) Transfer Scholarship",
                description: "Most transfer students skip this because they think scholarships are only for freshmen. Wrong. \(uni) has transfer-specific awards — usually $1,000–$3,000/year. Check \(uni.lowercased().replacingOccurrences(of: " ", with: "")).edu/scholarships and filter by 'transfer.' Application takes 20 minutes.",
                points: 7, icon: "dollarsign.circle.fill", color: .orange, monthlyImpact: 150
            ),
            Solution(
                title: "Build a 3-Month Emergency Cushion",
                description: "Your runway is how long your savings last at your projected deficit. If you're negative $300/mo, you need at least $900 saved before day one. Open a separate high-yield savings account (Ally or Marcus) and automate $50/week into it starting today.",
                points: 3, icon: "banknote.fill", color: .cyan, monthlyImpact: 0
            ),
            Solution(
                title: "Get on Federal Work-Study First Week",
                description: "Campus jobs through Work-Study pay $12–15/hr and work around your class schedule. The catch: positions fill in the first week of the semester. Don't wait for the job fair. Go to \(uni)'s student employment portal the day your semester starts and apply to 5+ positions.",
                points: 4, icon: "briefcase.fill", color: .brown, monthlyImpact: 200
            ),
        ])

        return items
    }
}
