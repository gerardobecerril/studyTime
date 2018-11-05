//
//  ClassInfoViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/28/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class ClassInfoViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var teacherField: UITextField!
    @IBOutlet weak var colorField: UITextField!
    @IBOutlet weak var notesView: UITextView!
    var previousVC = ClassHomeworkTableViewController()
    var assignmentsTableVC = AssignmentsTableViewController()
    
    var currentClass : ClassEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let unwrappedName = currentClass?.name {
            if let unwrappedTeacher = currentClass?.teacher {
                if let unwrappedNotes = currentClass?.notes {
                    nameField.text = unwrappedName
                    teacherField.text = unwrappedTeacher
                    notesView.text = unwrappedNotes
                }
            }
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if nameField.text != "" && teacherField.text != "" && colorField.text != "Pick a color" {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let newClass = ClassEntity(context: context)
                if let unwrappedName = nameField.text {
                    if let unwrappedNotes = notesView.text {
                        if let unwrappedTeacher = teacherField.text {
                            if let unwrappedColor = colorField.text {
                                newClass.name = unwrappedName
                                newClass.notes = unwrappedNotes
                                newClass.teacher = unwrappedTeacher
                                let myColors : [Double] = chooseColor(color: unwrappedColor)
                                newClass.red = Int16(myColors[0])
                                newClass.green = Int16(myColors[1])
                                newClass.blue = Int16(myColors[2])
                            }
                        }
                    }
                }
                
                try? context.save()
                previousVC.previousVC.shouldReloadData = true
                navigationController?.popViewController(animated: true)
                
            }
            
        } else {
            
            displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
            
        }
        
    }
    
    func chooseColor(color: String) -> [Double] {
        var colorArray = [1.0, 1.0, 1.0]
        switch(color) {
        case "Red":
            colorArray = [1, 0, 0]
        case "Light green":
            colorArray = [Double(128/255), 1.0, 0.0]
        case "Dark green":
            colorArray = [Double(76/255), Double(153/255), 0.0]
        case "Light blue":
            colorArray = [0, 1.0, 1.0]
        case "Dark blue":
            colorArray = [Double(51/255), Double(51/255), 1.0]
        case "Purple":
            colorArray = [Double(102/255), 0.0, Double(204/255)]
        case "Yellow":
            colorArray = [1.0, 1.0, 0.0]
        case "Grey":
            colorArray = [Double(160/255), Double(160/255), Double(160/255)]
        case "Brown":
            colorArray = [Double(102/255), Double(51/255), 0.0]
        case "Orange":
            colorArray = [1.0, Double(128/255), 0.0]
        default:
            colorArray = [1.0, 1.0, 1.0]
        }
        return colorArray
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                
                if let coreDataAssignments = entityAssignments {
                    
                    for assignment in coreDataAssignments {
                        if assignment.rgbClass == currentClass?.name {
                            context.delete(assignment)
                        }
                    }
                }
            }
            
            if let selectedClass = currentClass {
                context.delete(selectedClass)
                navigationController?.popViewController(animated: true)
                previousVC.navigationController?.popViewController(animated: true)
            }
            
            try? context.save()
            previousVC.previousVC.shouldReloadData = true
            GlobalData.shouldReloadAssignments = true
            
        }
    }
    
}
