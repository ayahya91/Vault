//
//  Agent.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/9/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import UIKit
import MobileCoreServices                   // For Camera Service
import AVFoundation                         // For Camera Service
import LocalAuthentication                  // For FingerPrint Service
import Vision                               // For Facial Recognition Service

@available(iOS 11.0, *)
class Agent: NSObject {
    
    var FACE_SCAN_TIME_INTERVAL: TimeInterval = 2.25
    var appDelegate: AppDelegate!
    var imagePickerController: UIImagePickerController!
    var isImagePickerControllerRecording: Bool = false
    var recordingCircle: UIImageView!
    var currentFaceVideoURL: URL!
    var currentFaceImages: [UIImage]!
    var currentFrame: Int!
    var faceFound: Bool = false
    var lastProcessedFace: Face!
    
    var popupImageView: UIImageView!
    
    override init() {
        super.init()
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.initialize()
    }
    
    func initialize() {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.sourceType = .camera
        self.imagePickerController.mediaTypes = [kUTTypeMovie as String]    //, kUTTypeImage as String
        self.imagePickerController.cameraCaptureMode = .video
        self.imagePickerController.cameraDevice = .front
        self.imagePickerController.cameraFlashMode = .auto
        self.imagePickerController.videoQuality = .typeHigh
        self.imagePickerController.videoMaximumDuration = .infinity
        self.imagePickerController.showsCameraControls = false
        
        self.recordingCircle = UIImageView(image:  self.circle(diameter: 20.0, color: UIColor.red))
        //self.recordingCircle.layer.borderColor = UIColor.black.cgColor
        //self.recordingCircle.layer.borderWidth = 2.0
        //self.recordingCircle.layer.cornerRadius
        self.recordingCircle.translatesAutoresizingMaskIntoConstraints = false
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        AUTHENTICATION FUNCTIONALITY: START         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func authenticateFingerPrint(completionSuccessHandler: @escaping () -> Void, completionFailureHandler: @escaping (_ canceled: Bool) -> Void, unavailableFailure: @escaping () -> Void) {
        let context = LAContext()
        var error: NSError?
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) in
                if success {
                    completionSuccessHandler()
                } else {
                    print("Finger Authentication Error: \(error.debugDescription)")
                    if error != nil {
                        if error.debugDescription.contains("Canceled by user") {
                            completionFailureHandler(true)
                            return
                        }
                    }
                    completionFailureHandler(false)
                    
                }
            })
        } else {
            print("Finger Authentication Unavailable")
            unavailableFailure()
        }
    }
    
    func authenticateFacialRecognition(facialScanVideoURL: URL, completionSuccessHandler: @escaping () -> Void, completionFailureHandler: @escaping () -> Void, unavailableFailure: @escaping () -> Void) {
        self.faceFound = false
        self.currentFaceImages = self.extractImageFromURL(videoURL: facialScanVideoURL)
        if self.currentFaceImages.isEmpty {
            print("Video Frames Non-Existent Or Corrupted")
        }
        //self.popupImageView(self.currentFaceImages.first!)
        self.currentFrame = 0
        for faceImage in self.currentFaceImages {
            var orientation: Int32 = 0
            switch faceImage.imageOrientation {
            case .up:
                orientation = 1
            case .right:
                orientation = 6
            case .down:
                orientation = 3
            case .left:
                orientation = 8
            default:
                orientation = 1
            }
            
            // vision
            if #available(iOS 11.0, *) {
                let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.processFaceFeatures)
                let requestHandler = VNImageRequestHandler(cgImage: faceImage.cgImage!, orientation: CGImagePropertyOrientation(rawValue: UInt32(orientation))! ,options: [:])
                
                do {
                    try requestHandler.perform([faceLandmarksRequest])
                    if self.faceFound {
                        if faceImage == self.currentFaceImages.last! {              // FOR TESTING ONLY
                            self.popupImageView(faceImage, face: self.lastProcessedFace)
                        }
                    } else {
                        print("No Face Found")
                    }
                    if faceImage == self.currentFaceImages.last! { completionSuccessHandler() }
                    
                } catch {
                    print(error)
                    if faceImage == self.currentFaceImages.last! { completionFailureHandler() }
                }
            } else {
                if faceImage == self.currentFaceImages.last! { unavailableFailure() }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func processFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        if observations.isEmpty {
            print("No Face Found")
        }
        
        for observedFace in observations {
            self.faceFound = true
            print("Face Found!")
            self.lastProcessedFace = Face(observedFace)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        AUTHENTICATION FUNCTIONALITY: END         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        VIDEO PROCESSING FUNCTIONALITY: START         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func startVideoCapture() {
        let recording = self.imagePickerController.startVideoCapture()
        print("Is Recording... \(recording)")
        self.isImagePickerControllerRecording = recording
        if recording {
            let recordingXConstraint = NSLayoutConstraint(item: self.recordingCircle, attribute: .centerX, relatedBy: .equal, toItem: self.imagePickerController.view, attribute: .rightMargin, multiplier: 1.0, constant: -20.0)
            
            let recordingYConstraint = NSLayoutConstraint(item: self.recordingCircle, attribute: .centerY, relatedBy: .equal, toItem: self.imagePickerController.view, attribute: .bottomMargin, multiplier: 1.0, constant: -25.0)
            self.imagePickerController.view.addSubview(self.recordingCircle)
            self.imagePickerController.view.addConstraints([recordingXConstraint, recordingYConstraint])
        } else {
            print("Failure To Start Recording")
        }
    }
    
    func stopVideoCapture() {
        self.imagePickerController.stopVideoCapture()
        print("Stopped Video Capture")
        self.isImagePickerControllerRecording = false
        self.recordingCircle.removeFromSuperview()
    }
    
    func extractImageFromURL(videoURL: URL) -> [UIImage] {
        self.currentFaceVideoURL = videoURL
        var timeFrameImages = [UIImage]()
        
        let asset = AVURLAsset(url: self.currentFaceVideoURL)
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        print("Video Duration: \(durationTime)")
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGeneratorApertureMode.encodedPixels
        
        for time in 1...Int(durationTime) {
            let cmTime = CMTime(seconds: Double(time), preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
                timeFrameImages.append(UIImage(cgImage: thumbnailImageRef))
            } catch let error {
                print("Error: \(error)")
            }
        }
        return timeFrameImages
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        VIDEO PROCESSING FUNCTIONALITY: END         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        CRYPTOGRAPHY FUNCTIONALITY: START         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////        CRYPTOGRAPHY FUNCTIONALITY: END         /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    /*@objc func displayNext(_ timer: Timer) {
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame >= self.currentFaceImages.count {
            return
        }
        self.popupImageView(self.currentFaceImages[self.currentFrame])
    }*/
    
    @available(iOS 11.0, *)
    func popupImageView(_ image: UIImage, face: Face? = nil) {
        let modifiedImage: UIImage!
        if face != nil {
            modifiedImage = self.drawLandmarks(image: image, face: face!)
        } else {
            modifiedImage = image
        }
        self.popupImageView = UIImageView(frame: CGRect(x: 50.0, y: 50.0, width: 300.0, height: 300.0))
        self.popupImageView.image = modifiedImage.ResizeImage(targetSize: CGSize(width: 200.0, height: 200.0))
        self.appDelegate.welcomeVC?.view.addSubview(self.popupImageView)
        //let _ = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(displayNext(_:)), userInfo: nil, repeats: false)
    }
    
    @available(iOS 11.0, *)
    func drawLandmarks(image: UIImage, face: Face) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // draw the face rect
        let w = face.observation.boundingBox.size.width * image.size.width
        let h = face.observation.boundingBox.size.height * image.size.height
        let x = face.observation.boundingBox.origin.x * image.size.width
        let y = face.observation.boundingBox.origin.y * image.size.height
        let faceRect = CGRect(x: x, y: y, width: w, height: h)
        context?.saveGState()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(8.0)
        context?.addRect(faceRect)
        context?.drawPath(using: .stroke)
        context?.restoreGState()
        
        let facialPoints: [[CGPoint]] = [[face.nose.crest, face.nose.outterRight], [face.nose.crest, face.nose.outterLeft], [face.nose.crest, face.rightEye.inner], [face.nose.crest, face.leftEye.inner], [face.nose.crest, face.nose.topRight], [face.nose.crest, face.nose.topLeft], [face.rightEye.inner, face.rightEye.outter], [face.rightEye.inner, face.nose.topRight], [face.rightEye.inner, face.leftEye.inner], [face.leftEye.inner, face.leftEye.outter], [face.leftEye.inner, face.nose.topLeft]]
        
        for fp in facialPoints {
            let points = fp
            context?.saveGState()
            context?.setStrokeColor(UIColor.yellow.cgColor)
            for point in points { // last point is 0,0
                if point == points.first! {
                    context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                } else {
                    context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
                }
            }
            context?.setLineWidth(8.0)
            context?.drawPath(using: .stroke)
            context?.saveGState()
        }
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        //if color == UIColor.black {
        let newRect = CGRect(x: 0, y: 0, width: diameter - 2.0, height: diameter - 2.0)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: newRect)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.strokeEllipse(in: rect)
        /*} else {
         ctx.setFillColor(color.cgColor)
         ctx.fillEllipse(in: rect)
         }*/
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}

extension UIViewController {
    /*func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }*/
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UILabel {
    /*func multiColorText(fullText: String, stringColorDict: Dictionary<String, UIColor>) {
        let newText = NSMutableAttributedString(string: fullText)
        for tuple in stringColorDict {
            newText.addAttribute(NSForegroundColorAttributeName, value: tuple.value, range: (fullText as NSString).range(of: tuple.key))
            
        }
        self.attributedText = newText
    }
    
    func boldString(text: String) {
        var mutatedAttrString: NSMutableAttributedString!
        var fullText: String!
        if self.attributedText != nil {
            mutatedAttrString = NSMutableAttributedString(attributedString: self.attributedText!)
            fullText = mutatedAttrString.string
        } else {
            if self.text != nil {
                mutatedAttrString = NSMutableAttributedString(string: self.text!)
                fullText = self.text!
            } else {
                mutatedAttrString = NSMutableAttributedString(string: text)
                fullText = text
            }
        }
        mutatedAttrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 18.0, weight: 1.0), range:  (fullText as NSString).range(of: text))
        self.attributedText = mutatedAttrString
    }*/
}

extension UIView {
    func addShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -2.0, height: 5.0)
        self.layer.shadowOpacity = 0.5
    }
    
    func removeShadow() {
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    func fadeInAnimate(animationDistance: CGFloat, duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping () -> Void ) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.alpha = 1.0
            var viewFrame = self.frame
            viewFrame.origin.y += animationDistance
            self.frame = viewFrame
        }, completion: { finished in
            print("Animation Finished \(finished)")
            completion()
        })
    }
    
    func fadeInAnimateHorizontal(animationDistance: CGFloat, duration: TimeInterval = 0.7, delay: TimeInterval = 0.0, completion: @escaping () -> Void ) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.alpha = 1.0
            var viewFrame = self.frame
            viewFrame.origin.x += animationDistance
            self.frame = viewFrame
        }, completion: { finished in
            print("Animation Finished \(finished)")
            completion()
        })
    }
}

extension String {
    func indexOf(_ string: String) -> String.Index? {
        return range(of: string, options: .literal, range: nil, locale: nil)?.lowerBound
    }
    
    func capitalizeAllLetters() -> String {
        let nss = NSString(string: self)
        let upperCaseVersion = nss.uppercased
        return upperCaseVersion
    }
    
    func decodeToImage() -> UIImage? {
        if self == "" {
            return nil
        }
        let dataDecoded: Data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))! as Data
        return UIImage(data: dataDecoded as Data)!
    }
    
    func base64Encoded() -> Data {
        let plainData = self.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedData(options: .lineLength64Characters)
        return base64String!
    }
    
    func base64Decoded() -> String {
        let decodedData = NSData(base64Encoded: self, options:Data.Base64DecodingOptions(rawValue: 0))
        let decodedString = NSString(data: decodedData as! Data, encoding: String.Encoding.utf8.rawValue)
        return decodedString as! String
    }
    
    func shortenAddress(includeZipCode: Bool = false) -> String {
        var zipCode: String? = nil
        let statesDictionary = ["Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR", "California": "CA", "Colorado": "CO",
                                "Connecticut": "CT", "Delaware": "DE", "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID",
                                "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS", "Kentucky": "KY", "Louisiana": "LA",
                                "Maine": "ME", "Maryland": "MD", "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
                                "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV", "New Hampshire": "NH", "New Jersey": "NJ",
                                "New Mexico": "NM", "New York": "NY", "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK",
                                "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC", "South Dakota": "SD",
                                "Tennessee": "TN", "Texas": "TX", "Utah": "UT", "Vermont": "VT", "Virginia": "VA", "Washington": "WA",
                                "West Virginia": "WV", "Wisconsin": "WI", "Wyoming": "WY"]
        
        var addressArray = self.components(separatedBy: ", ")
        if addressArray.count == 6 {
            zipCode = addressArray[4]
            addressArray = Array(addressArray[0..<3])
        } else if addressArray.count > 6 {
            addressArray = Array(addressArray[0..<4])
        } else if addressArray.count == 5 {
            addressArray = Array(addressArray[0..<3])
        }
        
        for component in addressArray.enumerated() {
            if let stateAbbreviation = statesDictionary[component.element] {
                addressArray[component.offset] = stateAbbreviation
            }
        }
        if zipCode != nil && includeZipCode == true {
            addressArray.append(zipCode!)
        }
        return addressArray.joined(separator: ", ")
    }
    
    func iconAttributedString(icon: UIImage, bounds: CGRect) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = bounds
        let attributedText = NSMutableAttributedString(string: "")
        attributedText.append(NSAttributedString(attachment: attachment))
        attributedText.append(NSMutableAttributedString(string: "\(self)"))
        return attributedText
    }
    
    func trim() -> String {
        var trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if !trimmed.isEmpty {
            if trimmed.last! == "." {
                trimmed = String(trimmed.dropLast())
            }
        }
        return trimmed
    }
}

extension UIImage {
    
    func encode() -> String {
        let imageData = UIImagePNGRepresentation(self)
        return imageData!.base64EncodedString(options: .init(rawValue: 0))
    }
    
    func scaled() -> UIImage {
        let image = self
        let size = image.size.applying(CGAffineTransform(scaleX: 0.10, y: 0.10))
        let hasAlpha = false
        let scale: CGFloat = 0.0
        // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint(x:0,y:0), size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func ResizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension Date {
    func isToday() -> Bool {
        return NSCalendar.current.isDateInToday(self)
    }
    
    func dayOfWeek(abbreviated: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: self)
        if let dayNumberOfWeek = Calendar.current.dateComponents([.weekday], from: self).weekday {
            if dayNumberOfWeek == 1 {
                if abbreviated {
                    return "Sun \(dateString)"
                } else {
                    return "Sunday \(dateString)"
                }
            } else if dayNumberOfWeek == 2 {
                if abbreviated {
                    return "Mon \(dateString)"
                } else {
                    return "Monday \(dateString)"
                }
            } else if dayNumberOfWeek == 3 {
                if abbreviated {
                    return "Tue \(dateString)"
                } else {
                    return "Tuesday \(dateString)"
                }
            } else if dayNumberOfWeek == 4 {
                if abbreviated {
                    return "Wed \(dateString)"
                } else {
                    return "Wednesday \(dateString)"
                }
            } else if dayNumberOfWeek == 5 {
                if abbreviated {
                    return "Thu \(dateString)"
                } else {
                    return "Thursday \(dateString)"
                }
            } else if dayNumberOfWeek == 6 {
                if abbreviated {
                    return "Fri \(dateString)"
                } else {
                    return "Friday \(dateString)"
                }
            } else if dayNumberOfWeek == 7 {
                if abbreviated {
                    return "Sat \(dateString)"
                } else {
                    return "Saturday \(dateString)"
                }
            }
        }
        return dateString
    }
    
    func formattedDaysInThisWeek() -> [String] {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let todayComponent = calendar.components([.day, .month, .year], from: self)
        let thisWeekDateRange = calendar.range(of: .day, in:.weekOfMonth, for: self)
        let dayInterval = thisWeekDateRange.location - todayComponent.day!
        let beginningOfWeek = calendar.date(byAdding: .day, value: dayInterval, to: self, options: .matchNextTime)
        var formattedDays: [String] = []
        
        for i in 0 ..< 7 {
            let date = calendar.date(byAdding: .day, value: i, to: beginningOfWeek!, options: .matchNextTime)!
            formattedDays.append(formatDate(date: date))
        }
        
        return formattedDays
    }
    
    // FINISH
    func formattedDaysInThisMonth() -> [String] {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let todayComponent = calendar.components([.day, .month, .year], from: self)
        let thisMonthDateRange = calendar.range(of: .day, in: .month , for: self)
        let dayInterval = thisMonthDateRange.location - todayComponent.day!
        let beginningOfMonth = calendar.date(byAdding: .day, value: dayInterval, to: self, options: .matchNextTime)
        var formattedDays: [String] = []
        print("Days in the month \(thisMonthDateRange.length)")
        for i in 0 ..< thisMonthDateRange.length {
            let date = calendar.date(byAdding: .day, value: i, to: beginningOfMonth!, options: .matchNextTime)!
            formattedDays.append(formatDate(date: date))
        }
        
        return formattedDays
    }
    
    // FINISH
    func formattedMonthsInThisYear() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let todayComponent = calendar.components([.day, .month, .year], from: self)
        let thisYearDateRange = calendar.range(of: .month, in: .year , for: self)
        let dayInterval = thisYearDateRange.location - todayComponent.month!
        let beginningOfYear = calendar.date(byAdding: .month, value: dayInterval, to: self, options: .matchNextTime)
        var formattedMonths: [String] = []
        
        for i in 0 ..< thisYearDateRange.length {
            let date = calendar.date(byAdding: .month, value: i, to: beginningOfYear!, options: .matchNextTime)!
            formattedMonths.append(formatter.string(from: date))
        }
        return formattedMonths
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE M/d"
        return formatter.string(from: date)
    }
    
    func isFirstOfWeek() -> Bool {
        if let dayNumberOfWeek = Calendar.current.dateComponents([.weekday], from: self).weekday {
            if dayNumberOfWeek == 1 {
                return true
            }
        }
        return false
    }
    
    func isFirstOfMonth() -> Bool {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let todayComponent = calendar.components([.day, .month, .year], from: self)
        let thisMonthDateRange = calendar.range(of: .day, in: .month , for: self)
        let dayInterval = thisMonthDateRange.location - todayComponent.day!
        let beginningOfMonth = calendar.date(byAdding: .day, value: dayInterval, to: self, options: .matchNextTime)
        let beginningOfMonthComponent = calendar.components([.day, .month, .year], from: beginningOfMonth!)
        if todayComponent.day == beginningOfMonthComponent.day {
            return true
        } else {
            return false
        }
    }
    
    func isFirstOfYear() -> Bool {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let todayComponent = calendar.components([.day, .month, .year], from: self)
        let thisYearDateRange = calendar.range(of: .month, in: .year , for: self)
        let dayInterval = thisYearDateRange.location - todayComponent.month!
        let beginningOfYear = calendar.date(byAdding: .month, value: dayInterval, to: self, options: .matchNextTime)
        let beginningOfYearComponent = calendar.components([.day, .month, .year], from: beginningOfYear!)
        if todayComponent.day == beginningOfYearComponent.day {
            return true
        } else {
            return false
        }
    }
}

extension Dictionary
{
    public init(keys: [Key], values: [Value])
    {
        precondition(keys.count == values.count)
        
        self.init()
        
        for (index, key) in keys.enumerated()
        {
            self[key] = values[index]
        }
    }
}

extension Array {
    func sum() -> Double {
        return self.map { $0 as! Double }.reduce(0) { $0 + $1 }
    }
}

extension UINavigationController {
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.portrait
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
}
