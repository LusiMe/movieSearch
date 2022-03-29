//
//  Worker.swift
//  Movie list
//
//  Created by Mark Parfenov on 27/12/2021.
//

import Foundation

class Worker {
    public static let sharedInstanse = Worker()
    
    public func getMovieList(_ onFullSuccess: @escaping(Result<ResponceModel, NetworkError>) -> Void) {
        ServerCommunication.sharedInstance.fetchMovies(onSuccess: onFullSuccess)
    }
    
    public func searchMovie(searchText: String, onFullSuccess: @escaping(Result<ResponceModel, NetworkError>) -> Void) {
        ServerCommunication.sharedInstance.moviesSearchRequest(search: searchText, onSuccess:onFullSuccess)
    }
    
    public func getImage(path: String, _ onFullSuccess: @escaping(Data) -> Void) {
        guard let url = URL(string: path) else {return}
        ServerCommunication.sharedInstance.downloadImage(from: url, onSuccess: onFullSuccess)
    }
    
  
//    private func onSuccess(_ onFullSuccess: @escaping (Result<[Search], NetworkError>) -> Void) -> Void {
        
//        func getData(data: (Result<[Search], NetworkError>)) -> Void {
//            onFullSuccess(getTitles(result: data))
//            onFullSuccess(data)
//        }
        
//        return getData
//    }
    
//    public func onSearchSuccess(_ onFullSuccess: @escaping([Search]) -> Void) -> (Result<ResponceModel, NetworkError>) -> Void {
//        func getData(data: Result<[Search], NetworkError>) -> Void {
//            onFullSuccess(getTitles(result: data))
//        }
//        return getData
//    }
    
//    private func getTitles(result: (Result<[Search], NetworkError>)) -> [Search] {
//        switch result {
//        case .success(let data) :
//            return data
//        case .failure(let error):
//
//            print("get titles error", error)
//            return error
//        }
//
//    }

    public func getMovieDetails(imdbID: String, path: String, _ onFullSuccess: @escaping((Data?, String?)) -> Void) {
        
        guard let url = URL(string: path) else {return}
        var data: (Data?, String?) = (image: nil, description: nil)
        
        func getImage(image: Data) -> Void {
            data.0 = image
            if ((data.1) != nil) {
                onFullSuccess((data.0, data.1))
            }
        }
        //TODO: rename variables and functions to represent functionality
        func getDesc(desc: MovieDetails) -> Void {
            let description = getDetails(desc)
            data.1 = description
            if ((data.0) != nil) {
                onFullSuccess((data.0, data.1))
            }
        }
        
            ServerCommunication.sharedInstance.getMovieByID(imdbID: imdbID, onSuccess: getDesc)
            
            ServerCommunication.sharedInstance.downloadImage(from: url, onSuccess: getImage)
    }
    
    private func getDetails(_ data: MovieDetails ) -> String {
        data.plot
    }
    
    public func specifyError(_ error: NetworkError) -> String {
        switch error {
        case .transportError(let error):
            return error.localizedDescription
        case .serverError(_):
            return "\(error)"
        case .decodingError(let error):
            return" Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error)"
        default:
            return error.localizedDescription
        }
    }
}
