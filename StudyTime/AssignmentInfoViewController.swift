//
//  AssignmentInfoViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 11/4/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class AssignmentInfoViewController: UIViewController {

    @IBOutlet weak var classField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var descField: UITextView!
    
    var previousVC = AssignmentsTableViewController()
    var previousVC2 = ClassHomeworkTableViewController()
    var currentAssignment : AssignmentEntity?
    var currentAssignment2 : AssignmentEntity?
    var currentSender = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentSender == 1 {
            if let unwrappedAssignment = currentAssignment {
                setUpView(myAssignment: unwrappedAssignment)
            }
        } else {
            if let unwrappedAssignment = currentAssignment2 {
                setUpView(myAssignment: unwrappedAssignment)
            }
        }
    }
    
    func setUpView(myAssignment: AssignmentEntity) {
        classField.text = myAssignment.rgbClass
        descField.text = myAssignment.desc
        if let unwrappedDate = myAssignment.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dayField.text = dateFormatter.string(from: unwrappedDate)
        }
    }
    
    @IBAction func homeworkDoneTapped(_ sender: Any) {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if currentSender == 1 {
                if let selectedAssignment = currentAssignment {
                    context.delete(selectedAssignment)
                    navigationController?.popViewController(animated: true)
                }
            } else {
                if let selectedAssignment = currentAssignment2 {
                    context.delete(selectedAssignment)
                    navigationController?.popViewController(animated: true)
                }
            }
            
            try? context.save()
            
        }
        
        previousVC.shouldReloadData = true
        previousVC2.shouldReloadData = true
        
    }

}
