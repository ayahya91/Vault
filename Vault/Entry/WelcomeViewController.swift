//
//  ViewController.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/8/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import UIKit
import MobileCoreServices                   // For Camera Service

@available(iOS 11.0, *)
class WelcomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var appDelegate: AppDelegate!
    var navigation_controller: UINavigationController!
    
    var titleLabel: UILabel!
    var loginButton: UIButton!
    var signUpButton: UIButton!
    var imagePickerView: UIView!
    
    
    // TEMP VARIABLES
    var firstFace: Face!
    var secondFace: Face!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        self.setupAppDelegate_NavController()
        self.initialize()
        
        self.titleLabel.fadeInAnimate(animationDistance: 0.0, duration: 0.75, delay: 0.3, completion: {
            self.loginButton.fadeInAnimate(animationDistance: 0.0, duration: 0.5, delay: 0.2, completion: {
                self.signUpButton.fadeInAnimate(animationDistance: 0.0, duration: 0.3, delay: 0.0, completion: {})
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @available(iOS 11.0, *)
    func setupAppDelegate_NavController() -> Void {
        self.title = ""
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigation_controller = appDelegate.nav_controller
        self.navigation_controller.setNavigationBarHidden(true, animated: true)
    }

    func initialize() {
        
        // Title Label
        let titleLabelText = " Vault "
        //let textRange = NSMakeRange(0, titleLabelText.characters.count)
        let attributedText = NSMutableAttributedString(string: titleLabelText)
        //attributedText.addAttribute(UIFontDescriptorNameAttribute, value: UIFontDescriptorSymbolicTraits.traitItalic, range: textRange)
        //attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleThick.rawValue, range: textRange)
        
        self.titleLabel = UILabel(frame: CGRect(x: 0,y: 0,width: Int(self.view.frame.width*0.75),height: Int(self.view.frame.height*0.33)))
        self.titleLabel.center = CGPoint(x: 0, y: 0)
        self.titleLabel.attributedText = attributedText
        self.titleLabel.textColor = UIColor.darkGray //UIColor.black
        self.titleLabel.backgroundColor = self.view.backgroundColor! //UIColor.white //UIColor(red: (59/255), green: (59/255), blue: (59/255), alpha: 1.0)
        //self.titleLabel.layer.borderWidth = 4.0
        //self.titleLabel.layer.borderColor = UIColor.black.cgColor
        self.titleLabel.font = UIFont(name: "CopperPlate", size: 150)
        self.titleLabel.textAlignment = NSTextAlignment.left
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.alpha = 0.0
        
        let loginImage = UIImage(named: "fingerPrint")?.ResizeImage(targetSize: CGSize(width: 30.0, height: 30.0))
        
        self.loginButton = UIButton()
        self.loginButton.backgroundColor = UIColor.white
        self.loginButton.setTitle(" Login ", for: UIControlState())
        self.loginButton.setTitleColor(UIColor.black, for: UIControlState())
        self.loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.loginButton.layer.borderColor = UIColor.black.cgColor
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.addTarget(self, action: #selector(loginButtonPressed(_:)), for: .touchUpInside)
        self.loginButton.showsTouchWhenHighlighted = true
        self.loginButton.layer.cornerRadius = 15.0
        self.loginButton.layer.masksToBounds = true
        self.loginButton.setImage(loginImage!, for: UIControlState())
        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
        self.loginButton.alpha = 0.0
        
        self.signUpButton = UIButton()
        self.signUpButton.backgroundColor = UIColor.black
        self.signUpButton.setTitle("New User", for: UIControlState())
        self.signUpButton.setTitleColor(UIColor.white, for: UIControlState())
        self.signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.signUpButton.layer.borderColor = UIColor.white.cgColor
        self.signUpButton.layer.borderWidth = 1.0
        self.signUpButton.addTarget(self, action: #selector(signUpButtonPressed(_:)), for: .touchUpInside)
        self.signUpButton.showsTouchWhenHighlighted = true
        self.signUpButton.layer.cornerRadius = 15.0
        self.signUpButton.layer.masksToBounds = true
        self.signUpButton.translatesAutoresizingMaskIntoConstraints = false
        self.signUpButton.alpha = 0.0
        
        self.appDelegate.agent.imagePickerController.delegate = self
        self.imagePickerView = self.appDelegate.agent.imagePickerController.view
        self.imagePickerView.alpha = 0.0
        self.imagePickerView.isUserInteractionEnabled = false
        self.imagePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.embedIntoView()
    }
    
    func embedIntoView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.signUpButton)
        self.view.addSubview(self.imagePickerView)
        self.addAutoLayoutConstraint()
    }
    
    func addAutoLayoutConstraint() {
        
        let titleLabelXConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
        
        let titleLabelYConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: self.view.frame.height*0.15)
        
        let titleLabelWConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.95, constant: 0.0)
        
        let loginXConstraint = NSLayoutConstraint(item: self.loginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        let loginYConstraint = NSLayoutConstraint(item: self.loginButton, attribute: .topMargin, relatedBy: .equal, toItem: self.titleLabel, attribute: .bottomMargin, multiplier: 1.0, constant: self.view.frame.height*0.35)
        
        let loginwWConstraint = NSLayoutConstraint(item: self.loginButton, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.75, constant: 0.0)
        
        let loginHConstraint = NSLayoutConstraint(item: self.loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 38.0)
        
        let signUpXConstraint = NSLayoutConstraint(item: self.signUpButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        let signUpYConstraint = NSLayoutConstraint(item: self.signUpButton, attribute: .topMargin, relatedBy: .equal, toItem: self.loginButton, attribute: .bottomMargin, multiplier: 1.0, constant: self.view.frame.height*0.05)
        
        let signUpWConstraint = NSLayoutConstraint(item: self.signUpButton, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.75, constant: 0.0)
        
        let signUpHConstraint = NSLayoutConstraint(item: self.signUpButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 38.0)
        
        let imagePickerViewXConstraint = NSLayoutConstraint(item: self.imagePickerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        let imagePickerViewYConstraint = NSLayoutConstraint(item: self.imagePickerView, attribute: .topMargin, relatedBy: .equal, toItem: self.titleLabel, attribute: .bottomMargin, multiplier: 1.0, constant: self.view.frame.height*0.15)
        
        let imagePickerViewWConstraint = NSLayoutConstraint(item: self.imagePickerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.75, constant: 0.0)
        
        let imagePickerViewHConstraint = NSLayoutConstraint(item: self.imagePickerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.height*0.45)
        
        self.view.addConstraints([titleLabelXConstraint, titleLabelYConstraint, titleLabelWConstraint, loginXConstraint, loginYConstraint, loginwWConstraint, loginHConstraint, signUpXConstraint, signUpYConstraint, signUpWConstraint, signUpHConstraint, imagePickerViewXConstraint, imagePickerViewYConstraint, imagePickerViewWConstraint, imagePickerViewHConstraint])
    }
    
    @objc func loginButtonPressed(_ sender: UIButton) {
        if self.removePopupView() {
            return
        }
        self.appDelegate.agent.authenticateFingerPrint(completionSuccessHandler: {
            DispatchQueue.main.async {
                self.loginButton.isHidden = true
                self.loginButton.isEnabled = false
                self.signUpButton.isHidden = true
                self.signUpButton.isEnabled = false
                
                self.imagePickerView.fadeInAnimate(animationDistance: 0.0, duration: 0.8, delay: 0.4, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                        self.startFacialCapture()
                    })
                })
            }
            
            
        }, completionFailureHandler: { (cancelled) in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.loginButton.isHidden = false
                self.loginButton.isEnabled = true
                self.signUpButton.isHidden = false
                self.signUpButton.isEnabled = true
                
                if !cancelled  {        // An actual failure
                    let av = self.appDelegate.returnCustomAlertView(titleText: "Touch ID Authentication Failed", messageText: "Please Try Again", yesCompletionHandler: {() in
                    })
                    self.present(av, animated: true, completion: nil)
                }
                
            })
        }, unavailableFailure: {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.loginButton.isHidden = false
                self.loginButton.isEnabled = true
                self.signUpButton.isHidden = false
                self.signUpButton.isEnabled = true
                
                let av = self.appDelegate.returnCustomAlertView(titleText: "Touch ID isn't available or enabled", messageText: "If Touch ID is available, please enable it. This app requires Touch ID.")
                self.present(av, animated: true, completion: nil)
            })
        })
    }
    
    @objc func signUpButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async { () -> Void in
            self.navigation_controller.pushViewController(SignUpViewController(), animated: true)
        }
    }
    
    func startFacialCapture() {
        self.appDelegate.agent.startVideoCapture()
        let _ = Timer.scheduledTimer(timeInterval: self.appDelegate.agent.FACE_SCAN_TIME_INTERVAL, target: self, selector: #selector(self.stopFacialCapture(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func stopFacialCapture(_ sender: Timer) {
        self.appDelegate.agent.stopVideoCapture()
    }
    
    func removePopupView() -> Bool {
        if self.appDelegate.agent.popupImageView != nil {
            self.appDelegate.agent.popupImageView.removeFromSuperview()
            self.appDelegate.agent.popupImageView = nil
            return true
        }
        return false
    }
    
    func hideImagePickerView() {
        let _ = self.removePopupView()
        self.imagePickerView.alpha = 0.0
        self.loginButton.isHidden = false
        self.loginButton.isEnabled = true
        self.signUpButton.isHidden = false
        self.signUpButton.isEnabled = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //picker.dismiss(animated: true)
        if self.appDelegate.appResigning { return }
        /*guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("No image found. Re-running Facial Capture")
            self.startFacialCapture()
            return
        }*/
        
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String), let url = info[UIImagePickerControllerMediaURL] as? URL else {
                print("No image found. Re-running Facial Capture")
                self.startFacialCapture()
                return
        }
        self.appDelegate.agent.authenticateFacialRecognition(facialScanVideoURL: url, completionSuccessHandler: {
            if self.appDelegate.agent.faceFound {
                print("Facial Detection: Success")
                //self.hideImagePickerView()
                /* TEMP */
                if self.firstFace == nil {
                    self.firstFace = self.appDelegate.agent.lastProcessedFace
                    let av = self.appDelegate.returnCustomAlertView(titleText: "Face Saved", messageText: "Please Scan Your Face Again For Verification.", yesCompletionHandler: {() in self.startFacialCapture() })
                    self.present(av, animated: true, completion: nil)
                } else if self.secondFace == nil {
                    let _ = self.removePopupView()
                    self.secondFace = self.appDelegate.agent.lastProcessedFace
                    // Compare Faces
                    if self.firstFace.compareToWithAccuracyVariation(self.secondFace) {
                        let av = self.appDelegate.returnCustomAlertView(titleText: "Positive Match!!!", messageText: "")
                        self.present(av, animated: true, completion: nil)
                    } else {
                        let av = self.appDelegate.returnCustomAlertView(titleText: "No Match Found", messageText: "", yesCompletionHandler: {() in
                            self.firstFace = nil
                            self.secondFace = nil
                            self.hideImagePickerView()
                        })
                        self.present(av, animated: true, completion: nil)
                    }
                } else {
                    self.firstFace = nil
                    self.secondFace = nil
                    self.hideImagePickerView()
                }
                /* TEMP */
            } else {
                print("Facial Detection: No Face Detected")
                let av = self.appDelegate.returnCustomAlertView(titleText: "The Camera Isn't Able To Detect A Face", messageText: "Please show your face to login", yesCompletionHandler: {() in self.startFacialCapture() })
                self.present(av, animated: true, completion: nil)
                return
            }
            // Check With Saved Face
        }, completionFailureHandler: {
            print("Facial Detection: Failed")
            self.hideImagePickerView()
        }, unavailableFailure: {
            print("Facial Detection: Unavailable")
            self.hideImagePickerView()
        })
        print("Video Found")
        
        // print out the image size as a test
        //print("Image Size \(image.size)")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}

