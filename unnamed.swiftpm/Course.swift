import SwiftData

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
