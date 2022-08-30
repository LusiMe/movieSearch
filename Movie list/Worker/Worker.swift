

import Foundation

class Worker {
    public static let sharedInstanse = Worker()
    
    public func getMovieList(_ onFullSuccess: @escaping([Search]) -> Void) {
        ServerCommunication.sharedInstance.fetchMovies(onSuccess: onSuccess(onFullSuccess))
    }
    
    public func searchMovie(searchText: String, onFullSuccess: @escaping([Search]) -> Void) {
        ServerCommunication.sharedInstance.moviesSearchRequest(search: searchText, onSuccess: onSearchSuccess(onFullSuccess))
    }
    
    public func getImage(path: String, _ onFullSuccess: @escaping(Data) -> Void) {
        guard let url = URL(string: path) else {return}
        ServerCommunication.sharedInstance.downloadImage(from: url, onSuccess: onFullSuccess)
    }
    
  
    private func onSuccess(_ onFullSuccess: @escaping([Search]) -> Void) -> (ResponceModel) -> Void {
        func getData(data: ResponceModel) -> Void {
            onFullSuccess(getTitles(data))
        }
        return getData
    }
    
    public func onSearchSuccess(_ onFullSuccess: @escaping([Search]) -> Void) -> (ResponceModel) -> Void {
        func getData(data: ResponceModel) -> Void {
            onFullSuccess(getTitles(data))
        }
        return getData
    }
    
    private func getTitles(_ data: ResponceModel ) -> [Search] {
        data.search
    }

    public func getMovieDetails(imdbID: String, path: String, _ onFullSuccess: @escaping((Data?, String?)) -> Void) {
        
        guard let url = URL(string: path) else {return}
        var data: (Data?, String?) = (image: nil, description: nil)
        
        func getImage(image: Data) -> Void {
            data.0 = image
            if ((data.1) != nil) {
                onFullSuccess((data.0, data.1))
            }
        }
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
}
