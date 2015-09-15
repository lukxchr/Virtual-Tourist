//
//  DebugVC.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 14/09/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import CoreData

class DebugVC: UIViewController {
    
    
    @IBOutlet weak var textArea: UITextView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    @IBAction func add(sender: UIButton) {
        let d = Double(arc4random_uniform(100)) + 0.2
        let new_d = DE1(d: d, context: sharedContext)
        var error: NSError?
        sharedContext.save(&error)
    }
    
    
    @IBAction func load(sender: AnyObject) {
        let req = NSFetchRequest(entityName: "DE1")
        
        var error: NSError?
        let res = sharedContext.executeFetchRequest(req, error: &error) as! [DE1]
        var sum = 0.0
        for r in res {
            sum += Double(r.d)
        }
        
        textArea.text = "\(sum)"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let d1 = DE1(d: 7.2, context: sharedContext)
//        let d2 = DE1(d: 7.9, context: sharedContext)
//
//        var error: NSError?
//        sharedContext.save(&error)
        // Do any additional setup after loading the view.
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
