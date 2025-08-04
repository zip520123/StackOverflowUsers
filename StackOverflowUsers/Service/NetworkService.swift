import Foundation

protocol NetworkServiceProtocol {
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    private let urlString = "https://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchTopUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let usersResponse = try JSONDecoder().decode(UsersResponse.self, from: data)
                completion(.success(usersResponse.items))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
