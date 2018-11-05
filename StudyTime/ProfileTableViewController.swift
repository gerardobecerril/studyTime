//
//  ProfileTableViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 11/5/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    var username = "Default username"
    var classCount = 0
    var assignmentsCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        classCount = countClasses()
        assignmentsCount = countAssignments()
        tableView.reloadData()
    }
    
    func countClasses() -> Int {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                
                if let coreDataClasses = entityClasses {
                    return coreDataClasses.count
                }
            }
        }
        return 0
    }
    
    func countAssignments() -> Int {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                
                if let coreDataAssignments = entityAssignments {
                    return coreDataAssignments.count
                }
            }
        }
        return 0
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel!.text = username + "."
        } else if indexPath.row == 1 {
            cell.textLabel!.text = String(classCount) + " classes."
        } else {
            cell.textLabel!.text = String(assignmentsCount) + " assignments left."
        }
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

}
