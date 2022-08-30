//
//  ServerCommunicationStore.swift
//  Movie list
//
//  Created by Mark Parfenov on 22/12/2021.
//

import Foundation

class ServerCommunication {
    public static let sharedInstance = ServerCommunication()
    
    private let BASE_URL = "https://www.omdbapi.com/"
    private let API_KEY = "fcf51026"
    private let defaultSearch = "batman"
    
    private let moviesDecoder = ResultDecoder<ResponceModel>({ (data) throws -> ResponceModel in
        try JSONDecoder().decode(ResponceModel.self, from: data)
    })
    
    private let searchDecoder = ResultDecoder<[Search]>({ (data) throws -> [Search] in
        try Array(JSONDecoder().decode([String: Search].self, from: data).values)
    })
    
    enum parameters {
        static let search = "s"
        static let title = "t"
        static let imdbID = "i"
    }
    
    enum methods {
        static let get = "GET"
    }
    
    private func requestBuilder(searchValue: String) -> URLRequest? {
//        let session = URLSession.shared
        var urlBuilder = URLComponents(string: BASE_URL)
        urlBuilder?.queryItems = [
        URLQueryItem(name: "apikey", value: API_KEY),
            URLQueryItem(name: parameters.search, value: searchValue)]
        
        guard let url = urlBuilder?.url else { return nil } //return error
        
        var request = URLRequest(url: url)
        request.httpMethod = methods.get
        return request
    }
    
    public func fetchMovies(onSuccess: @escaping(Result<ResponceModel, NetworkError>) -> Void) {
        // guard let request else { return Network error. can't build url
        if let request = requestBuilder(searchValue: defaultSearch) {
            call(request: request, completion: onSuccess) }
    }
    public func moviesSearchRequest(search: String, onSuccess: @escaping(Result<ResponceModel, NetworkError>) -> Void) {
        if let request = requestBuilder(searchValue: search) {
            call(request: request, completion: onSuccess) }
    }
    
    public func getMovieByID(imdbID: String, onSuccess: @escaping(MovieDetails) -> Void) {
        // rewrite to new request
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
                print("wrong mime type", responce?.mimeType as Any)
                return
            }
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(MovieDetails.self, from: data)
                    onSuccess(result)
                }catch let error {
                    //handle parsing error
                    print("search parsing error",error)
                }
            }
            }})
        task.resume()
        
    }
    private func handleClientError(_ error: Error) {
        print("cached error", error)
        //let component know of smth
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
    
    
    
    public func callDeprecated(path: String, method: String, parameter: String, value: String, onSuccess: @escaping(ResponceModel) -> Void) {
        let session = URLSession.shared
        var urlBuilder = URLComponents(string: path)
        urlBuilder?.queryItems = [
        URLQueryItem(name: "apikey", value: API_KEY),
        URLQueryItem(name: parameter, value: value)]
        
        guard let url = urlBuilder?.url else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
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
                    //handle parsing error
                    print(error)
                }
            }
            }})
        task.resume()
}
    
    func call(request: URLRequest, completion: @escaping(Result<ResponceModel, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { result in
            completion(self.moviesDecoder.decode(result))
        }.resume()
    }
    
    func callSearch(request: URLRequest, completion: @escaping(Result<[Search], NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { result in
            completion(self.searchDecoder.decode(result))
        }.resume()
    }
}

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}

extension NetworkError {
    init?(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            self = .transportError(error)
            return
        }
        
        if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
            self = .serverError(statusCode: response.statusCode)
            return
        }
        
        if data == nil {
            self = .noData
        }
        return nil
    }
}

typealias DataResult = Result<Data, NetworkError>

extension URLSession {
    func dataTask(with request: URLRequest, resultHandler:@escaping(DataResult) ->Void) -> URLSessionDataTask {
        
        return self.dataTask(with: request) { data, response, error in
            if let networkError = NetworkError(data: data, response: response, error: error) {
                resultHandler(.failure(networkError))
                return
            }
            resultHandler(.success(data!))
        }
    }
}


