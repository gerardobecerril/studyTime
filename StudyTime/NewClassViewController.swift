//
//  NewClassViewController.swift
//  StudyTime
//
//  Created by Gerardo Becerril on 10/26/18.
//  Copyright © 2018 Gerardo Glz. All rights reserved.
//

import UIKit

class NewClassViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var teacher: UITextField!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var color: UITextField!
    let pickerView = UIPickerView()
    
    var fieldWasSelected = false
    var fieldDidBeginEditing = false
    var previousVC = ClassesTableViewController() 
    var selectedColor : String?
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
        self.hideKeyboardWhenTappedAround()
        name.text = ""
        teacher.text = ""
        textViewPlaceholder()
        color.text = "Pick a color"
        pickerView.delegate = self
        color.inputView = pickerView
        color.delegate = self
        notes.delegate = self
        createToolBar()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if name.text != "" && teacher.text != "" && color.text != "Pick a color" {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                let newClass = ClassEntity(context: context)
                if let unwrappedName = name.text {
                    if let unwrappedNotes = notes.text {
                        if let unwrappedTeacher = teacher.text {
                            if let unwrappedColor = color.text {
                                newClass.name = unwrappedName
                                newClass.notes = unwrappedNotes
                                newClass.teacher = unwrappedTeacher
                                let myColors : [Double] = chooseColor(color: unwrappedColor)
                                newClass.red = myColors[0]
                                newClass.green = myColors[1]
                                newClass.blue = myColors[2]
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
    
    // MARK: - PickerView
    
    @objc func dismissKeyboardForPickerView() {
        view.endEditing(true)
        
        if !fieldWasSelected && fieldDidBeginEditing {
            color.text = colors[0]
        }
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboardForPickerView))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        color.inputAccessoryView = toolBar
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        fieldDidBeginEditing = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: - Textview Placeholder
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if notes.textColor == UIColor.lightGray {
            notes.text = ""
            notes.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notes.text.isEmpty {
            textViewPlaceholder()
        }
    }
    
    func textViewPlaceholder() {
        notes.text = "Add some notes!"
        notes.textColor = UIColor.lightGray
    }

}

extension NewClassViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        color.text = colors[row]
        fieldWasSelected = true
    }
    
}
