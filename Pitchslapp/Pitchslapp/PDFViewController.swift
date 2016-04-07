//
//  PDFViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/6/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PDFViewController: UIViewController {

    
    @IBOutlet weak var pdfWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        let pdfLoc = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("MakeYouFeel", ofType:"pdf")!)
        let request = NSURLRequest(URL: pdfLoc);
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
