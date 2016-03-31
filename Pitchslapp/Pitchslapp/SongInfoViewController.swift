//
//  SongInfoViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase

class SongInfoViewController: UITableViewController {
    
    var song: SongItem!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
