//
//  ClassesTableViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/26/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class ClassesTableViewController: UITableViewController {

    var myClasses : [ClassEntity] = []
    
    override func viewWillAppear(_ animated: Bool) {
        getClasses()
        tableView.reloadData()
    }
    
    // MARK: - Deleting function
    
    func deleteAll() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                    if let coreDataClasses = entityClasses {
                        if let coreDataAssignments = entityAssignments {
                            for aClass in coreDataClasses {
                                context.delete(aClass)
                            }
                            for assignment in coreDataAssignments {
                                context.delete(assignment)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Setup functions
    
    func getClasses() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                if let coreDataClasses = entityClasses {
                    myClasses = coreDataClasses
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myClasses.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
        cell.cellColor.backgroundColor = UIColor(red: CGFloat(myClasses[indexPath.row].red), green: CGFloat(myClasses[indexPath.row].green), blue: CGFloat(myClasses[indexPath.row].blue), alpha: 1.0)
        cell.cellLabel.text = myClasses[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myClass = myClasses[indexPath.row]
        performSegue(withIdentifier: "classesToHW", sender: myClass)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let newClassVC = segue.destination as? NewClassViewController {
            newClassVC.previousVC = self
        }

        if let classHWVC = segue.destination as? ClassHomeworkTableViewController {
            classHWVC.previousVC = self
            if let selectedClass = sender as? ClassEntity {
                classHWVC.currentClass = selectedClass
            }
        }
    
    }

}
