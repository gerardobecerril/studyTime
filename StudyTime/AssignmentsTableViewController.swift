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
    var days : [DayClass] = []
    var shouldReloadData = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        days = addDays()
        getAssignments()
    }
    
    func getAssignments() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                
                if let coreDataAssignments = entityAssignments {
                    
                    myAssignments = coreDataAssignments
                    
                    if myAssignments.count > 0 {
                        
                        for i in 0...myAssignments.count-1 {
                            myAssignments[i].identifier = Int16(i)
                            if let myClassName = myAssignments[i].rgbClass {
                                let classColors = getClassesColors(currentClass: myClassName)
                                myAssignments[i].red = Int16(classColors[0])
                                myAssignments[i].green = Int16(classColors[1])
                                myAssignments[i].blue = Int16(classColors[2])
                            }
                        }
                        
                        for assignment in myAssignments {
                            if !days[Int(assignment.date)].dailyAssignments.contains(Int(assignment.identifier)) {
                                days[Int(assignment.date)].assignmentsCounter += 1
                                days[Int(assignment.date)].dailyAssignments.append(Int(assignment.identifier))
                            }
                        }
                        
                    }
                    
                    if shouldReloadData || GlobalData.shouldReloadAssignments {
                        tableView.reloadData()
                        shouldReloadData = false
                        GlobalData.shouldReloadAssignments = false
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
    
//    func getDates() -> [DayClass] {
//
//    }
    
    func addDays() -> [DayClass] {
        let monday = DayClass()
        monday.assignmentsCounter = 0
        monday.fakeDay = "Monday"
        let tuesday = DayClass()
        tuesday.assignmentsCounter = 0
        tuesday.fakeDay = "Tuesday"
        let wednesday = DayClass()
        wednesday.assignmentsCounter = 0
        wednesday.fakeDay = "Wednesday"
        let thursday = DayClass()
        thursday.assignmentsCounter = 0
        thursday.fakeDay = "Thursday"
        let friday = DayClass()
        friday.assignmentsCounter = 0
        friday.fakeDay = "Friday"
        let saturday = DayClass()
        saturday.assignmentsCounter = 0
        saturday.fakeDay = "Saturday"
        let sunday = DayClass()
        sunday.assignmentsCounter = 0
        sunday.fakeDay = "Sunday"
        
        return [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return days.count
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
        if days[section].assignmentsCounter == 0 {
            return 0
        } else {
            return days[section].assignmentsCounter+1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var todaysAssignments : [AssignmentEntity] = []
        if myAssignments.count > 0 {
            for assignment in 0...myAssignments.count-1 {
                if Int(myAssignments[assignment].date) == indexPath.section {
                    todaysAssignments.append(myAssignments[assignment])
                }
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
            cell.cellLabel.text = days[indexPath.section].fakeDay
            return cell
            
        } else {
            
            let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
            cell.cellColor.backgroundColor = UIColor(red: CGFloat(myAssignments[days[indexPath.section].dailyAssignments[indexPath.row-1]].red), green: CGFloat(myAssignments[days[indexPath.section].dailyAssignments[indexPath.row-1]].green), blue: CGFloat(myAssignments[days[indexPath.section].dailyAssignments[indexPath.row-1]].blue), alpha: 1.0)
            cell.cellLabel.text = myAssignments[days[indexPath.section].dailyAssignments[indexPath.row-1]].name
            return cell
            
        }
        
    }
    
    // MARK : - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let newAssignmentVC = segue.destination as? NewAssignmentViewController {
            newAssignmentVC.previousVC = self
        }
        
        if let assignmentInfoVC = segue.destination as? AssignmentInfoViewController {
            if let selectedAssignment = sender as? AssignmentEntity {
                assignmentInfoVC.previousVC = self
                assignmentInfoVC.currentAssignment = selectedAssignment
            }
        }
        
    }

}
