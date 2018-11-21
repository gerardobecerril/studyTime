//
//  AssignmentsTableViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/31/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class AssignmentsTableViewController: UITableViewController {
    
    var myAssignments : [AssignmentEntity] = []
    var dates : [DayClass] = []
    
    override func viewWillAppear(_ animated: Bool) {
        dates = getDates()
        sortDates()
        getAssignments()
        tableView.reloadData()
        assignIDs()
    }
    
    // MARK: - Setup functions
    
    func assignIDs() {
        for assignment in myAssignments {
            assignment.previousID = assignment.identifier
        }
    }
    
    func sortDates() {
        var myDates : [Date] = []
        
        for date in dates {
            if let unwrappedDate = date.dueDate {
                myDates.append(unwrappedDate)
            }
        }
        myDates.sort()
        var i = 0
        for date in dates {
            date.dueDate = myDates[i]
            i += 1
        }
    }
    
    // USE SORT DESCRIPTOR SOMEHOW TO ALWAYS GET SAME ORDER
    func getAssignments() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                if let coreDataAssignments = entityAssignments {
                    //let sortDescriptor = NSSortDescriptor(key: "previousID", ascending: true, selector: #selector(NSString.localizedStandardCompare))
                    myAssignments = coreDataAssignments
                    if myAssignments.count > 0 {
                        for i in 0...myAssignments.count-1 {
                            myAssignments[i].identifier = Int16(i)
                            if let myClassName = myAssignments[i].rgbClass {
                                let classColors = getClassesColors(currentClass: myClassName)
                                myAssignments[i].red = classColors[0]
                                myAssignments[i].green = classColors[1]
                                myAssignments[i].blue = classColors[2]
                            }
                            if dates.count > 0 {
                                for j in 0...dates.count-1 {
                                    if dates[j].dueDate == myAssignments[i].dueDate {
                                        dates[j].assignmentsCounter += 1
                                        let myIdentifier = Int(myAssignments[i].identifier)
                                        dates[j].dailyAssignments.append(myIdentifier)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getClassesColors(currentClass: String) -> [Double] {
        var colorArray : [Double] = []
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                if let coreDataClasses = entityClasses {
                    if coreDataClasses.count > 0 {
                        for i in 0...coreDataClasses.count-1 {
                            if let myClassName = coreDataClasses[i].name {
                                if currentClass == myClassName {
                                    colorArray.append(coreDataClasses[i].red)
                                    colorArray.append(coreDataClasses[i].green)
                                    colorArray.append(coreDataClasses[i].blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        return colorArray
    }
    
    func getDates() -> [DayClass] {
        var myDates : [DayClass] = []
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                if let coreDataAssignments = entityAssignments {
                    if coreDataAssignments.count > 0 {
                        var datesCounter = 0
                        for i in 0...coreDataAssignments.count-1 {
                            let newDate = DayClass()
                            if let unwrappedDate = coreDataAssignments[i].dueDate {
                                var dateIsNew = true
                                for date in myDates {
                                    if date.dueDate == unwrappedDate {
                                        dateIsNew = false
                                    }
                                }
                                if dateIsNew {
                                    myDates.append(newDate)
                                    myDates[datesCounter].dueDate = unwrappedDate
                                    datesCounter += 1
                                }
                            }
                        }
                    }
                }
            }
        }
        return myDates
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dates.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 25
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dates[section].assignmentsCounter+1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var todaysAssignments : [AssignmentEntity] = []
        for i in 0...myAssignments.count-1 {
            if myAssignments[i].dueDate == dates[indexPath.section].dueDate {
                todaysAssignments.append(myAssignments[i])
            }
        }
        let myAssignment = todaysAssignments[indexPath.row-1]
        performSegue(withIdentifier: "toAssignmentInfo", sender: myAssignment)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = Bundle.main.loadNibNamed("CustomTableViewCell2", owner: self, options: nil)?.first as! CustomTableViewCell2
            cell.cellColor.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let unwrappedDate = dates[indexPath.section].dueDate {
                cell.cellLabel.text = dateFormatter.string(from: unwrappedDate)
            }
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
            cell.cellColor.backgroundColor = UIColor(red: CGFloat(myAssignments[dates[indexPath.section].dailyAssignments[indexPath.row-1]].red), green: CGFloat(myAssignments[dates[indexPath.section].dailyAssignments[indexPath.row-1]].green), blue: CGFloat(myAssignments[dates[indexPath.section].dailyAssignments[indexPath.row-1]].blue), alpha: 1.0)
            cell.cellLabel.text = myAssignments[dates[indexPath.section].dailyAssignments[indexPath.row-1]].name
            cell.isUserInteractionEnabled = true
            return cell
        }
    }
    
    // MARK : - Table view data 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let assignmentInfoVC = segue.destination as? AssignmentInfoViewController {
            if let selectedAssignment = sender as? AssignmentEntity {
                assignmentInfoVC.currentAssignment = selectedAssignment
            }
        }
        
    }

}
