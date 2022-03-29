//
//  ViewController.swift
//  Movie list
//
//  Created by Mark Parfenov on 22/12/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sort: UISegmentedControl!
    @IBOutlet weak var errorLabel: UILabel!
    
    var movieList = [Search]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        Worker.sharedInstanse.getMovieList(onSuccess)
    }
    
    func onSuccess(result: Result<ResponceModel, NetworkError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                self.errorLabel.isHidden = true
                self.movieList = data.search
                self.tableView.reloadData()
            case .failure(let error):
                self.errorLabel.isHidden = false
                print("onSuccess error", error)
                self.errorLabel.text = Worker.sharedInstanse.specifyError(error)
                self.movieList = [Search]()
                self.tableView.reloadData()
            }
        }
    }
    
    func onSearchSuccess(result: Result<[Search], NetworkError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                self.movieList = data
                self.tableView.reloadData()
            case .failure(let error):
                print("onSuccess error", error)
            }
        }
    }
    
    func onImageSuccess(data: (Data?, String?)) -> Void {
        if let imageData = data.0, let description = data.1 {
        DispatchQueue.main.async() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "movieDetails") as? DetailsViewController
            vc?.imageData = imageData
            vc?.movieDetails = description
        self.present(vc!, animated: true, completion: nil)
        }
        }
    }
    
    @IBAction func toSortBy(_ sender: UISegmentedControl) {
        switch sort.selectedSegmentIndex {
        case 0:
            movieList = movieList.sorted(by: {$0.Title < $1.Title} )
            tableView.reloadData()
        case 1:
            movieList = movieList.sorted(by: {$0.Year < $1.Year} )
            tableView.reloadData()
        default: break
        }
    }
    
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieTableViewCell
        if movieList.count > 0 {
            cell.movieTitle.text = movieList[indexPath.row].Title + " " + movieList[indexPath.row].Year
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select at",indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        let imdbID = movieList[indexPath.row].imdbID
        let path = movieList[indexPath.row].Poster
        Worker.sharedInstanse.getMovieDetails(imdbID: imdbID, path: path, onImageSuccess)
//        Worker.sharedInstanse.getImage(path: path, onImageSuccess)
        
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard searchBar.text != nil else {
            return
        }
        let searchText = searchBar.text!
        Worker.sharedInstanse.searchMovie(searchText: searchText, onFullSuccess: onSuccess)
        print(searchText)
        //hide keyboard
        self.view.endEditing(true)
    }
    
}

