//
//  MovieDetails.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

struct MovieDetails {
    
    //MARK: Properties 
    
    let title: String
    let genre: String
    let releaseDate: String
    let imdbID: String
    let plot: String
    let ratings: String
    let posterUrl: String
    
    //MARK: Initializers
    
    init(title: String, genre: String, releaseDate: String, imdbId: String, plot: String, ratings: String, imageUrl: String) {
        self.title = title
        self.genre = genre
        self.imdbID = imdbId
        self.releaseDate = releaseDate
        self.plot = plot
        self.ratings = ratings
        self.posterUrl = imageUrl
    }
}
