//
//  AssignmentInfoViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 11/4/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class AssignmentInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var classField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var descField: UITextView!
    
    let pickerView = UIPickerView()
    private var datePicker : UIDatePicker?
    var currentAssignment : AssignmentEntity?
    var selectedClass : String?
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
        setUpViewWithAssignment()
        self.hideKeyboardWhenScreenIsTapped()
        createDatePicker()
        if descField.textColor == UIColor.lightGray {
            textViewPlaceholder()
        }
        getMyClasses()
        pickerView.delegate = self
        classField.inputView = pickerView
        classField.delegate = self
        descField.delegate = self
        dayField.delegate = self
        descField.isUserInteractionEnabled = true
        createToolBars()
    }
    
    // MARK: - Buttons
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if descField.textColor == UIColor.lightGray {
            descField.text = ""
        }
        
        if nameField.text != "" && dayField.text != "" && classField.text != "Pick a color" {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                do {
                    if let entityAssignments = try context.fetch(AssignmentEntity.fetchRequest()) as? [AssignmentEntity] {
                        nameIsAvailable = true
                        for assignment in entityAssignments {
                            if assignment.name == nameField.text {
                                if currentAssignment?.name != nameField.text {
                                    nameIsAvailable = false
                                }
                            }
                        }
                        if nameIsAvailable {
                            if entityAssignments.count > 0 {
                                for i in 0...entityAssignments.count-1 {
                                    if entityAssignments[i].name == currentAssignment?.name {
                                        if entityAssignments[i].name != nameField.text {
                                            entityAssignments[i].name = nameField.text
                                        }
                                        if entityAssignments[i].rgbClass != classField.text {
                                            entityAssignments[i].rgbClass = classField.text
                                        }
                                        if entityAssignments[i].desc != descField.text {
                                            entityAssignments[i].desc = descField.text
                                        }
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MM/dd/yyyy"
                                        if let unwrappedDay = dayField.text {
                                            if entityAssignments[i].dueDate != dateFormatter.date(from: unwrappedDay) {
                                                entityAssignments[i].dueDate = dateFormatter.date(from: unwrappedDay)
                                            }
                                        }
                                    }
                                }
                            }
                            try? context.save()
                            navigationController?.popViewController(animated: true)
                        } else {
                            displayAlert(alertTitle: "Name is not available", alertMessage: "You've already assigned that name to another assignment. Change it.", actionTitle: "OK")
                        }
                    } else {
                        displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
                    }
                } catch {
                    
                }
            }
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
        
    }
    
    // MARK: - Setup functions
    
    func setUpViewWithAssignment() {
        if let unwrappedAssignment = currentAssignment {
            setUpView(myAssignment: unwrappedAssignment)
        }
    }
    
    func setUpView(myAssignment: AssignmentEntity) {
        classField.text = myAssignment.rgbClass
        descField.text = myAssignment.desc
        nameField.text = myAssignment.name
        if let unwrappedDate = myAssignment.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dayField.text = dateFormatter.string(from: unwrappedDate)
        }
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
    
    // MARK: - Date picker
    
    func createDatePicker() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.timeZone = TimeZone(abbreviation: "CST")
        datePicker?.addTarget(self, action: #selector(NewAssignmentViewController.dateChanged(datePicker:)), for: .valueChanged)
        dayField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dayField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    // MARK: - Picker view
    
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
            if let unwrappedDate = lastDate {
                datePicker?.setDate(unwrappedDate, animated: true)
            }
        }
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
        dayField.inputAccessoryView = toolBar2
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.autocapitalizationType = .sentences
        if textField == classField {
            pickerView.selectRow(lastRowForClass, inComponent: 0, animated: true)
            classDidBeginEditing = true
            pickerView.reloadAllComponents()
        } else if textField == dayField {
            if let unwrappedDate = lastDate {
                datePicker?.setDate(unwrappedDate, animated: true)
            }
            dateDidBeginEditing = true
            datePicker?.reloadInputViews()
        } else {
            
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: - Text view Placeholder
    
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

extension AssignmentInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

