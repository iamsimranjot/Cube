//
//  MovieDetailsViewController.swift
//  Cube
//
//  Created by SimranJot Singh on 17/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    
    var movieTitle: String?
    var currentMovie: MoviesModel!
    let sessionObject = NetworkManager.sharedInstance()
    let dataSource = DataSource.sharedInstance()
    
    //MARK: LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Initial UI
        idleView.isHidden = true
        loadingView.isHidden = false
        view.backgroundColor = UIColor(hex: 0x65c3ba)
        idleView.backgroundColor = UIColor(hex: 0x65c3ba)
        loadingView.backgroundColor = UIColor(hex: 0x35a79c)
        activityIndicator.startAnimating()
        
        // Check if the movie exits in Data Source so that it doesn't have to fetch again. (Gives better user experience)
        for movie in dataSource.movieDetailsDic {
            if movie.movieDetails.title == movieTitle {
                currentMovie = movie
                break
            }
        }
        
        // If not Fetch Details
        if currentMovie == nil {
            sessionObject.getMovieDetailsForTitle(movieTitle!) { (movieDetail , _) in
                self.currentMovie = movieDetail
                self.dataSource.movieDetailsDic.append(movieDetail!) // Saves it to the data source
                DispatchQueue.main.async {
                    // Configure UI With Data
                    self.configureUI(details: self.currentMovie)
                }
            }
        }
    }
    
    //MARK: Helper Methods
    
    private func configureUI(details: MoviesModel) {
        
        let url = URL(string: details.movieDetails.posterUrl)
        posterImageView.download(from: url!, placeholder: #imageLiteral(resourceName: "defaultPoster")) { (image , error) in
            if error == nil {
                self.posterImageView.image = image
            }
        }
        
        titleLabel.text = "\(details.movieDetails.title)\n(\(details.movieDetails.genre))"
        releaseDateLabel.text = "Release Date: \(details.movieDetails.releaseDate)"
        ratingsLabel.text = "Rating: \(details.movieDetails.ratings)"
        plotLabel.text = details.movieDetails.plot
        
        idleView.isHidden = false
        loadingView.isHidden = true
        
        // Spring Animation
        
        let height: CGFloat = view.bounds.size.height
        posterImageView.transform = CGAffineTransform(translationX: 0, y: height)
        titleLabel.transform = CGAffineTransform(translationX: 0, y: height)
        releaseDateLabel.transform = CGAffineTransform(translationX: 0, y: height)
        ratingsLabel.transform = CGAffineTransform(translationX: 0, y: height)
        plotLabel.transform = CGAffineTransform(translationX: 0, y: height)
        
        
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
            self.posterImageView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.releaseDateLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.ratingsLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.plotLabel.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: UIImageView Extension

extension UIImageView {
    
    // Downloads & loads the image in imageView Asynchronously else fills it with the placeholder image.
    public func download(from url: URL,
                         contentMode: UIViewContentMode = .scaleAspectFit,
                         placeholder: UIImage? = nil,
                         completionHandler: ((UIImage?, Error?) -> Void)? = nil) {
        
        image = placeholder
        self.contentMode = contentMode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completionHandler?(nil, error)
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                completionHandler?(image, nil)
            }
            }.resume()
    }
}
