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
        case "UCLA":
            return [
                Apartment(name: "Westwood Palms", distance: "0.8 mi", beds: 2, baths: 2, rent: 2800, odds: "Low Odds", oddsDetail: "Guarantor Required"),
                Apartment(name: "Kelton Towers", distance: "0.5 mi", beds: 1, baths: 1, rent: 2200, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Weyburn Terrace", distance: "0.3 mi", beds: 2, baths: 1, rent: 2400, odds: "Medium Odds", oddsDetail: "UCLA Housing"),
                Apartment(name: "Gayley Heights", distance: "0.4 mi", beds: 1, baths: 1, rent: 1900, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Levering Terrace", distance: "0.2 mi", beds: 2, baths: 2, rent: 2600, odds: "Medium Odds", oddsDetail: "UCLA Housing"),
            ]
        case "UT Austin":
            return [
                Apartment(name: "West Campus Lofts", distance: "0.4 mi", beds: 2, baths: 2, rent: 1500, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "The Callaway", distance: "0.6 mi", beds: 1, baths: 1, rent: 1200, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "Riverside Terrace", distance: "1.5 mi", beds: 2, baths: 1, rent: 1050, odds: "High Odds", oddsDetail: "No Credit Check"),
                Apartment(name: "26 West", distance: "0.3 mi", beds: 4, baths: 4, rent: 950, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "Dobie Center", distance: "0.1 mi", beds: 1, baths: 1, rent: 1350, odds: "High Odds", oddsDetail: "Student Housing"),
            ]
        case "Rutgers":
            return [
                Apartment(name: "The Yard", distance: "0.3 mi", beds: 2, baths: 2, rent: 1400, odds: "High Odds", oddsDetail: "Student-Friendly"),
                Apartment(name: "College Ave Apartments", distance: "0.5 mi", beds: 1, baths: 1, rent: 1100, odds: "Medium Odds", oddsDetail: "Co-signer Recommended"),
                Apartment(name: "Easton Avenue", distance: "0.8 mi", beds: 3, baths: 2, rent: 900, odds: "High Odds", oddsDetail: "Per-bed Lease"),
                Apartment(name: "George Street Lofts", distance: "1.0 mi", beds: 2, baths: 1, rent: 1250, odds: "High Odds", oddsDetail: "No Credit Check"),
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

        let state = stateForSchool(uni)

        var transferable: [CourseTransfer] = [
            CourseTransfer(name: "English Composition I", code: "ENC 1101", credits: 3, grade: "A-", transfers: true, costIfWasted: 0, reason: "Satisfies general education writing requirement"),
            CourseTransfer(name: "College Algebra", code: "MAC 1105", credits: 3, grade: "B+", transfers: true, costIfWasted: 0, reason: "Core math requirement fulfilled"),
            CourseTransfer(name: "General Psychology", code: "PSY 2012", credits: 3, grade: "B", transfers: true, costIfWasted: 0, reason: "Counts toward social science elective"),
            CourseTransfer(name: "Statistics", code: "STA 2023", credits: 3, grade: "A", transfers: true, costIfWasted: 0, reason: "Required for most STEM and business majors"),
            CourseTransfer(name: "Microeconomics", code: "ECO 2023", credits: 3, grade: "B+", transfers: true, costIfWasted: 0, reason: "Accepted as equivalent to \(uni) ECO requirement"),
        ]


        let stemUnis = ["UCF", "UT Austin", "UCLA", "UC Berkeley", "Virginia Tech", "NC State", "NJIT", "Rutgers",
                        "Texas A&M", "Univ. of Washington", "Georgia Tech", "San Jose State", "George Mason"]
        if stemUnis.contains(uni) {
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


        let costPerCredit: Int
        switch state {
        case "Florida": costPerCredit = 200
        case "California": costPerCredit = 250
        case "Texas": costPerCredit = 180
        case "Virginia": costPerCredit = 300
        case "New Jersey": costPerCredit = 280
        default: costPerCredit = 200
        }

        var wasted: [CourseTransfer] = []

        switch state {
        case "Florida":
            wasted = [
                CourseTransfer(name: "Art Appreciation", code: "ARH 1000", credits: 3, grade: "A", transfers: false, costIfWasted: costPerCredit * 3, reason: "Fulfills humanities at your community college, but \(uni) requires upper-level arts for this major"),
                CourseTransfer(name: "Music of the World", code: "MUH 2012", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "No equivalent course exists at \(uni); elective credit only, doesn't count toward degree"),
                CourseTransfer(name: "Humanities Elective", code: "HUM 2230", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires HUM 3000+ level; this lower-level course is not accepted"),
            ]
        case "California":
            wasted = [
                CourseTransfer(name: "Ethnic Studies Survey", code: "ES 001", credits: 3, grade: "A", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires their own Ethnic Studies series; CC equivalent not on ASSIST.org transfer list"),
                CourseTransfer(name: "Intro to Film", code: "CINE 001", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "Not on the IGETC-approved list for \(uni); counts as general elective only"),
                CourseTransfer(name: "Health Education", code: "HLTH 001", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) does not accept Health Ed from community colleges toward any degree requirement"),
            ]
        case "Texas":
            wasted = [
                CourseTransfer(name: "Kinesiology Activity", code: "KINE 1100", credits: 1, grade: "A", transfers: false, costIfWasted: costPerCredit * 1, reason: "Activity courses do not count toward the Texas Core Curriculum block for \(uni)"),
                CourseTransfer(name: "Creative Arts Survey", code: "ARTS 1301", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires a specific fine arts course not matched by this survey class"),
                CourseTransfer(name: "Speech Communication", code: "SPCH 1321", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires COMM 1310 specifically; SPCH 1321 is not accepted as equivalent"),
            ]
        case "Virginia":
            wasted = [
                CourseTransfer(name: "Art Survey", code: "ART 101", credits: 3, grade: "A", transfers: false, costIfWasted: costPerCredit * 3, reason: "Not on the GAA approved transfer list for \(uni); counts as free elective only"),
                CourseTransfer(name: "Music Appreciation", code: "MUS 121", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires a performance-based music credit; appreciation courses don't qualify"),
                CourseTransfer(name: "Personal Finance", code: "BUS 100", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "Business elective at CC level is not equivalent to any \(uni) School of Business requirement"),
            ]
        case "Washington":
            wasted = [
                CourseTransfer(name: "PE Activity Course", code: "PE 100", credits: 2, grade: "A", transfers: false, costIfWasted: costPerCredit * 2, reason: "Activity credits don't count toward DTA requirements for \(uni)"),
                CourseTransfer(name: "Career Exploration", code: "HDCE 101", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "Professional/technical course; not transferable under the DTA agreement to \(uni)"),
                CourseTransfer(name: "Intro to Library Research", code: "LIB 101", credits: 2, grade: "B", transfers: false, costIfWasted: costPerCredit * 2, reason: "\(uni) does not accept library science as a transferable academic credit"),
            ]
        case "North Carolina":
            wasted = [
                CourseTransfer(name: "Wellness Concepts", code: "HEA 110", credits: 1, grade: "A", transfers: false, costIfWasted: costPerCredit * 1, reason: "Not on the CAA transfer list; \(uni) does not accept wellness courses from CC"),
                CourseTransfer(name: "Academic Transition", code: "ACA 122", credits: 1, grade: "A", transfers: false, costIfWasted: costPerCredit * 1, reason: "Orientation/transition courses are CC-specific and not transferable to \(uni)"),
                CourseTransfer(name: "Art Appreciation", code: "ART 111", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) accepts ART 114 (Art History) but not ART 111 (Appreciation); different course content"),
            ]
        case "New Jersey":
            wasted = [
                CourseTransfer(name: "Fitness & Wellness", code: "HPE 101", credits: 2, grade: "A", transfers: false, costIfWasted: costPerCredit * 2, reason: "Physical education credits don't transfer to \(uni) degree requirements per njtransfer.org"),
                CourseTransfer(name: "Intro to Cinema", code: "COM 105", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "Not listed as equivalent on njtransfer.org for \(uni); elective credit only"),
                CourseTransfer(name: "Music Fundamentals", code: "MUS 100", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires MUS 100-level theory, not fundamentals; no equivalency match"),
            ]
        default:
            wasted = [
                CourseTransfer(name: "Art Appreciation", code: "ART 100", credits: 3, grade: "A", transfers: false, costIfWasted: costPerCredit * 3, reason: "Fulfills humanities at your community college, but \(uni) requires upper-level arts"),
                CourseTransfer(name: "Music Survey", code: "MUS 100", credits: 3, grade: "B+", transfers: false, costIfWasted: costPerCredit * 3, reason: "No equivalent course exists at \(uni); elective credit only"),
                CourseTransfer(name: "Humanities Elective", code: "HUM 200", credits: 3, grade: "B", transfers: false, costIfWasted: costPerCredit * 3, reason: "\(uni) requires higher-level humanities; this course is not accepted"),
            ]
        }

        return transferable + wasted
    }

    private static func stateForSchool(_ school: String) -> String {
        for (state, data) in stateData {
            if data.ccs.contains(school) || data.unis.contains(school) { return state }
        }
        return "Florida"
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
            items.append(Solution(title: "Lock In DirectConnect", description: "Your \(cc) AA degree guarantees \(uni) admission — but only if you finish the AA first. Don't transfer with 55 credits thinking you'll finish later. Complete it, then transfer.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
            items.append(Solution(title: "File for Bright Futures Before July 1", description: "If you had Bright Futures in high school, it transfers with you — but you have to reactivate it through your \(uni) financial aid office. Miss the renewal window and you lose it permanently.", points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 300))
        case "California":
            items.append(Solution(title: "Submit TAG Application (Sept 1–30)", description: "TAG locks in your \(uni) admission — but the window is literally one month in September. Miss it by a day and you're in the regular pool with 80,000 other applicants.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
            items.append(Solution(title: "File Cal Grant by March 2", description: "Free money from the state — up to $14K/year at UCs. Requires FAFSA + GPA verification from \(cc). Your CC financial aid office sends the GPA automatically, but only if you tell them to.", points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 400))
        case "Texas":
            items.append(Solution(title: "Complete the Texas Core (42 credits)", description: "The 42-credit Texas Core Curriculum transfers as a BLOCK to any public university. If you finish it at \(cc), \(uni) has to accept all 42 credits — no questions asked.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
            items.append(Solution(title: "Apply for TEXAS Grant", description: "Need-based grant up to $10K/year. File FAFSA → mark \(uni) as your school → TEXAS Grant eligibility is automatic. No separate application required.", points: 7, icon: "star.fill", color: .yellow, monthlyImpact: 350))
        case "Virginia":
            items.append(Solution(title: "Confirm Your GAA Status", description: "The Guaranteed Admission Agreement from \(cc) to \(uni) has GPA minimums that vary by major. Engineering at Virginia Tech needs a 3.4, not the 3.0 on the flyer. Confirm YOUR major's actual cutoff.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
        case "Washington":
            items.append(Solution(title: "Finish Your DTA Degree", description: "The Direct Transfer Agreement degree from \(cc) guarantees junior standing at \(uni). Without it, they evaluate you course-by-course and you'll lose credits.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
        case "North Carolina":
            items.append(Solution(title: "Use the CAA Transfer Path", description: "The Comprehensive Articulation Agreement maps every \(cc) course to a UNC system equivalent. Cross-reference your degree audit against the CAA transfer list on cfnc.org.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
        case "New Jersey":
            items.append(Solution(title: "Run Your NJ Transfer Evaluation", description: "Go to njtransfer.org and run a course-by-course evaluation from \(cc) to \(uni) right now. It shows exactly which credits transfer and which don't. The website is the source of truth.", points: 8, icon: "link", color: .blue, monthlyImpact: 0))
        default: break
        }

        items.append(contentsOf: [
            Solution(title: "Renew Your FAFSA (Deadline: June 30)", description: "Your FAFSA from \(cc) does NOT auto-transfer. Refile it and add \(uni)'s school code on studentaid.gov. Do this the week you get accepted — late filers get less aid.", points: 10, icon: "doc.text.fill", color: .green, monthlyImpact: 250),
            Solution(title: "Fight Your Wasted Credits", description: "Email the \(uni) department chair for each rejected course, attach your syllabus plus the course description, and request a manual equivalency review. Polite persistence works.", points: 5, icon: "arrow.uturn.backward", color: .red, monthlyImpact: 0),
            Solution(title: "Lock Down a Roommate Now", description: "Post in the \(uni) housing Facebook group and subreddit now. A roommate splits rent, utilities, internet, and renter's insurance — that's 30%+ off your monthly housing cost.", points: 6, icon: "person.2.fill", color: .purple, monthlyImpact: 0),
            Solution(title: "Apply for the \(uni) Transfer Scholarship", description: "Most transfer students skip this thinking scholarships are only for freshmen. Wrong. \(uni) has transfer-specific awards — usually $1,000–$3,000/year. Application takes 20 minutes.", points: 7, icon: "dollarsign.circle.fill", color: .orange, monthlyImpact: 150),
            Solution(title: "Build a 3-Month Emergency Cushion", description: "Your runway is how long your savings last at your projected deficit. Open a separate high-yield savings account and automate $50/week into it starting today.", points: 3, icon: "banknote.fill", color: .cyan, monthlyImpact: 0),
            Solution(title: "Get on Federal Work-Study First Week", description: "Campus jobs through Work-Study pay $12–15/hr and work around your class schedule. Positions fill in the first week — go to \(uni)'s student employment portal day one.", points: 4, icon: "briefcase.fill", color: .brown, monthlyImpact: 200),
        ])

        return items
    }
}
