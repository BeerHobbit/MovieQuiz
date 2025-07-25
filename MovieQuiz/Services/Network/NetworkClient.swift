import Foundation

struct NetworkClient {
    
    //MARK: - Errors
    
    private enum NetworkError: Error {
        case codeError
    }
    
    //MARK: - Public Methods
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))
                print(error)
                return
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                print(NetworkError.codeError)
                return
            }
            guard let data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
    
}
