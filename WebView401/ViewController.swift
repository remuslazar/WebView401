//
//  ViewController.swift
//  WebView401
//
//  Created by Remus Lazar on 06.09.16.
//  Copyright © 2016 Remus Lazar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! { didSet { webView.delegate = self } }

    private func loadURL(url: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!,
                                          cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: NSTimeInterval(10))
        request.HTTPMethod = "POST"
        fetchDataForRequest(request) { (data, response, _) in
            dispatch_async(dispatch_get_main_queue()) {
                self.webView.loadData(data!, MIMEType: response!.MIMEType!, textEncodingName: response!.textEncodingName ?? "utf-8", baseURL: request.URL!)
            }
        }
    }

    private func fetchDataForRequest(request: NSMutableURLRequest, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        
        print("fetch url: \(request.URL!)")
            
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {

                // check if we got 401
                if (response as! NSHTTPURLResponse).statusCode == 401 {
                    print("got 401, insert token")
                    // build the login token
                    let token = NSURLQueryItem(name: "token", value: "foo")
                    
                    // build the new URL with our token
                    let newURL = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)!
                    
                    if newURL.queryItems != nil && newURL.queryItems!.contains(token) {
                        print("uuh, still got 401 with token, bail out!")
                        completionHandler(data: data, response: response, error: error)
                    } else {
                        newURL.queryItems?.append(token)
                        request.URL = newURL.URL
                        self.fetchDataForRequest(request, completionHandler: completionHandler)
                    }
                    
                } else {
                    // no 401, return the data to the caller
                    completionHandler(data: data, response: response, error: error)
                }
            }
        }).resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // this URL will return a 401
        loadURL("https://api.openchargemap.io/v2/?action=comment_submission&format=json")
    }

}

