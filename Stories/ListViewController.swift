//
//  ListViewController.swift
//  Stories
//
//  Created by Ankita Satpathy on 17/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStory" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let storyVC = segue.destination as! StoryViewController
                storyVC.rowIndex = indexPath.row
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

// MARK:- Table View Data Source and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = "Story \(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showStory", sender: self)
    }
}
