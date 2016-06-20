//
//  HighStakesViewController.swift
//  
//
//  Created by Zachary Stecker on 5/17/16.
//
//

import UIKit

class HighStakesViewController: UIViewController {

    @IBOutlet weak var cardLabel: UILabel!
    
    var barColor: UIColor?
    
    let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    let suits = ["♠️", "♣️", "♥️", "♦️"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barColor = self.navigationController?.navigationBar.barTintColor
        generateRandomCard()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = barColor
    }
    
    func generateRandomCard() {
        let rank = Int(arc4random_uniform(13))
        let suit = Int(arc4random_uniform(4))
        
        let card = ranks[rank] + suits[suit]
        
        var color = UIColor.blackColor()
        if suit == 2 || suit == 3 {
            color = UIColor(red: 208/255, green: 54/255, blue: 28/255, alpha: 1)
        }
        
        showCard(card, color: color)
    }
    
    func showCard(card: String, color: UIColor) {
        cardLabel.textColor = color
        cardLabel.text = card
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    @IBAction func getAnotherCardDidTouch(sender: AnyObject) {
        generateRandomCard()
    }
    
}
