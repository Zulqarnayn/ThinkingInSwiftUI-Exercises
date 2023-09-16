//
//  Remote.swift
//  Exercise.1
//
//  Created by Asif Mujtaba on 11/9/23.
//

import Foundation
import Combine

struct Photo: Codable, Identifiable {
    var id: String
    var author: String
    var width, height: CGFloat
    var url, download_url: URL
}

enum APIError: Error {
    case unknown
    case apiError(reason: String)
    case parseError(reason: String)
    
    var errorDescription: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(reason: let reason), .parseError(reason: let reason):
            return reason
        }
    }
}

class Remote<A>: ObservableObject {
    @Published var result: Result<A, Error>? = nil
    var token: Cancellable?
    
    var value: A? { try? result?.get() }
    
    let url: URL
    var transform: (Data) -> A?
    
    init(url: URL, transform: @escaping (Data) -> A?) {
        self.url = url
        self.transform = transform
    }
    
    func load() {
        token = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                      (200..<300) ~= response.statusCode else {
                    throw APIError.unknown
                }
                
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.result = .failure(error)
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { (data: Data) in
                if let result = self.transform(data) {
                    self.result = .success(result)
                }
            }

    }
}
