//
//  SearchViewController.swift
//  Cube
//
//  Created by SimranJot Singh on 17/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: UIConfiguration Enum
    
    enum UIState { case NoContent, WithContent }
    
    //MARK: Outlets
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var moviesTableView: UITableView!
    
    //MARK: Properties
    
    var movies = [String : [String]]()
    var searchTask: URLSessionDataTask?
    var moviesArray = [String]()
    var seriesArray = [String]()
    var episodeArray = [String]()
    
    //MARK: LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Initial View
        configureUIState(.NoContent)
        
        // Configure Table View for automatic height according to the content dynamically
        moviesTableView.estimatedRowHeight = 50
        moviesTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    //MARK: Helper Methods
    
    func configureUIState(_ state: UIState){
        switch state {
        case .NoContent:
            moviesTableView.isHidden = true
            emptyView.isHidden = false
            emptyView.backgroundColor = UIColor(hex: 0x65c3ba)
        case .WithContent:
            emptyView.isHidden = true
            moviesTableView.isHidden = false
            moviesTableView.backgroundColor = UIColor(hex: 0x83d0c9)
        }
        
        idleView.backgroundColor = UIColor(hex: 0x65c3ba)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desitination = segue.destination as! MovieDetailsViewController
        desitination.movieTitle = sender as? String
    }
}

// MARK: - SearchViewController: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    // each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // if the text is empty we are done
        if searchText == "" {
            movies = [String : [String]]()
            moviesTableView?.reloadData()
            configureUIState(.NoContent)
            return
        }
        
        // new search
        searchTask = NetworkManager.sharedInstance().getSearchResultsFor(searchText) { (movies, error, response) in
            self.searchTask = nil
            if let movies = movies {
                self.movies = movies
                
                self.moviesArray = movies["movie"]!
                self.seriesArray = movies["series"]!
                self.episodeArray = movies["episode"]!

                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        let indexSet = NSIndexSet.init(indexesIn: NSRange(location: 0,length: self.moviesTableView.numberOfSections))
                        self.moviesTableView!.reloadSections(indexSet as IndexSet, with: UITableViewRowAnimation.automatic)
                        self.configureUIState(.WithContent)
                    })
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - SearchViewController: UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return AppConstants.HeaderTitles.movies
        } else if section == 1 {
            return AppConstants.HeaderTitles.series
        } else {
            return AppConstants.HeaderTitles.episodes
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = AppConstants.Identifiers.searchMovieCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as! SearchTableViewCell
        cell.backgroundColor = UIColor(hex: 0x83d0c9)
        
        if indexPath.section == 0 {
            if moviesArray.count != 0 {
                cell.configureCell(title: moviesArray[indexPath.row])
            } else {
                cell.configureCell(title: AppConstants.defaultCellValues.noMovies)
            }
        } else if indexPath.section == 1 {
            if seriesArray.count != 0 {
                cell.configureCell(title: seriesArray[indexPath.row])
            } else {
                cell.configureCell(title: AppConstants.defaultCellValues.noSeries)
            }
        } else {
            if episodeArray.count != 0 {
                cell.configureCell(title: episodeArray[indexPath.row])
            } else {
                cell.configureCell(title: AppConstants.defaultCellValues.noEpisodes)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return the number of rows for each section with fetched data
        if section == 0 {
            return moviesArray.count != 0 ? moviesArray.count : 1
        } else if section == 1 {
            return seriesArray.count != 0 ? seriesArray.count : 1
        } else {
            return episodeArray.count != 0 ? episodeArray.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Show Details Screen when the respected row is selected.
        // Check for the placeholder cells
        
        let senderObject: String?
        if indexPath.section == 0 && moviesArray.count != 0 {
            senderObject = moviesArray[indexPath.row]
        } else if indexPath.section == 1 && seriesArray.count != 0 {
            senderObject = seriesArray[indexPath.row]
        } else {
            if episodeArray.count != 0 {
                senderObject = episodeArray[indexPath.row]
            } else {
                senderObject = nil
            }
        }
        
        // Deselects the cell afterwards
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Check if it has a sender & perform show segue
        if let senderObject = senderObject {
            performSegue(withIdentifier: AppConstants.Identifiers.movieDetailsSegueIdentifier, sender: senderObject)
        }
    }
}

