//
//  Model.swift
//  Movie list
//
//  Created by Mark Parfenov on 26/12/2021.
//

import Foundation

//struct ResponceModel: Codable {
//    let Title: String
//    let Released: String
//    let Plot: String
//}

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


//let decoder = JSONDecoder()
//let wrapper = try decoder.decode(ResponceModel.self, from: data )
