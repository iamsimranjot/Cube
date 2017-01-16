//
//  DataSource.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import UIKit

class DataSource: NSObject {
    
    //MARK: Properties
    var movieID = [String]()
    var movieDetailsDic = [MovieDetails]()
    
    //MARK: Singleton Instance
    private static let sharedManager = DataSource()
    
    class func sharedInstance() -> DataSource  {
        return sharedManager
    }
    
    // Helper Methods
    func fillIDsFromSearchResultDic(dictionary: [String : AnyObject]) {
        movieID.append(dictionary[NetworkManager.responseKeys.imdbID] as! String)
    }
}
