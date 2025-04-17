//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 19.03.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    LogService.error(type: "Ошибка HTTP status code", statusCode.description)
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                LogService.error(type: "Ошибка URLRequest", error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                LogService.error("Ошибка URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            switch result {
            case .success(let data):
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                }
                catch {
                    LogService.error(type: "Ошибка декодирования", error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                LogService.error("Ошибка \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
