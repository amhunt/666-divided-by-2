//
//  PDFViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/6/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import SwiftSpinner

class PDFViewController: UIViewController, UIWebViewDelegate {

    
    @IBOutlet weak var pdfWebView: UIWebView!
    var pdfUrlString: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pdfWebView.delegate = self
        self.tabBarController?.tabBar.hidden = true
        let pdfURLtest = NSURL(string: pdfUrlString!)
        let request = NSURLRequest(URL: pdfURLtest!)
        self.automaticallyAdjustsScrollViewInsets = false;
        self.pdfWebView.loadRequest(request);

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    // MARK: - WebView Delegate Methods: progress indicator
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // start animating
        SwiftSpinner.show("Loading sheet music...")
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // stop animating
        SwiftSpinner.hide()
    }

}
