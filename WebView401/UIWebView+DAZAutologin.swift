//
//  UIWebView+DAZAutologin.swift
//  WebView401
//
//  Created by Remus Lazar on 07.09.16.
//  Copyright © 2016 Remus Lazar. All rights reserved.
//

import UIKit

extension UIWebView {

    // MARK: - Public API
    
    public func loadDAZURL(url: String) {
        
        NSUserDefaults.standardUserDefaults().setObject(url, forKey: "lastURL")
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!,
                                          cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: NSTimeInterval(10))
        DAZAutoLogin.sharedInstance.fetchDataWithRequest(request) { (data, response, _) in
            dispatch_async(dispatch_get_main_queue()) {
                print("response: \(response)")
                self.loadData(data!, MIMEType: response!.MIMEType!, textEncodingName: response!.textEncodingName ?? "utf-8", baseURL: request.URL!)
            }
        }
    }
    
}
