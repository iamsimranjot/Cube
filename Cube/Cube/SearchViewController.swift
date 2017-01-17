//
//  SearchViewController.swift
//  Cube
//
//  Created by SimranJot Singh on 17/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
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
        
        // Configure Table View
        moviesTableView.estimatedRowHeight = 50
        moviesTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK: Helper Methods
    
    func configureUIState(_ state: UIState){
        switch state {
        case .NoContent:
            moviesTableView.isHidden = true
            emptyView.isHidden = false
        case .WithContent:
            emptyView.isHidden = true
            moviesTableView.isHidden = false
        }
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
            return "Movies"
        } else if section == 1 {
            return "Series"
        } else {
            return "Episodes"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "MovieSearchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        if indexPath.section == 0 {
            if moviesArray.count != 0 {
                cell?.textLabel?.text = moviesArray[indexPath.row]
            } else {
                cell?.textLabel?.text = "No Movies Found"
            }
        } else if indexPath.section == 1 {
            if seriesArray.count != 0 {
                cell?.textLabel?.text = seriesArray[indexPath.row]
            } else {
                cell?.textLabel?.text = "No Series Found"
            }
        } else {
            if episodeArray.count != 0 {
                cell?.textLabel?.text = episodeArray[indexPath.row]
            } else {
                cell?.textLabel?.text = "No Episodes Found"
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return moviesArray.count != 0 ? moviesArray.count : 1
        } else if section == 1 {
            return seriesArray.count != 0 ? seriesArray.count : 1
        } else {
            return episodeArray.count != 0 ? episodeArray.count : 1
        }
    }
}

