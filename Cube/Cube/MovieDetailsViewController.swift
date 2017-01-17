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
    
    //MARK: Properties
    
    var movieID = String()
    var currentMovie: MoviesModel!
    let sessionObject = NetworkManager.sharedInstance()
    let dataSource = DataSource.sharedInstance()
    
    //MARK: LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the movie exits in Data Source
        for movie in dataSource.movieDetailsDic {
            if movie.movieDetails.imdbID == movieID {
                currentMovie = movie
                break
            }
        }
        
        // If not Fetch Details
        if currentMovie == nil {
            sessionObject.getMovieDetailsForID(movieID) { (movieDetail , _) in
                self.currentMovie = movieDetail
                self.dataSource.movieDetailsDic.append(movieDetail!)
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
