//
//  Model.swift
//  Movie list
//
//  Created by Mark Parfenov on 26/12/2021.
//

import Foundation

struct ResponceModel: Codable {
    let search: [Search]
    let results: String
    
    
    enum CodingKeys: String, CodingKey {
            case search = "Search"
            case results = "totalResults"
    }
}

struct Search: Codable {
    let Title, Year, Poster, imdbID : String
}

struct MovieDetails: Codable {
    let plot: String
    
    enum CodingKeys: String, CodingKey  {
        case plot = "Plot"
    }
}

struct ResultDecoder<T> {
    
    private let transform: (Data) throws -> T
    
    init (_ transform: @escaping (Data) throws -> T) {
        self.transform = transform
    }
    
    func decode(_ result: DataResult) -> Result<T, NetworkError> {
      result.flatMap { (data) -> Result<T, NetworkError> in
            Result { try transform(data) }.mapError { NetworkError.decodingError($0) }
        }
        
    }
}
