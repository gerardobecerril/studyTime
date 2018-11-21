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
    private var datePicker : UIDatePicker?
    var lastRowForClass = 0
    var classWasSelected = false
    var classDidBeginEditing = false
    var dateWasSelected = false
    var dateDidBeginEditing = false
    var lastDate : Date?
    var myClasses : [String] = []
    var nameIsAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenScreenIsTapped()
        createDatePicker()
        getMyClasses()
        textViewPlaceholder()
        titleField.text = ""
        dateField.text = "Due date"
        classField.text = "Class"
        pickerView.delegate = self
        classField.inputView = pickerView
        classField.delegate = self
        descField.delegate = self
        dateField.delegate = self
        createToolBars()
    }
    
    // MARK: - Buttons
    
    @IBAction func doneTapped(_ sender: Any) {
        if descField.textColor == UIColor.lightGray {
            descField.text = ""
        }
        if titleField.text != "" && dateField.text != "Due date" && classField.text != "Class" {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                if let entityAssignments = try? context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                    if let coreDataAssignments = entityAssignments {
                        nameIsAvailable = true
                        for assignment in coreDataAssignments {
                            if assignment.name == titleField.text {
                                nameIsAvailable = false
                            }
                        }
                    }
                }
                if nameIsAvailable {
                    let newAssignment = AssignmentEntity(context: context)
                    if let unwrappedTitleField = titleField.text {
                        if let unwrappedDescField = descField.text {
                            if let unwrappedSelectedDate = dateField.text {
                                if let unwrappedClassName = classField.text {
                                    newAssignment.name = unwrappedTitleField
                                    newAssignment.desc = unwrappedDescField
                                    newAssignment.rgbClass = unwrappedClassName
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MM/dd/yyyy"
                                    newAssignment.dueDate = dateFormatter.date(from: unwrappedSelectedDate)
                                }
                            }
                        }
                    }
                    try? context.save()
                    navigationController?.popViewController(animated: true)
                } else {
                    displayAlert(alertTitle: "Name is not available", alertMessage: "You've already assigned that name to another assignment. Change it.", actionTitle: "OK")
                }
            }
        } else {
            displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
        }
    }
    
    // MARK: - Setup functions
    
    func createDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.timeZone = TimeZone(abbreviation: "CST")
        datePicker?.addTarget(self, action: #selector(NewAssignmentViewController.dateChanged(datePicker:)), for: .valueChanged)
        dateField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateField.text = dateFormatter.string(from: datePicker.date)
    }
    
    func getMyClasses() {
        myClasses = []
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let entityClasses = try? context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                if let coreDataClasses = entityClasses {
                    if coreDataClasses.count > 0 {
                        for i in 0...coreDataClasses.count-1 {
                            if let myClassName = coreDataClasses[i].name {
                                myClasses.append(myClassName)
                            }
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
            if myClasses.count > 0 {
                classField.text = myClasses[0]
            }
        }
    }
    
    @objc func dismissKeyboardForDatePicker() {
        if !dateWasSelected && dateDidBeginEditing {
            if let unwrappedDatePicker = datePicker {
                dateChanged(datePicker: unwrappedDatePicker)
            }
        }
        view.endEditing(true)
    }
    
    func createToolBars() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBar2 = UIToolbar()
        toolBar2.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForPickerView))
        let doneButton2 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForDatePicker))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        classField.inputAccessoryView = toolBar
        
        toolBar2.setItems([doneButton2], animated: true)
        toolBar2.isUserInteractionEnabled = true
        dateField.inputAccessoryView = toolBar2
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.autocapitalizationType = .sentences
        if textField == classField {
            classDidBeginEditing = true
            pickerView.reloadAllComponents()
        } else {
            dateDidBeginEditing = true
            datePicker?.reloadInputViews()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
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

// MARK: - Picker view Extension

extension NewAssignmentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myClasses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myClasses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if classDidBeginEditing {
            lastRowForClass = pickerView.selectedRow(inComponent: 0)
            classField.text = myClasses[lastRowForClass]
            classWasSelected = true
        } else {
            lastDate = datePicker?.date
            dateWasSelected = true
        }
    }
    
}

// MARK: - Other functions

extension UIViewController {
    
    func hideKeyboardWhenScreenIsTapped() {
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
