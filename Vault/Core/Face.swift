//
//  Face.swift
//  Vault
//
//  Created by Ahmed Yahya on 9/9/18.
//  Copyright © 2018 Ahmed Yahya. All rights reserved.
//

import Foundation
import Vision                               // For Facial Recognition Service

enum RecognitionAccuracy {
    case highest        // 98 %
    case high           // 92 %
    case standard       // 90 %
}

struct Nose {
    var topRight: CGPoint!
    var topLeft: CGPoint!
    var outterRight: CGPoint!
    var outterLeft: CGPoint!
    var crest: CGPoint!
    
    var crestToOutterRight: (distance: CGFloat, angle: CGFloat)!
    var crestToOutterLeft: (distance: CGFloat, angle: CGFloat)!
    var crestToTopRight: (distance: CGFloat, angle: CGFloat)!
    var crestToTopLeft: (distance: CGFloat, angle: CGFloat)!
    var outterRightToTopRight: (distance: CGFloat, angle: CGFloat)!
    var outterLeftToTopLeft: (distance: CGFloat, angle: CGFloat)!

    var topRightToRightEyeInner: (distance: CGFloat, angle: CGFloat)!
    var topLeftToLeftEyeInner: (distance: CGFloat, angle: CGFloat)!
    
    var outterRightToRightEyeOutter: (distance: CGFloat, angle: CGFloat)!
    var outterLeftToLeftEyeOutter: (distance: CGFloat, angle: CGFloat)!
    
    var crestToRightEyeInner: (distance: CGFloat, angle: CGFloat)!
    var crestToLeftEyeInner: (distance: CGFloat, angle: CGFloat)!
}

struct Eye {
    var inner: CGPoint!
    var outter: CGPoint!
    
    var innerToOutter: (distance: CGFloat, angle: CGFloat)!
    var toOtherEye: (distance: CGFloat, angle: CGFloat)!
}

// OBSOLETE
struct Lips {
    var outterRight: CGPoint!
    var outterLeft: CGPoint!
    var bottom: CGPoint!
    
    var leftToRight: CGFloat!
    var leftToBottom: CGFloat!
    var rightToBottom: CGFloat!
    
    var rightToNoseOutterRight: CGFloat!
    var rightToNoseCrest: CGFloat!
    var leftToNoseOutterLeft: CGFloat!
    var leftToNoseCrest: CGFloat!
}

@available(iOS 11.0, *)
class Face: Equatable {
    var observation: VNFaceObservation!
    var faceBiometrics: Dictionary<String,CGFloat>!
    var searchAccuracy: CGFloat!
    
    var noseIdentified: Bool = false
    //var lipsIdentified: Bool = false
    var rightEyeIdentified: Bool = false
    var leftEyeIdentified: Bool = false
    
    var nose: Nose!
    var rightEye: Eye!
    var leftEye: Eye!
    
    //var lips: Lips!
    
    /*
    //var rightEyeBrowIdentified: Bool = false
    //var leftEyeBrowIdentified: Bool = false
    //var eyeBrowRightInner: CGPoint!
    //var eyeBrowRightTop: CGPoint!
    
    //var eyeBrowLeftInner: CGPoint!
    //var eyeBrowLeftTop: CGPoint!
    
    // Confidence = 0.5
    var eyeBrowRightInnerToEyeBrowRightTop: CGFloat!
    var eyeBrowRightInnerToEyeBrowLeftInner: CGFloat!
    var eyeBrowLeftInnerToEyeBrowLeftTop: CGFloat!
    
    // Confidence 0.0
    var rightEyeInnerToEyeBrowRightInner: CGFloat!
    var rightEyeOutterToEyeBrowTop: CGFloat!
    var leftEyeInnerToEyeBrowLeftInner: CGFloat!
    var leftEyeOutterToEyeBrowTop: CGFloat!*/
    
    init(_ face: VNFaceObservation) {
        self.observation = face
        self.initializeFaceBiometricsObject()
        self.scanFace()
        if self.facialFeatureIdentifcation() {
            self.calculateFaceMetrics()
        }
    }
    
    func initializeFaceBiometricsObject() {
        self.faceBiometrics = Dictionary()
        /*self.faceBiometrics["noseTopRightToNoseTopLeft"] = 0.0
        self.faceBiometrics[""] = 0.0
        self.faceBiometrics[""] = 0.0
        self.faceBiometrics[""] = 0.0
        self.faceBiometrics[""] = 0.0
        self.faceBiometrics["rightInnerEyeToLeftInnerEye"] = 0.0
        self.faceBiometrics["rightInnerEyeToNoseCrest"] = 0.0
        self.faceBiometrics["rightInnerEyeToNoseRight"] = 0.0
        self.faceBiometrics["rightInnerEyeToNoseBottom"] = 0.0
        self.faceBiometrics[""] = 0.0*/
    }
    
    func compareToWithAccuracyVariation(_ face: Face) -> Bool {
        if self.compareTo(face, .highest) {
            return true
        } else if self.compareTo(face, .high) {
            return true
        } else if self.compareTo(face, .standard) {
            return true
        }
        return false
    }
    
    func compareTo(_ face: Face, _ accuracy: RecognitionAccuracy) -> Bool {
        self.searchAccuracy = 90.0            // Default to Standard
        if accuracy == .highest {
            self.searchAccuracy = 98.0
        } else if accuracy == .high {
            self.searchAccuracy = 92.0
        }
        print("Analyzing Face With \(self.searchAccuracy!)% Accuracy...")
        
        var results: [Bool] = [
            /*self.compareDifferenceWithAccuracy(value1: self.nose.crestToOutterRight.distance, value2: face.nose.crestToOutterRight.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToOutterLeft.distance, value2: face.nose.crestToOutterLeft.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToTopRight.distance, value2: face.nose.crestToTopRight.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToTopLeft.distance, value2: face.nose.crestToTopLeft.distance, accuracy: self.searchAccuracy),*/
            self.compareDifferenceWithAccuracy(value1: self.nose.outterRightToTopRight.distance, value2: face.nose.outterRightToTopRight.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.outterLeftToTopLeft.distance, value2: face.nose.outterLeftToTopLeft.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.topRightToRightEyeInner.distance, value2: face.nose.topRightToRightEyeInner.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.topLeftToLeftEyeInner.distance, value2: face.nose.topLeftToLeftEyeInner.distance, accuracy: self.searchAccuracy),/*
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToRightEyeInner.distance, value2: face.nose.crestToRightEyeInner.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToLeftEyeInner.distance, value2: face.nose.crestToLeftEyeInner.distance, accuracy: self.searchAccuracy),*/
            self.compareDifferenceWithAccuracy(value1: self.rightEye.innerToOutter.distance, value2: face.rightEye.innerToOutter.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.rightEye.toOtherEye.distance, value2: face.rightEye.toOtherEye.distance, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.leftEye.innerToOutter.distance, value2: face.leftEye.innerToOutter.distance, accuracy: self.searchAccuracy),/*
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToOutterRight.angle, value2: face.nose.crestToOutterRight.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToOutterLeft.angle, value2: face.nose.crestToOutterLeft.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToTopRight.angle, value2: face.nose.crestToTopRight.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToTopLeft.angle, value2: face.nose.crestToTopLeft.angle, accuracy: self.searchAccuracy),*/
            self.compareDifferenceWithAccuracy(value1: self.nose.outterRightToTopRight.angle, value2: face.nose.outterRightToTopRight.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.outterLeftToTopLeft.angle, value2: face.nose.outterLeftToTopLeft.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.topRightToRightEyeInner.angle, value2: face.nose.topRightToRightEyeInner.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.topLeftToLeftEyeInner.angle, value2: face.nose.topLeftToLeftEyeInner.angle, accuracy: self.searchAccuracy),/*
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToRightEyeInner.angle, value2: face.nose.crestToRightEyeInner.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.nose.crestToLeftEyeInner.angle, value2: face.nose.crestToLeftEyeInner.angle, accuracy: self.searchAccuracy),*/
            self.compareDifferenceWithAccuracy(value1: self.rightEye.innerToOutter.angle, value2: face.rightEye.innerToOutter.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.rightEye.toOtherEye.angle, value2: face.rightEye.toOtherEye.angle, accuracy: self.searchAccuracy),
            self.compareDifferenceWithAccuracy(value1: self.leftEye.innerToOutter.angle, value2: face.leftEye.innerToOutter.angle, accuracy: self.searchAccuracy)]
        
        let resultsAccuracy = CGFloat( ( (results.filter{$0 == true}.count) / results.count))
        if resultsAccuracy > self.searchAccuracy {
            print("Facial Recognition: Positive Match With \(self.searchAccuracy!)% Accuracy!")
            return true     // Positive Match
        }
        print("Facial Recognition: No Match With \(self.searchAccuracy!)% Accuracy")

        return false
    }
    
    func compareDifferenceWithAccuracy(value1: CGFloat, value2: CGFloat, accuracy: CGFloat) -> Bool {
        let upperRangeAccuracy = 100.0 + (100.0 - accuracy)
        let lowestAcceptableValue = value1 * (accuracy / 100.0)
        let highestAcceptableValue = value1 * (upperRangeAccuracy / 100.0)
        if value2 > lowestAcceptableValue && value2 < highestAcceptableValue {
            return true
        }
        return false
    }
    
    func scanFace() {
        self.scanNose()
        self.scanEyes()
        //self.scanLips()
        //self.scanEyeBrows()
    }
    
    func scanNose() {
        if let landmark = self.observation.landmarks?.nose {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Nose"); return }
            var landmarkXCoordinates = [CGFloat]()
            var landmarkYCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
                landmarkYCoordinates.append(point.y)
            }
            
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            
            self.nose = Nose()
            self.nose.topLeft = landmark.normalizedPoints.first!
            self.nose.topRight = landmark.normalizedPoints.last!
            self.nose.outterLeft = landmark.normalizedPoints[maxX]
            self.nose.outterRight = landmark.normalizedPoints[minX]
            
            print("Nose Top Left Identified! - \(self.nose.topLeft)")
            print("Nose Top Right Identified! - \(self.nose.topRight)")
            print("Nose Outter Left Identified! - \(self.nose.outterLeft)")
            print("Nose Outter Right Identified! - \(self.nose.outterRight)")
            self.noseIdentified = true
        }
        
        if let landmark = self.observation.landmarks?.noseCrest {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Nose Crest"); return }
            var landmarkXCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
            }
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            
            if landmark.normalizedPoints.first!.x > landmarkXCoordinates[minX] {
                self.nose.crest = landmark.normalizedPoints[minX]
            } else {
                self.nose.crest = landmark.normalizedPoints[maxX]
            }
        }
    }
    
    func scanEyes() {
        self.identifyRightEyePOI()
        self.identifyLeftEyePOI()
    }
    
    func identifyRightEyePOI() {
        if let landmark = self.observation.landmarks?.rightEye {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Right Eye"); return }
            var landmarkXCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
            }
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            
            self.rightEye = Eye()
            self.rightEye.outter = landmark.normalizedPoints[minX]
            print("Right Eye Outter Identified! - \(self.rightEye.outter!)")
            self.rightEye.inner = landmark.normalizedPoints[maxX]
            print("Right Eye Inner Identified! - \(self.rightEye.inner!)")
            self.rightEyeIdentified = true
        }
    }
    
    func identifyLeftEyePOI() {
        if let landmark = self.observation.landmarks?.leftEye {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Left Eye"); return }
            var landmarkXCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
            }
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            
            self.leftEye = Eye()
            self.leftEye.inner = landmark.normalizedPoints[minX]
            print("Left Eye Inner Identified! - \(self.leftEye.inner!)")
            self.leftEye.outter = landmark.normalizedPoints[maxX]
            print("Left Eye Outter Identified! - \(self.leftEye.outter!)")
            self.leftEyeIdentified = true
        }
    }
    
    /*func scanLips() {
        if let landmark = self.observation.landmarks?.outerLips {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Lips"); return }
            var landmarkXCoordinates = [CGFloat]()
            var landmarkYCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
                landmarkYCoordinates.append(point.y)
            }
            
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            //let minY = landmarkYCoordinates.index(of: landmarkYCoordinates.max()!)!
            let minY = landmarkYCoordinates.index(of: landmarkYCoordinates.min()!)!
            
            self.lips = Lips()
            self.lips.outterLeft = landmark.normalizedPoints[minX]
            print("Lip - Left Edge Identified! - \(self.lips.outterLeft!)")
            self.lips.outterRight = landmark.normalizedPoints[maxX]
            print("Lip - Right Edge Identified! - \(self.lips.outterRight!)")
            self.lips.bottom = landmark.normalizedPoints[minY]
            print("Lip - Bottom Identified! - \(self.lips.bottom!)")
            self.lipsIdentified = true
        }
    }*/
    
    /*func scanEyeBrows() {
        self.identifyRightEyeBrowPOI()
        self.identifyLeftEyeBrowPOI()
    }
    
    func identifyRightEyeBrowPOI() {
        if let landmark = self.observation.landmarks?.rightEyebrow {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Right Eye Brow"); return }
            var landmarkXCoordinates = [CGFloat]()
            var landmarkYCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
                landmarkYCoordinates.append(point.y)
            }
            let minX = landmarkXCoordinates.index(of: landmarkXCoordinates.min()!)!
            let maxY = landmarkYCoordinates.index(of: landmarkYCoordinates.max()!)!
            
            self.eyeBrowRightInner = landmark.normalizedPoints[minX]
            print("Right Eyebrow Inner Identified! - \(self.eyeBrowRightInner!)")
            self.eyeBrowRightTop = landmark.normalizedPoints[maxY]
            print("Right Eyebrow Top Identified! - \(self.eyeBrowRightTop!)")
            self.rightEyeBrowIdentified = true
        }
    }
    
    func identifyLeftEyeBrowPOI() {
        if let landmark = self.observation.landmarks?.leftEyebrow {
            if landmark.normalizedPoints.count == 0 { print("No Points Found For Left Eye Brow"); return }
            var landmarkXCoordinates = [CGFloat]()
            var landmarkYCoordinates = [CGFloat]()
            for i in 0...landmark.pointCount - 1 { // last point is 0,0
                let point = landmark.normalizedPoints[i]
                landmarkXCoordinates.append(point.x)
                landmarkYCoordinates.append(point.y)
            }
            let maxX = landmarkXCoordinates.index(of: landmarkXCoordinates.max()!)!
            let maxY = landmarkYCoordinates.index(of: landmarkYCoordinates.max()!)!
            
            self.eyeBrowLeftInner = landmark.normalizedPoints[maxX]
            print("Left Eyebrow Inner Identified! - \(self.eyeBrowLeftInner!)")
            self.eyeBrowLeftTop = landmark.normalizedPoints[maxY]
            print("Left Eyebrow Top Identified! - \(self.eyeBrowLeftTop!)")
            self.leftEyeBrowIdentified = true
        }
    }*/
    
    func facialFeatureIdentifcation() -> Bool {
        if self.noseIdentified && self.rightEyeIdentified && self.leftEyeIdentified {           //&& self.lipsIdentified
            return true
        }
        return false
    }
    
    func calculateFaceMetrics() {
        self.calculateNoseMetrics()
        self.calculateEyeMetrics()
        self.calculateNoseEyesMetrics()
        //self.calculateLipMetrics()
        //self.calculateNoseLipsMetrics()
    }
    
    func calculateNoseMetrics() {
        self.nose.crestToOutterRight = self.nose.crest.distanceAndAngle(toPoint:self.nose.outterRight)
        self.nose.crestToOutterLeft = self.nose.crest.distanceAndAngle(toPoint:self.nose.outterLeft)
        self.nose.crestToTopRight = self.nose.crest.distanceAndAngle(toPoint:self.nose.topRight)
        self.nose.crestToTopLeft = self.nose.crest.distanceAndAngle(toPoint:self.nose.topLeft)
        
        self.nose.outterRightToTopRight = self.nose.outterRight.distanceAndAngle(toPoint:self.nose.topRight)
        self.nose.outterLeftToTopLeft = self.nose.outterLeft.distanceAndAngle(toPoint:self.nose.topLeft)
        
        print("Nose Crest To Nose Outter Right \(self.nose.crestToOutterRight!)")
        print("Nose Crest To Nose Outter Left \(self.nose.crestToOutterLeft!)")
        print("Nose Crest To Nose Top Right \(self.nose.crestToTopRight!)")
        print("Nose Crest To Nose Top Left \(self.nose.crestToTopLeft!)")
        print("Nose Outter Right To Nose Top Right \(self.nose.outterRightToTopRight!)")
        print("Nose Outter Left To Nose Top Left \(self.nose.outterLeftToTopLeft!)")
    }
    
    func calculateEyeMetrics() {
        self.rightEye.innerToOutter = self.rightEye.inner.distanceAndAngle(toPoint:self.rightEye.outter)
        self.leftEye.innerToOutter = self.leftEye.inner.distanceAndAngle(toPoint:self.leftEye.outter)
        self.rightEye.toOtherEye = self.rightEye.inner.distanceAndAngle(toPoint:self.leftEye.inner)
        self.leftEye.toOtherEye = self.rightEye.toOtherEye
        
        print("Right Eye Inner To Outter \(self.rightEye.innerToOutter!)")
        print("Left Eye Inner To Outter \(self.leftEye.innerToOutter!)")
        print("Right Eye Inner To Left Eye Inner \(self.rightEye.toOtherEye!)")
    }
    
    func calculateNoseEyesMetrics() {
        self.nose.topRightToRightEyeInner = self.nose.topRight.distanceAndAngle(toPoint:self.rightEye.inner)
        self.nose.topLeftToLeftEyeInner = self.nose.topLeft.distanceAndAngle(toPoint:self.leftEye.inner)
        self.nose.crestToRightEyeInner = self.nose.crest.distanceAndAngle(toPoint:self.rightEye.inner)
        self.nose.crestToLeftEyeInner = self.nose.crest.distanceAndAngle(toPoint:self.leftEye.inner)
        
        self.nose.outterRightToRightEyeOutter = self.nose.topRight.distanceAndAngle(toPoint:self.rightEye.outter)
        self.nose.outterLeftToLeftEyeOutter = self.nose.topRight.distanceAndAngle(toPoint:self.leftEye.outter)
        
        print("Nose Top Right To Right Eye Inner \(self.nose.topRightToRightEyeInner!)")
        print("Nose Top Left To Left Eye Inner \(self.nose.topLeftToLeftEyeInner!)")
    }
    
    /*func calculateLipMetrics() {
     self.lips.leftToRight = self.lips.outterLeft.distance(toPoint: self.lips.outterRight)
     self.lips.leftToBottom = self.lips.outterLeft.distance(toPoint: self.lips.bottom)
     self.lips.rightToBottom = self.lips.outterRight.distance(toPoint: self.lips.bottom)
     
     print("Lips Left To Right \(self.lips.leftToRight!)")
     print("Lips Left To Bottom \(self.lips.leftToBottom!)")
     print("Lips Right To Bottom \(self.lips.rightToBottom!)")
     }*/
    
    /*func calculateNoseLipsMetrics() {
        self.nose.crestToLipRight = self.nose.crest.distance(toPoint: self.lips.outterRight)
        self.nose.crestToLipLeft = self.nose.crest.distance(toPoint: self.lips.outterLeft)
        self.nose.outterRightToLipRight = self.nose.outterRight.distance(toPoint: self.lips.outterRight)
        self.nose.outterLeftToLipLeft = self.nose.outterLeft.distance(toPoint: self.lips.outterLeft)
        
        self.lips.rightToNoseOutterRight = self.nose.outterRightToLipRight
        self.lips.rightToNoseCrest = self.nose.crestToLipRight
        self.lips.leftToNoseOutterLeft = self.nose.outterLeftToLipLeft
        self.lips.leftToNoseCrest = self.nose.crestToLipLeft
        
        print("Nose Crest To Lip Outter Right \(self.nose.crestToLipRight!)")
        print("Nose Crest To Lip Outter Left \(self.nose.crestToLipLeft!)")
        print("Nose Outter Right To Lip Right \(self.nose.outterRightToLipRight!)")
        print("Nose Outter Left To Lip Left \(self.nose.outterLeftToLipLeft!)")
    }*/
    
    static func ==(firstFace: Face, secondFace: Face) -> Bool {
        return false
    }
}

extension CGPoint {
    
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow(x - p.x, 2) + pow(y - p.y, 2))
    }
    
    func shortestAngle(toPoint p:CGPoint) -> CGFloat {
        let deltaX = p.x - x
        let deltaY = p.y - y
        let radians  = atan2(deltaY, deltaX)
        var angleInDegrees = (radians * (180.0 / CGFloat.pi))
        if angleInDegrees < 0.0 {
            angleInDegrees = angleInDegrees + 360.0
        }
        
        if angleInDegrees > 180.0 {
            angleInDegrees = 360.0 - angleInDegrees
        }
        return (radians * (180.0 / CGFloat.pi))
    }
    
    func distanceAndAngle(toPoint p:CGPoint) -> (distance: CGFloat, angle: CGFloat) {
        let distanceToP = self.distance(toPoint: p)
        let angleToP = self.shortestAngle(toPoint: p)
        return (distanceToP, angleToP)
    }
}
