//
//  DAZAutoLogin.swift
//  WebView401
//
//  Created by Remus Lazar on 07.09.16.
//  Copyright © 2016 Remus Lazar. All rights reserved.
//

import Foundation
import JWT

class DAZAutoLogin {
    
    private struct Settings {
        static let UserAgent = "WebView401 DAZ-iOS/0.0-dev"
        static let JWTSecret = "my-secret"
        static let ObisID = "my-obis-id"
    }
    
    static let sharedInstance = DAZAutoLogin()
    
    init() {
        NSURLSessionConfiguration.defaultSessionConfiguration().HTTPAdditionalHeaders = [
            "User-Agent": Settings.UserAgent,
        ]
    }
    
    func getTokenForObisID(id: String = Settings.ObisID) -> String {
        return JWT.encode(["obisID": id], algorithm: .HS256(Settings.JWTSecret))
    }
    
    func fetchDataWithRequest(request: NSMutableURLRequest, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        
        print("fetch url: \(request.URL!)")
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                
                // check if we got 401
                if (response as! NSHTTPURLResponse).statusCode == 401 {
                    // build the login token
                    let token = NSURLQueryItem(name: "jwt", value: DAZAutoLogin.sharedInstance.getTokenForObisID())
                    
                    // build the new URL with our token
                    let newURL = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)!
                    
                    if newURL.queryItems != nil && newURL.queryItems!.contains(token) {
                        print("uuh, still got 401 with token, bail out!")
                        completionHandler(data: data, response: response, error: error)
                    } else {
                        print("got 401, insert token")
                        if newURL.queryItems == nil { newURL.queryItems = [] }
                        newURL.queryItems?.append(token)
                        request.URL = newURL.URL
                        self.fetchDataWithRequest(request, completionHandler: completionHandler)
                    }
                    
                } else {
                    // no 401, return the data to the caller
                    completionHandler(data: data, response: response, error: error)
                }
            }
        }).resume()
        
    }
    
}