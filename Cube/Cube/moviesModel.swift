//
//  MoviesModel.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

struct MoviesModel {
    
    //MARK: Properties
    
    let movieDetails: MovieDetails
    
    //MARK: Initializer
    
    init(dictionary: [String : AnyObject]) {
        let title = dictionary[NetworkManager.responseKeys.title] as? String ?? ""
        let genre = dictionary[NetworkManager.responseKeys.genre] as? String ?? ""
        let releaseDate = dictionary[NetworkManager.responseKeys.releaseDate] as? String ?? ""
        let imdbid = dictionary[NetworkManager.responseKeys.imdbID] as? String ?? ""
        let plot = dictionary[NetworkManager.responseKeys.plot] as? String ?? ""
        let ratings = dictionary[NetworkManager.responseKeys.ratings] as? String ?? ""
        let posterUrl = dictionary[NetworkManager.responseKeys.posterUrl] as? String ?? ""
        
        movieDetails = MovieDetails(title: title, genre: genre, releaseDate: releaseDate, imdbId: imdbid, plot: plot, ratings: ratings, imageUrl: posterUrl)
    }
    
    // Helper Methods
    static func detailsFromDictionary(dictionary: [String: AnyObject]) -> MoviesModel {
        return MoviesModel(dictionary: dictionary)
    }
}

