import Foundation

struct Response {
    let data: Data
    var statusCode: Int = 500

    init(data: Data, urlResponse: URLResponse) {
        self.data = data
        if let httpResponse = urlResponse as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
        }
    }
}
