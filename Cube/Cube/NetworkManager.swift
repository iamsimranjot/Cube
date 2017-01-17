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
    
    func taskForMethod(request: URLRequest, completionHandler: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // Make the request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                completionHandler(nil, error.description)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        // Start the request
        task.resume()
        
        return task
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            
            completionHandlerForConvertData(nil, "Could not parse the data as JSON: '\(data)'")
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func getSearchResultsFor(_ searchString: String, requestMethod: HTTPMethod = .GET, requestHeaders: [String:String]? = nil, requestBody: [String:AnyObject]? = nil, responseHandler: @escaping (_ resultDic: [String : [String]]?, _ error: String?, _ response: Bool?) -> Void) -> URLSessionDataTask? {
        
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
        
        // Make the request
        let task = taskForMethod(request: request){ (result, error) in
            
            if let error = error {
                responseHandler(nil, error, nil)
            } else {
                // Unwrap result
                if let search = result?[responseKeys.search] as? [[String : AnyObject]] {
                    var results = [String : [String]]()
                    var movieArray = [String]()
                    var seriesArray = [String]()
                    var episodeArray = [String]()
                    
                    for dic in search {
                        if (dic[responseKeys.type] as! String == parameterValues.movie){
                            let value = "\(dic[responseKeys.title] as! String) , \(dic[responseKeys.year] as! String)"
                            movieArray.append(value)
                        } else if (dic[responseKeys.type] as! String == parameterValues.series){
                            let value = "\(dic[responseKeys.title] as! String) , \(dic[responseKeys.year] as! String)"
                            seriesArray.append(value)
                        } else {
                            let value = "\(dic[responseKeys.title] as! String) , \(dic[responseKeys.year] as! String)"
                            episodeArray.append(value)
                        }
                    }
                    
                    results[parameterValues.movie] = movieArray
                    results[parameterValues.series] = seriesArray
                    results[parameterValues.episode] = episodeArray
                    
                    
//                    for dic in search {
//                        let value = "\(dic[responseKeys.title] as! String) , \(dic[responseKeys.year] as! String)\n(\(dic[responseKeys.type] as! String))"
//                        idArray.append(value)
//                    }
                    responseHandler(results, nil, true)
                    return
                } else {
                    responseHandler(nil, nil, false)
                    return
                }
            }
        }
        return task
    }
    
    func getMovieDetailsForID(_ imdbID: String, requestMethod: HTTPMethod = .GET, requestHeaders: [String:String]? = nil, requestBody: [String:AnyObject]? = nil, responseHandler: @escaping (_ movieDetails: MoviesModel?, _ success: Bool) -> Void) {
        
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
            
            responseHandler(MoviesModel.detailsFromDictionary(dictionary: parsedResult), true)
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
        static let year = "Year"
        static let type = "Type"
        static let error = "Error"
    }
    
    //MARK: Pamameter Keys
    
    struct parameterKeys {
        static let search = "s"
        static let id = "i"
        static let type = "type"
    }
    
    struct parameterValues {
        static let movie = "movie"
        static let series = "series"
        static let episode = "episode"
    }
    
    //MARK: Error Messages Constants
    
    struct Errors {
        static let unsuccessfulStatusCode = "Unsuccessful Status Code Received."
        static let noDataReturned = "No data was returned by the request."
        static let unableToParseData = "We are unable to complete your request. Please try again after some time."
    }
}
