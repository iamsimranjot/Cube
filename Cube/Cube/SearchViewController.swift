//
//  SearchViewController.swift
//  Cube
//
//  Created by SimranJot Singh on 17/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moviesTableView: UITableView!
    
    //MARK: Properties
    
    var movies = [String]()
    var searchTask: URLSessionDataTask?
    
    //MARK: LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            movies = [String]()
            moviesTableView?.reloadData()
            return
        }
        
        // new search
        searchTask = NetworkManager.sharedInstance().getSearchResultsFor(searchText) { (movies, error, response) in
            self.searchTask = nil
            if let movies = movies {
                self.movies = movies
                DispatchQueue.main.async {
                    self.moviesTableView!.reloadData()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "MovieSearchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        cell?.textLabel?.text = movies[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}

