import Foundation

class ErrorNetworkService: NetworkServiceProtocol {
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated network error"])
        completion(.failure(error))
    }
}
