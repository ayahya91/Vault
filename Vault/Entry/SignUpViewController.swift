//
//  SignUpViewController.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/21/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    var appDelegate: AppDelegate!
    var navigation_controller: UINavigationController!
    
    var animatedDistance: CGFloat!
    var KEYBOARD_ANIMATION_DURATION: CGFloat = 0.3
    var MINIMUM_SCROLL_FRACTION: CGFloat = 0.2
    var MAXIMUM_SCROLL_FRACTION: CGFloat = 0.8
    var PORTRAIT_KEYBOARD_HEIGHT: CGFloat = 216
    var LANDSCAPE_KEYBOARD_HEIGHT: CGFloat = 162
    
    var faceRecordingURL: URL!
    var tapGestureRecognizier: UITapGestureRecognizer!
    var firstNameTextField: UITextField!
    var lastNameTextField: UITextField!
    var emailTextField: UITextField!
    var dobTextField: UITextField!
    var dobPicker: UIDatePicker!
    var runFacialRecognitionButton: UIButton!
    var mainStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAppDelegate_NavController() -> Void {
        self.title = "Sign Up"
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigation_controller = self.appDelegate.nav_controller
        self.navigation_controller.isNavigationBarHidden = false
        self.navigation_controller.navigationBar.barStyle = UIBarStyle.black
        self.navigation_controller.navigationBar.barTintColor = UIColor.black    //UIColor(red: (59/255), green: (59/255), blue: (59/255), alpha:1.0)
        self.navigation_controller.navigationBar.barStyle = UIBarStyle.black
        //self.navigation_controller.navigationItem.hidesBackButton = true
        self.navigation_controller.navigationBar.backItem?.title = ""
        /*let transparentButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: self.navigation_controller.navigationBar.frame.height))
        transparentButton.backgroundColor = UIColor.clear
        transparentButton.addTarget(self, action: #selector(backButtonPressed), for:.touchUpInside)
        self.navigation_controller.navigationBar.addSubview(transparentButton)*/
        self.navigation_controller.navigationBar.tintColor = UIColor.white
        //self.navigation_controller.navigationBar.tintColor = UIColor.blackColor()
        self.navigation_controller.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Copperplate", size: 24)!]
    }
    
    func initialize() {
        self.tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        self.firstNameTextField = UITextField()
        self.firstNameTextField.delegate = self
        self.firstNameTextField.textAlignment = NSTextAlignment.left
        self.firstNameTextField.layer.borderColor = UIColor.black.cgColor
        self.firstNameTextField.layer.borderWidth = 1.0
        self.firstNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        //self.firstNameTextField.layer.cornerRadius = 10.0
        self.firstNameTextField.backgroundColor = UIColor.white
        //self.firstNameTextField.layer.masksToBounds=true
        self.firstNameTextField.attributedPlaceholder = NSAttributedString(string: " Your First Name", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.firstNameTextField.autocorrectionType = .no
        self.firstNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        
        self.lastNameTextField = UITextField()
        self.lastNameTextField.delegate = self
        self.lastNameTextField.textAlignment = NSTextAlignment.left
        self.lastNameTextField.backgroundColor = UIColor.white
        self.lastNameTextField.layer.borderColor = UIColor.black.cgColor
        self.lastNameTextField.layer.borderWidth = 1.0
        //self.lastNameTextField.layer.cornerRadius = 10.0
        //self.lastNameTextField.layer.masksToBounds = true
        self.lastNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        self.lastNameTextField.attributedPlaceholder = NSAttributedString(string: " Your Last Name", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.lastNameTextField.autocorrectionType = .no
        self.lastNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        self.dobPicker = UIDatePicker()
        self.dobPicker.datePickerMode = UIDatePickerMode.date
        self.dobPicker.backgroundColor = UIColor.white
        //self.dobPicker.layer.borderColor = UIColor.blackColor().CGColor
        //self.dobPicker.layer.borderWidth = 0.5
        //self.dobPicker.layer.cornerRadius = 15.0
        //self.dobPicker.layer.masksToBounds=true
        self.dobPicker.maximumDate = (Calendar.current as NSCalendar).date(byAdding: .year, value: -18, to: Date(), options: [])
        self.dobPicker.addTarget(self, action: #selector(dobDateChanged(_:)), for: UIControlEvents.valueChanged)
        //self.dobPicker.translatesAutoresizingMaskIntoConstraints = false
        
        self.dobTextField = TextField_NoPaste()     //frame: CGRectMake(0,0,self.view.frame.width, 30)
        self.dobTextField.delegate = self
        self.dobTextField.backgroundColor = UIColor.white
        self.dobTextField.attributedPlaceholder = NSAttributedString(string: " Your Date Of Birth", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.dobTextField.layer.borderColor = UIColor.black.cgColor
        self.dobTextField.layer.borderWidth = 1.0
        //self.dobTextField.layer.cornerRadius = 10.0
        //self.dobTextField.layer.masksToBounds=true
        self.dobTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        self.dobTextField.textAlignment = NSTextAlignment.left
        self.dobTextField.inputView = self.dobPicker
        self.dobTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        self.emailTextField = UITextField(frame: CGRect(x: 0,y: 0,width: self.view.frame.width*0.8, height: 35))
        self.emailTextField.delegate = self
        self.emailTextField.textAlignment = NSTextAlignment.left
        self.emailTextField.backgroundColor = UIColor.white
        self.emailTextField.layer.borderColor = UIColor.black.cgColor
        self.emailTextField.layer.borderWidth = 1.0
        //self.emailTextField.layer.cornerRadius = 10.0
        //self.emailTextField.layer.masksToBounds = true
        self.emailTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: " Your Email Address", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.autocorrectionType = .no
        self.emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        self.runFacialRecognitionButton = UIButton()
        self.runFacialRecognitionButton.backgroundColor = UIColor.black.withAlphaComponent(0.85)    //UIColor(red: (59/255), green: (59/255), blue: (59/255), alpha: 1.0)
        self.runFacialRecognitionButton.setTitle("Run Facial Scan", for: UIControlState())
        self.runFacialRecognitionButton.setTitleColor(UIColor.white, for: UIControlState())
        //self.nextButton.layer.borderColor = UIColor.blackColor().CGColor
        //self.nextButton.layer.borderWidth = 2.0
        //self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0, self.view.frame.width*0.2, 0, self.view.frame.width*0.2)
        //self.runFacialRecognitionButton.layer.cornerRadius = 5.0
        //self.runFacialRecognitionButton.layer.masksToBounds = true
        self.runFacialRecognitionButton.addTarget(self, action: #selector(runFacialRecognitionButtonPressed(_:)), for: .touchUpInside)
        
        self.mainStackView = UIStackView(arrangedSubviews: [self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.dobTextField, self.runFacialRecognitionButton])
        self.mainStackView.axis = .vertical
        self.mainStackView.alignment = .fill
        self.mainStackView.distribution = .fillEqually
        self.mainStackView.spacing = 10.0
        self.mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.embedIntoView()
    }
    
    func embedIntoView() {
        self.view.addGestureRecognizer(self.tapGestureRecognizier)
        self.view.addSubview(self.mainStackView)
        self.addAutoLayoutConstraint()
    }
    
    func addAutoLayoutConstraint() {
        let mainSVXConstraint = NSLayoutConstraint(item: self.mainStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        let mainSVYConstraint = NSLayoutConstraint(item: self.mainStackView, attribute: .topMargin, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1.0, constant: 40.0)
        
        let mainSVWConstraint = NSLayoutConstraint(item: self.mainStackView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.85, constant: 0.0)
        
        let mainSVHConstraint = NSLayoutConstraint(item: self.mainStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(self.mainStackView.subviews.count)*45.0)
        
        self.view.addConstraints([mainSVXConstraint, mainSVYConstraint, mainSVWConstraint, mainSVHConstraint])
        
    }
    
    func runFacialRecognitionButtonPressed(_ sender: UIButton) {
        
    }
    
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func updateNextButton() {}
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////     UITEXTFIELD DELEGATE: FUNCTIONS BEGINNING     //////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Embed Phone Number Formatting as Well
        self.updateNextButton()
        if textField == self.firstNameTextField {
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 30
        } else if textField == self.lastNameTextField {
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 30
        } else if textField == self.emailTextField {
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 45
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.blackOpaque
        
        // Setup the buttons to be put in the system.
        //let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePressed) )
        //item.tintColor = UIColor.white
        
        let upItem = UIBarButtonItem(image: UIImage(named: "up")?.ResizeImage(targetSize: CGSize(width: 20, height: 20)), style: .plain, target: self, action: #selector(goUp))
        upItem.tintColor = UIColor.white
        
        let downItem = UIBarButtonItem(image: UIImage(named: "down")?.ResizeImage(targetSize: CGSize(width: 20, height: 20)), style: .plain, target: self, action: #selector(donePressed))
        downItem.tintColor = UIColor.white
        
        let toolbarLabel = UILabel(frame: CGRect.zero)
        if (textField == self.firstNameTextField) {
            toolbarLabel.text = "First Name"
        } else if (textField == self.lastNameTextField) {
            toolbarLabel.text = "Last Name"
        } else if (textField == self.emailTextField) {
            toolbarLabel.text = "Email Address"
        } else if (textField == self.dobTextField) {
            toolbarLabel.text = "Date Of Birth"
        }
        toolbarLabel.backgroundColor = UIColor.clear
        toolbarLabel.textColor = UIColor.white
        toolbarLabel.font = UIFont.systemFont(ofSize: 16.0, weight: 2.0)
        toolbarLabel.textAlignment = .center
        toolbarLabel.sizeToFit()
        let labelItem = UIBarButtonItem.init(customView: toolbarLabel)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:nil, action:nil)
        keyboardDoneButtonView.setItems([upItem,  flexible, downItem,  flexible, labelItem,  flexible,  flexible,  flexible, flexible], animated: false)
        textField.inputAccessoryView = keyboardDoneButtonView
        
        let textFieldRect = self.view.window?.convert(textField.bounds, from: textField)
        let viewRect = self.view.window?.convert(self.view.bounds, from: self.view)
        
        let midline = textFieldRect!.origin.y + 0.5 * textFieldRect!.size.height
        let numerator = midline - viewRect!.origin.y - MINIMUM_SCROLL_FRACTION * viewRect!.size.height
        let denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect!.size.height
        var heightFraction = numerator / denominator
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        
        let orientation = UIApplication.shared.statusBarOrientation
        if (orientation == UIInterfaceOrientation.portrait) || (orientation == UIInterfaceOrientation.portraitUpsideDown) {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(Double(self.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -animatedDistance)
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textFieldRect = self.view.window?.convert(textField.bounds, from: textField)
        let viewRect = self.view.window?.convert(self.view.bounds, from: self.view)
        
        let midline = textFieldRect!.origin.y + 0.5 * textFieldRect!.size.height
        let numerator = midline - viewRect!.origin.y - MINIMUM_SCROLL_FRACTION * viewRect!.size.height
        let denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect!.size.height
        var heightFraction = numerator / denominator
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        
        if animatedDistance == nil {
            let orientation = UIApplication.shared.statusBarOrientation
            if (orientation == UIInterfaceOrientation.portrait) || (orientation == UIInterfaceOrientation.portraitUpsideDown) {
                animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
            } else {
                animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
            }
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(Double(self.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: animatedDistance)
        UIView.commitAnimations()
        textField.text = textField.text?.trim()
        if (textField == self.cardNumTextField) {
            self.getSubmittedVerifiedCardType()
        }
        if (textField == self.expirationDateTextField) {
            self.updateNextButton()
        }
        //self.updateNextButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField == self.firstNameTextField) {
            self.lastNameTextField.becomeFirstResponder()
        } else if (textField == self.lastNameTextField) {
            self.emailTextField.becomeFirstResponder()
        } else if (textField == self.emailTextField) {
            self.dobTextField.becomeFirstResponder()
        }
        return true
    }
    
    func donePressed() {
        if (self.firstNameTextField.isFirstResponder) {
            self.firstNameTextField.resignFirstResponder()
            self.lastNameTextField.becomeFirstResponder()
        } else if (self.lastNameTextField.isFirstResponder) {
            self.lastNameTextField.resignFirstResponder()
            self.emailTextField.becomeFirstResponder()
        } else if (self.emailTextField.isFirstResponder) {
            self.emailTextField.resignFirstResponder()
            self.dobTextField.becomeFirstResponder()
        } else if (self.dobTextField.isFirstResponder) {
            self.dobTextField.resignFirstResponder()
        }
    }
    
    func goUp() {
        if (self.firstNameTextField.isFirstResponder) {
            self.firstNameTextField.resignFirstResponder()
        } else if (self.lastNameTextField.isFirstResponder) {
            self.lastNameTextField.resignFirstResponder()
            self.firstNameTextField.becomeFirstResponder()
        } else if (self.emailTextField.isFirstResponder) {
            self.emailTextField.resignFirstResponder()
            self.lastNameTextField.becomeFirstResponder()
        } else if (self.dobTextField.isFirstResponder) {
            self.dobTextField.resignFirstResponder()
            self.emailTextField.becomeFirstResponder()
        }
    }
    
    func dobDateChanged(_ sender: UIDatePicker) {
        if (sender == self.dobPicker) {
            let date: Date = self.dobPicker.date
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            self.dobTextField.text = dateFormatter.string(from: date)
        }
    }

}
