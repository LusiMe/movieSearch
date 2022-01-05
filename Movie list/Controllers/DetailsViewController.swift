//
//  DetailsTableViewController.swift
//  Movie list
//
//  Created by Mark Parfenov on 28/12/2021.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var movieDetails = String()
    var imageData = Data()
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsLabel?.text = movieDetails
        imageView?.image = UIImage(data: imageData)
    }


}
