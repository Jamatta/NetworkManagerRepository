import Foundation

public enum APIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case invalidData
    case decodingError
}

public struct NetworkManager {
    public static func requestData<T: Decodable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(.requestFailed))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(.decodingError))
            }
        }

        task.resume()
    }
}
