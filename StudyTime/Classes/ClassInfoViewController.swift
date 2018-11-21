//
//  ClassInfoViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/28/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class ClassInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var teacherField: UITextField!
    @IBOutlet weak var colorField: UITextField!
    @IBOutlet weak var notesView: UITextView!
    
    var fieldWasSelected = false
    var fieldDidBeginEditing = false
    var currentClass : ClassEntity?
    let pickerView = UIPickerView()
    var previousVC = ClassHomeworkTableViewController()
    var assignmentsTableVC = AssignmentsTableViewController()
    var selectedColor : String?
    var nameIsAvailable = true
    let colors = ["Red",
                  "Light green",
                  "Dark green",
                  "Light blue",
                  "Dark blue",
                  "Purple",
                  "Yellow",
                  "Grey",
                  "Brown",
                  "Orange"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFields()
        self.hideKeyboardWhenScreenIsTapped()
        pickerView.delegate = self
        colorField.inputView = pickerView
        colorField.delegate = self
        notesView.delegate = self
        createToolBar()
        if notesView.text == "" {
            textViewPlaceholder()
        }
        nameField.isUserInteractionEnabled = false
    }
    
    // MARK: - Buttons
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if notesView.textColor == UIColor.lightGray {
            notesView.text = ""
        }
        
        if teacherField.text != "" && colorField.text != "Pick a color" {
            addClass()
        } else {
            displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
        }
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
            
        }
    }
    
    // MARK: - Setup functions
    
    func addClass() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                if let entityClasses = try context.fetch(ClassEntity.fetchRequest()) as? [ClassEntity] {
                    if entityClasses.count > 0 {
                        for i in 0...entityClasses.count-1 {
                            if entityClasses[i].name == currentClass?.name {
                                if entityClasses[i].name != nameField.text {
                                    entityClasses[i].name = nameField.text
                                }
                                if entityClasses[i].teacher != teacherField.text {
                                    entityClasses[i].teacher = teacherField.text
                                }
                                if colorField.text != getColorFromRGB(red: entityClasses[i].red, green: entityClasses[i].green, blue: entityClasses[i].blue) {
                                    if let unwrappedColor = colorField.text {
                                        let myColors : [Double] = chooseColor(color: unwrappedColor)
                                        entityClasses[i].red = myColors[0]
                                        entityClasses[i].green = myColors[1]
                                        entityClasses[i].blue = myColors[2]
                                    }
                                }
                                if entityClasses[i].notes != notesView.text {
                                    entityClasses[i].notes = notesView.text
                                }
                            }
                        }
                    }
                    try? context.save()
                    navigationController?.popViewController(animated: true)
                } else {
                    displayAlert(alertTitle: "Fields missing", alertMessage: "You haven't filled all the fields required.", actionTitle: "OK")
                }
            } catch {
                
            }
        }
    }
    
    func setUpFields() {
        if let unwrappedName = currentClass?.name {
            if let unwrappedTeacher = currentClass?.teacher {
                if let unwrappedNotes = currentClass?.notes {
                    if let unwrappedRed = currentClass?.red {
                        if let unwrappedGreen = currentClass?.green {
                            if let unwrappedBlue = currentClass?.blue {
                                colorField.text = getColorFromRGB(red: unwrappedRed, green: unwrappedGreen, blue: unwrappedBlue)
                                nameField.text = unwrappedName
                                teacherField.text = unwrappedTeacher
                                notesView.text = unwrappedNotes
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getColorFromRGB(red: Double, green: Double, blue: Double) -> String {
        var colorName = ""
        switch(red, green, blue) {
        case(1.0, 0.0, 0.0):
            colorName = "Red"
        case(Double(128/255), 1.0, 0.0):
            colorName = "Light green"
        case(Double(76/255), 0.6, 0.0):
            colorName = "Dark green"
        case(0, 1.0, 1.0):
            colorName = "Light blue"
        case(0.2, 0.2, 1.0):
            colorName = "Dark blue"
        case(0.4, 0.0, 0.8):
            colorName = "Purple"
        case(1.0, 1.0, 0.0):
            colorName = "Yellow"
        case(Double(160.0/255.0), Double(160.0/255.0), Double(160.0/255.0)):
            colorName = "Grey"
        case(0.4, 0.2, 0.0):
            colorName = "Brown"
        case(1.0, Double(128.0/255.0), 0.0):
            colorName = "Orange"
        default:
            colorName = "White"
        }
        return colorName
    }
    
    func chooseColor(color: String) -> [Double] {
        var colorArray = [1.0, 1.0, 1.0]
        switch(color) {
        case "Red":
            colorArray = [1, 0, 0]
        case "Light green":
            colorArray = [Double(128/255), 1.0, 0.0]
        case "Dark green":
            colorArray = [Double(76/255), 0.6, 0.0]
        case "Light blue":
            colorArray = [0, 1.0, 1.0]
        case "Dark blue":
            colorArray = [0.2, 0.2, 1.0]
        case "Purple":
            colorArray = [0.4, 0.0, 0.8]
        case "Yellow":
            colorArray = [1.0, 1.0, 0.0]
        case "Grey":
            colorArray = [Double(160.0/255.0), Double(160.0/255.0), Double(160.0/255.0)]
        case "Brown":
            colorArray = [0.4, 0.2, 0.0]
        case "Orange":
            colorArray = [1.0, Double(128.0/255.0), 0.0]
        default:
            colorArray = [1.0, 1.0, 1.0]
        }
        return colorArray
    }
    
    // MARK: - Picker view
    
    @objc func dismissKeyboardForPickerView() {
        view.endEditing(true)
        
        if !fieldWasSelected && fieldDidBeginEditing {
            colorField.text = colors[0]
        }
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForPickerView))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        colorField.inputAccessoryView = toolBar
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.autocapitalizationType = .sentences
        fieldDidBeginEditing = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: - Text view Placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notesView.textColor == UIColor.lightGray {
            notesView.text = ""
            notesView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notesView.text.isEmpty {
            textViewPlaceholder()
        }
    }
    
    func textViewPlaceholder() {
        notesView.text = "Add some notes!"
        notesView.textColor = UIColor.lightGray
    }
    
}

// MARK: - Picker view extension

extension ClassInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorField.text = colors[row]
        fieldWasSelected = true
    }
    
}
