//
//  TodayViewController.swift
//  Pitches
//
//  Created by Zachary Stecker on 5/27/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import NotificationCenter
import AVFoundation

class TodayViewController: UIViewController, NCWidgetProviding {
    
     var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playE(sender: AnyObject) {
        let path = NSBundle.mainBundle().pathForResource("EHigh", ofType:"mp3", inDirectory: "Pitches")!
        let url = NSURL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            self.player = sound
            sound.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
