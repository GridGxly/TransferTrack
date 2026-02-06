import Foundation

class NetworkManager {
    func fetchData(from url: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                completion(nil, NSError(domain: "HTTP Error", code: 500, userInfo: nil))
                return
            }

            completion(data, nil)
        }
        task.resume()
    }
}
