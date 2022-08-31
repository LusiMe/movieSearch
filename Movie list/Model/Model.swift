
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
