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
    var currentAssignment : AssignmentEntity?
    var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classField.text = currentAssignment?.rgbClass
        descField.text = currentAssignment?.desc
        if let unwrappedDate = currentAssignment?.date {
            dayField.text = days[Int(unwrappedDate)]
        }
    }
    
    @IBAction func homeworkDoneTapped(_ sender: Any) {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let selectedAssignment = currentAssignment {
                context.delete(selectedAssignment)
                navigationController?.popViewController(animated: true)
            }
            
            try? context.save()
            
        }
        
        previousVC.shouldReloadData = true
        
    }

}
