//
//  NetworkManager.swift
//  Cube
//
//  Created by SimranJot Singh on 16/01/17.
//  Copyright © 2017 SimranJot Singh. All rights reserved.
//

import Foundation

//Global
//MARK: HTTP Request Method Enum

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

//MARK: APIUrlData

struct APIData {
    let scheme: String
    let host: String
    let path: String
}

class NetworkManager {
    
    //MARK: Properties
    
    private let session: URLSession!
    private let apiData: APIData
    
    //MARK: Singleton Class
    
    private static var sharedManager = NetworkManager()
    
    class func sharedInstance() -> NetworkManager {
        return sharedManager
    }
    
    //MARK: Initializer
    
    init() {
        
        // Get your Configuration Object
        let sessionConfiguration = URLSessionConfiguration.default
        
        // Set the Configuration on your session object
        session = URLSession(configuration: sessionConfiguration)
        
        // Set APIData
        apiData = APIData(scheme: APIComponents.scheme, host: APIComponents.host, path: APIComponents.path)
    }
    
    //MARK: Data Task Methods
    
    func getSearchResultsFor(_ searchString: String, requestMethod: HTTPMethod = .GET, requestHeaders: [String:String]? = nil, requestBody: [String:AnyObject]? = nil, responseHandler: @escaping (_ idArray: [String]?, _ error: String?, _ response: Bool?) -> Void) {
        
        // Make URL
        let url = urlForRequest(parameters: [
            parameterKeys.search: searchString as AnyObject])
        
        // Create request from URL
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        
        // Add headers if present
        if let requestHeaders = requestHeaders {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body if present
        if let requestBody = requestBody {
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: JSONSerialization.WritingOptions())
        }
        
        // Create Data Task
        let task = session.dataTask(with: request){ (data, response, error) in
            
            // Check for errors
            if let error = error {
                responseHandler(nil, error.localizedDescription, nil)
                return
            }
            
            // Check for successful response via status codes
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 200 && statusCode > 299 {
                responseHandler(nil, Errors.unsuccessfulStatusCode, nil)
                return
            }
            
            // Check weather the data returned is not nil
            guard let data = data else {
                responseHandler(nil, Errors.noDataReturned, nil)
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                responseHandler(nil, Errors.unableToParseData, nil)
                return
            }
            
            // Unwrap result
            if let search = parsedResult[responseKeys.search] as? [[String : AnyObject]] {
                var idArray = [String]()
                for dic in search {
                    idArray.append(dic[responseKeys.imdbID] as! String)
                }
                responseHandler(idArray, nil, true)
                return
            } else {
                responseHandler(nil, nil, false)
                return
            }
        }
        
        task.resume()
    }
    
    func getMovieDetailsForID(_ imdbID: String, requestMethod: HTTPMethod = .GET, requestHeaders: [String:String]? = nil, requestBody: [String:AnyObject]? = nil, responseHandler: @escaping (_ movieDetails: moviesModel?, _ success: Bool) -> Void) {
        
        // Make URL
        let url = urlForRequest(parameters: [
            parameterKeys.id: imdbID as AnyObject])
        
        // Create request from URL
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        
        // Add headers if present
        if let requestHeaders = requestHeaders {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body if present
        if let requestBody = requestBody {
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: JSONSerialization.WritingOptions())
        }
        
        // Create Data Task
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // Check for errors
            if let _ = error {
                responseHandler(nil, false)
                return
            }
            
            // Check for successful response via status codes
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 200 && statusCode > 299 {
                responseHandler(nil, false)
                return
            }
            
            // Check weather the data returned is not nil
            guard let data = data else {
                responseHandler(nil, false)
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                responseHandler(nil, false)
                return
            }
            
            responseHandler(moviesModel.detailsFromDictionary(dictionary: parsedResult), true)
        }
        task.resume()
    }
    
    //MARK: Build URL for request
    
    func urlForRequest(apiMethod: String? = nil, pathExtension: String? = nil, parameters: [String : AnyObject]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = apiData.scheme
        components.host = apiData.host
        components.path = apiData.path + (apiMethod ?? "") + (pathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
}

//MARK: Constants Extension

extension NetworkManager {
    
    //MARK: API Components
    
    struct APIComponents {
        static let scheme = "https"
        static let host = "www.omdbapi.com"
        static let path = ""
    }
    
    //MARK: JSONResponseKeys
    
    struct responseKeys {
        static let search = "Search"
        static let imdbID = "imdbID"
        static let title = "Title"
        static let ratings = "imdbRating"
        static let releaseDate = "Released"
        static let genre = "Genre"
        static let plot = "Plot"
        static let posterUrl = "Poster"
        static let response = "Response"
        static let error = "Error"
    }
    
    //MARK: Pamameter Keys
    
    struct parameterKeys {
        static let search = "s"
        static let id = "i"
        static let type = "type"
    }
    
    //MARK: Error Messages Constants
    
    struct Errors {
        static let unsuccessfulStatusCode = "Unsuccessful Status Code Received."
        static let noDataReturned = "No data was returned by the request."
        static let unableToParseData = "We are unable to complete your request. Please try again after some time."
    }
}
