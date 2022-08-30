

import Foundation

class ServerCommunication {
    public static let sharedInstance = ServerCommunication()
    
    private let BASE_URL = "https://www.omdbapi.com/"
    private let API_KEY = "fcf51026"
    
    public func fetchMovies(onSuccess: @escaping(ResponceModel) -> Void) {
        let session = URLSession.shared
        var urlBuilder = URLComponents(string: BASE_URL)
        urlBuilder?.queryItems = [
        URLQueryItem(name: "apikey", value: API_KEY),
        URLQueryItem(name: "s", value: "batman")]
        
        guard let url = urlBuilder?.url else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {data, responce, error in
            DispatchQueue.main.async {
            if error != nil {
                self.handleClientError(error!)
                return
            }
            guard let httpResponse = responce as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(responce!)
                return
            }
                guard let mime = responce?.mimeType, mime == "application/json" else {
                print("wrong mime type", responce?.mimeType)
                return
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ResponceModel.self, from: data)
                    print("result",result)
                    onSuccess(result)
                    
                }catch let error {
                    print(error)
                }
            }
            }})
        task.resume()
        
    }
    public func moviesSearchRequest(search: String, onSuccess: @escaping(ResponceModel) -> Void) {
        let session = URLSession.shared
        var urlBuilder = URLComponents(string: BASE_URL)
        urlBuilder?.queryItems = [
        URLQueryItem(name: "apikey", value: API_KEY),
        URLQueryItem(name: "s", value: search)]
        
        guard let url = urlBuilder?.url else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {data, responce, error in
            DispatchQueue.main.async {
            if error != nil {
                self.handleClientError(error!)
                return
            }
            guard let httpResponse = responce as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(responce!)
                return
            }
            guard let mime = responce?.mimeType, mime == "application/json" else {
                print("wrong mime type", responce?.mimeType)
                return
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ResponceModel.self, from: data)
                    onSuccess(result)
                }catch let error {
                    print("search parsing error",error)
                }
            }
            }})
        task.resume()
        
    }
    
    public func getMovieByID(imdbID: String, onSuccess: @escaping(MovieDetails) -> Void) {
        print("imdbID", imdbID)
        let session = URLSession.shared
        var urlBuilder = URLComponents(string: BASE_URL)
        urlBuilder?.queryItems = [
        URLQueryItem(name: "apikey", value: API_KEY),
        URLQueryItem(name: "i", value: imdbID),
        URLQueryItem(name: "plot", value: "full")]
        
        guard let url = urlBuilder?.url else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: {data, responce, error in
            DispatchQueue.main.async {
            if error != nil {
                self.handleClientError(error!)
                return
            }
            guard let httpResponse = responce as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(responce!)
                return
            }
            guard let mime = responce?.mimeType, mime == "application/json" else {
                print("wrong mime type", responce?.mimeType)
                return
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieDetails.self, from: data)
                    onSuccess(result)
                }catch let error {
                    print("search parsing error",error)
                }
            }
            }})
        task.resume()
        
    }
    private func handleClientError(_ error: Error) {
        print("cached error", error)
    }
    
    private func handleServerError(_ response: URLResponse) {
        print("server error", response)
    }
    
    func downloadImage(from url: URL, onSuccess: @escaping(Data) -> Void) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished", data)
            onSuccess(data)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
 
