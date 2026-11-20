//
//  Client.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import Foundation

enum HTTPMethod {
    case get
    case post
    case put
    case delete
    
    var string: String {
        switch self {
        case .get:
            "GET"
        case .post:
            "POST"
        case .put:
            "PUT"
        case .delete:
            "DELETE"
        }
    }
}

enum HTTPError: Error {
    case invalidURL
    case badRequest
    case badResponse
}

class HTTPClient {
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func request<Response: Decodable>(
        method: HTTPMethod,
        endpoint: String,
        body: Data? = nil,
        queryParams: [String:String]? = nil,
        headers: [String:String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> Response {
        guard let url = URL(string: "\(self.baseURL)\(endpoint)") else {
            throw HTTPError.invalidURL
        }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw HTTPError.invalidURL
        }
        
        if let queryParams {
            let queryItems = queryParams.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let finalURL = urlComponents.url else {
            throw HTTPError.invalidURL
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = method.string
        
        if let body {
            urlRequest.httpBody = body
        }
        
        if let headers {
            headers.forEach { (key, value) in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let cachePolicy {
            urlRequest.cachePolicy = cachePolicy
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let response = response as? HTTPURLResponse else {
                print("Bad response...")
                throw HTTPError.badResponse
            }
            
            if response.statusCode != 200 {
                print("Bad code: \(response.statusCode)")
                throw HTTPError.badResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decoded = try decoder.decode(Response.self, from: data)
            
            return decoded
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Missing key: \(key.stringValue)")
            print("Coding path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
            print("Description: \(context.debugDescription)")
            throw HTTPError.badRequest
        } catch {
            print(error.localizedDescription)
            throw HTTPError.badRequest
        }
    }
}

extension HTTPClient {
    func get<Response: Decodable>(
        endpoint: String,
        queryParams: [String:String]? = nil,
        headers: [String:String]? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> Response {
        try await request(
            method: .get,
            endpoint: endpoint,
            queryParams: queryParams,
            headers: headers,
            cachePolicy: cachePolicy
        )
    }
}
