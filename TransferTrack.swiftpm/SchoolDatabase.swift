import SwiftUI

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

    // MARK: logo asset names

    static let logoMap: [String: String] = [
        // Florida CCs
        "Valencia College":     "valencia-college",
        "Miami Dade College":   "miami-dade-college",
        "Seminole State":       "seminole-state",
        "Polk State":           "polk-state",
        "Santa Fe College":     "santa-fe-college",
        // Florida Unis
        "UCF":                  "ucf",
        "Univ. of Florida":     "univ-of-florida",
        "FSU":                  "fsu",
        "USF":                  "usf",
        "FIU":                  "fiu",
        // California CCs
        "Santa Monica College":     "santa-monica-college",
        "De Anza College":          "de-anza-college",
        "Pasadena City College":    "pasadena-city-college",
        "Diablo Valley College":    "diablo-valley-college",
        "Orange Coast College":     "orange-coast-college",
        // California Unis
        "UCLA":             "ucla",
        "UC Berkeley":      "uc-berkeley",
        "UC Davis":         "uc-davis",
        "CSU LA":           "csu-la",
        "San Jose State":   "san-jose-state",
        // Texas CCs
        "Austin CC":        "austin-cc",
        "Houston CC":       "houston-cc",
        "Lone Star College":"lone-star-college",
        "Dallas College":   "dallas-college",
        "Alamo Colleges":   "alamo-colleges",
        // Texas Unis
        "UT Austin":        "ut-austin",
        "Texas A&M":        "texas-am",
        "Univ. of Houston": "univ-of-houston",
        "UTSA":             "utsa",
        "Texas State":      "texas-state",
        // Virginia CCs
        "NOVA":                 "nova",
        "Tidewater CC":         "tidewater-cc",
        "Virginia Western CC":  "virginia-western-cc",
        "Reynolds CC":          "reynolds-cc",
        // Virginia Unis
        "UVA":              "uva",
        "Virginia Tech":    "virginia-tech",
        "JMU":              "jmu",
        "George Mason":     "george-mason",
        "VCU":              "vcu",
        // Washington CCs
        "Seattle Central":      "seattle-central",
        "Bellevue College":     "bellevue-college",
        "Spokane CC":           "spokane-cc",
        "Green River College":  "green-river-college",
        // Washington Unis
        "Univ. of Washington":  "univ-of-washington",
        "WSU":                  "wsu",
        "Central Washington":   "central-washington",
        "Eastern Washington":   "eastern-washington",
        // North Carolina CCs
        "Central Piedmont CC":  "central-piedmont-cc",
        "Wake Tech":            "wake-tech",
        "Guilford Tech":        "guilford-tech",
        "Cape Fear CC":         "cape-fear-cc",
        // North Carolina Unis
        "UNC Chapel Hill":  "unc-chapel-hill",
        "NC State":         "nc-state",
        "App State":        "app-state",
        "ECU":              "ecu",
        "UNC Charlotte":    "unc-charlotte",
        // New Jersey CCs
        "Bergen CC":            "bergen-cc",
        "Middlesex College":    "middlesex-college",
        "Camden County College":"camden-county-college",
        "Union College":        "union-college",
        // New Jersey Unis
        "Rutgers":          "rutgers",
        "Rowan Univ.":      "rowan-univ",
        "Montclair State":  "montclair-state",
        "NJIT":             "njit",
        "Stockton Univ.":   "stockton-univ",
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
