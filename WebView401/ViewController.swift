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
            if !textField.text!.lowercaseString.containsString("://") {
                textField.text = "http://" + textField.text!
            }

            // load URL if URL ok
            if let _ = NSURL(string: textField.text!) {
                webView.loadDAZURL(textField.text!)
                return true
            }
        }

        return false
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        urlTextField?.text = request.URL?.absoluteString
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        urlTextField.backgroundColor = UIColor.lightGrayColor()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        urlTextField.backgroundColor = nil
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("lastURL")
        if let url = urlTextField.text { webView.loadDAZURL(url) }
        // this URL will return a 401
//        loadURL("https://api.openchargemap.io/v2/?action=comment_submission&format=json")
    }

}

