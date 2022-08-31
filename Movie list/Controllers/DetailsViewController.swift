
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
