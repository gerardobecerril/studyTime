//
//  NewAssignmentViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/31/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class NewAssignmentViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var classField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var descField: UITextView!
    let pickerView = UIPickerView()
    
    var previousVC = AssignmentsTableViewController()
    var selectedClass : String?
    var selectedDate : String?
    var realSelectedDate : Int?
    var currentField : Int?
    var lastRowForClass = 0
    var lastRowForDate = 0
    var classWasSelected = false
    var dateWasSelected = false
    var classDidBeginEditing = false
    var dateDidBeginEditing = false
    var myClasses : [String] = []
    var myDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var myDates = [0, 1, 2, 3, 4, 5, 6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        getMyClasses()
        textViewPlaceholder()
        titleField.text = ""
        dateField.text = "Due date"
        classField.text = "Class"
        pickerView.delegate = self
        classField.inputView = pickerView
        dateField.inputView = pickerView
        classField.tag = 1
        dateField.tag = 2
        classField.delegate = self
        dateField.delegate = self
        descField.delegate = self
        createToolBar()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if titleField.text != "" && dateField.text != "Due date" && classField.text != "Class" {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let newAssignment = AssignmentEntity(context: context)
                if let unwrappedTitleField = titleField.text {
                    if let unwrappedDescField = descField.text {
                        if let unwrappedSelectedDate = realSelectedDate {
                            if let unwrappedClassName = classField.text {
                                newAssignment.name = unwrappedTitleField
                                newAssignment.desc = unwrappedDescField
                                newAssignment.date = Int16(unwrappedSelectedDate)
                                newAssignment.rgbClass = unwrappedClassName
                            }
                        }
                    }
                }
                
                try? context.save()
                previousVC.shouldReloadData = true
                navigationController?.popViewController(animated: true)
                
            }
            
        } else {
            
            displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
            
        }
        
    }
    
    func getMyClasses() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                
                if let coreDataClasses = entityClasses {
                    
                    for i in 0...coreDataClasses.count-1 {
                        if let myClassName = coreDataClasses[i].name {
                            myClasses.append(myClassName)
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - PickerViews
    
    @objc func dismissKeyboardForPickerView() {
        view.endEditing(true)
        
        if !classWasSelected && classDidBeginEditing {
            classField.text = myClasses[0]
        }
        
        if !dateWasSelected && dateDidBeginEditing {
            dateField.text = myDays[0]
            realSelectedDate = myDates[0]
        }
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForPickerView))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        classField.inputAccessoryView = toolBar
        dateField.inputAccessoryView = toolBar
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == classField {
            currentField = 1
            pickerView.selectRow(lastRowForClass, inComponent: 0, animated: true)
            classDidBeginEditing = true
        } else {
            currentField = 2
            pickerView.selectRow(lastRowForDate, inComponent: 0, animated: true)
            dateDidBeginEditing = true
        }
        
        pickerView.reloadAllComponents()
        return true
        
    }
    
    // MARK: - TextView Placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descField.textColor == UIColor.lightGray {
            descField.text = ""
            descField.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descField.text.isEmpty {
            textViewPlaceholder()
        }
    }
    
    func textViewPlaceholder() {
        descField.text = "Add a description!"
        descField.textColor = UIColor.lightGray
    }
    
}

// MARK: - PickerView Extension

extension NewAssignmentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentField == 1 {
            return myClasses.count
        } else {
            return myDays.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentField == 1 {
            return myClasses[row]
        } else {
            return myDays[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if currentField == 1 {
            lastRowForClass = pickerView.selectedRow(inComponent: 0)
            classField.text = myClasses[lastRowForClass]
            classWasSelected = true
        } else {
            lastRowForDate = pickerView.selectedRow(inComponent: 0)
            dateField.text = myDays[lastRowForDate]
            realSelectedDate = myDates[lastRowForDate]
            dateWasSelected = true
        }
    }
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayAlert(alertTitle: String, alertMessage: String, actionTitle: String) {
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}
