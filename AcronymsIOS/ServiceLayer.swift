//
//  ServiceLayer.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/24/21.
//

import Foundation

class ServiceLayer {
    
    class func request<T: Codable>(router: Router, completion: @escaping (Result<T, RequestError>) -> Void) {
        
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.port = router.port
        components.path = router.path
        components.queryItems = router.queryParameters
        
        guard let url = components.url else { // http://localhost:8080/api/acronyms
            
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method.rawValue
        urlRequest.allHTTPHeaderFields = router.header
        urlRequest.httpBody = router.body
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(.unknownError(err: error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
        
            do {
            let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(.decodingError))
            }            
        }
        
        dataTask.resume()
    }
    
    class func requestToDelete(router: Router, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.port = router.port
        components.path = router.path
        components.queryItems = router.queryParameters
        
        guard let url = components.url else { // http://localhost:8080/api/acronyms
            
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method.rawValue
        urlRequest.allHTTPHeaderFields = router.header
        urlRequest.httpBody = router.body
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let responseCode = (response as? HTTPURLResponse)?.statusCode, (200...300).contains(responseCode) else {
                return
            }
            
            completion(nil)

        }
        
        dataTask.resume()
    }
}

enum RequestError: Error {
    case decodingError
    case noData
    case unknownError(err: Error)
}
