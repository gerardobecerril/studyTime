//
//  ClassHomeworkTableViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/28/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class ClassHomeworkTableViewController: UITableViewController {

    var previousVC = ClassesTableViewController()
    var currentClass = ClassEntity()
    var myAssignments : [AssignmentEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAssignments()
    }
    
    func getAssignments() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                
                if let coreDataAssignments = entityAssignments {
                    
                    for assignment in coreDataAssignments {
                        
                        if assignment.rgbClass == currentClass.name {
                            
                            myAssignments.append(assignment)
                            
                        }
                        
                    }
                    
                    if myAssignments.count > 0 {
                        
                        for i in 0...myAssignments.count-1 {
                            if let myClassName = myAssignments[i].rgbClass {
                                let classColors = getClassesColors(currentClass: myClassName)
                                myAssignments[i].red = Int16(classColors[0])
                                myAssignments[i].green = Int16(classColors[1])
                                myAssignments[i].blue = Int16(classColors[2])
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func getClassesColors(currentClass: String) -> [Int] {
        
        var colorArray : [Int] = []
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                
                if let coreDataClasses = entityClasses {
                    
                    if coreDataClasses.count > 0 {
                        
                        for i in 0...coreDataClasses.count-1 {
                            if let myClassName = coreDataClasses[i].name {
                                if currentClass == myClassName {
                                    colorArray.append(Int(coreDataClasses[i].red))
                                    colorArray.append(Int(coreDataClasses[i].green))
                                    colorArray.append(Int(coreDataClasses[i].blue))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return colorArray
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myAssignments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
        cell.cellColor.backgroundColor = UIColor(red: CGFloat(myAssignments[indexPath.row].red), green: CGFloat(myAssignments[indexPath.row].green), blue: CGFloat(myAssignments[indexPath.row].blue), alpha: 1.0)
        cell.cellLabel.text = myAssignments[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myAssignment = myAssignments[indexPath.row]
        performSegue(withIdentifier: "toHWInfo", sender: myAssignment)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segues
    
    @IBAction func infoTapped(_ sender: Any) {
        performSegue(withIdentifier: "toClassInfo", sender: currentClass)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let infoVC = segue.destination as? ClassInfoViewController {
            infoVC.previousVC = self
            if let selectedClass = sender as? ClassEntity {
                infoVC.currentClass = selectedClass
            }
        }
        
    }

}
