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
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUsername()
        classCount = countClasses()
        assignmentsCount = countAssignments()
        tableView.reloadData()
    }
    
    func getUsername() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityUsername = try? context.fetch(UsernameEntity.fetchRequest()) as? [UsernameEntity] {
                
                if let coreDataUsername = entityUsername {
                    if coreDataUsername.count > 0 {
                        if let unwrappedUsername = coreDataUsername[0].username {
                            username = unwrappedUsername
                        }
                    }
                }
            }
        }
        
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
            cell.isUserInteractionEnabled = true
        } else if indexPath.row == 1 {
            if classCount == 1 {
                cell.textLabel!.text = String(classCount) + " class."
            } else {
                cell.textLabel!.text = String(classCount) + " classes."
            }
            cell.isUserInteractionEnabled = false
        } else {
            if assignmentsCount == 1 {
                cell.textLabel!.text = String(assignmentsCount) + " assignment left."
            } else {
                cell.textLabel!.text = String(assignmentsCount) + " assignments left."
            }
            cell.isUserInteractionEnabled = false
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "toEditName", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
