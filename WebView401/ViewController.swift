//
//  ViewController.swift
//  WebView401
//
//  Created by Remus Lazar on 06.09.16.
//  Copyright © 2016 Remus Lazar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView! { didSet { webView.delegate = self } }
    @IBOutlet weak var urlTextField: UITextField! { didSet { urlTextField.delegate = self } }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField.text != nil {
            // trim
            textField.text = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            // prepend http://
            if !textField.text!.lowercaseString.hasPrefix("http://") {
                textField.text = "http://" + textField.text!
            }

            // load URL if URL ok
            if let _ = NSURL(string: textField.text!) {
                loadURL(textField.text!)
                return true
            }
        }

        return false
    }
    
    private func loadURL(url: String) {
        
        NSUserDefaults.standardUserDefaults().setObject(url, forKey: "lastURL")
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!,
                                          cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: NSTimeInterval(10))
        fetchDataForRequest(request) { (data, response, _) in
            dispatch_async(dispatch_get_main_queue()) {
                print("response: \(response)")
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
        urlTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("lastURL")
        // this URL will return a 401
//        loadURL("https://api.openchargemap.io/v2/?action=comment_submission&format=json")
    }

}

