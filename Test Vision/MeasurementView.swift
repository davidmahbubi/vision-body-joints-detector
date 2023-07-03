//
//  MeasurementView.swift
//  Test Vision
//
//  Created by David Mahbubi on 03/07/23.
//

import SwiftUI
import Vision
import VisionKit

struct MeasurementView: View {
    
    private var image: UIImage?
    @State private var selectedCoordinate: CGPoint?
    @State var widthSize : Double = 0.0
    @State var heightSize : Double = 0.0
    
    init() {
        self.image = UIImage(named: "pose")
    }
    
    var body: some View {
            VStack {
                if let image = image {
                    GeometryReader { geometry in
                        if (selectedCoordinate?.x != nil || selectedCoordinate?.y != nil) {
                                Image(uiImage: image)
                                    .resizable()
                                    .overlay(PointOverlay(imageWidth: widthSize, imageHeight: heightSize, coordinate: selectedCoordinate!))
                                    .onAppear {
                                        widthSize = geometry.size.width
                                        heightSize = geometry.size.height
                                    }
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                    }.border(.green)
                }
                Button("Detect Joints") {
                    detectJoints()
                }
            }
    }
    
    private func detectJoints() {
        guard let image = image, let ciImage = CIImage(image: image) else {
            return
        }
        
        let request = VNDetectHumanBodyPoseRequest { request, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let results = request.results as? [VNHumanBodyPoseObservation] {
                // Process the detected joints
                for result in results {
                    
                    guard let recognizedPoints = try? result.recognizedPoints(forGroupKey: .all) else {
                        continue
                    }
                    
                    for (jointName, point) in recognizedPoints {
                        let joint = jointName
                        let coordinate = point.location
//                        print("Joint \(joint): \(coordinate.x), \(coordinate.y)")
//                        print(jointName.rawValue)
//                        print("x : \(coordinate.x) ||")
                        if (jointName.rawValue == "left_shoulder_1_joint") {
                            selectedCoordinate = coordinate
//                            print("\(jointName.rawValue) : x : \(coordinate.x) | y : \(coordinate.y)")
                        }
//                        selectedCoordinate = coordinate
                    }
                }
            } else {
                print("Unable to detect human body pose.")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Error: \(error)")
        }
    }

}

struct PointOverlay: View {
    
    var imageWidth: Double
    var imageHeight : Double
    var coordinate: CGPoint
    
    var body: some View {
        GeometryReader { geometry in
            let x = (1-coordinate.x) * imageWidth
            let y = (1-coordinate.y) * imageHeight
            
            let _ = print("x : \(coordinate.x) || y : \(coordinate.y)")
            let _ = print("g : \(imageHeight), img : \(imageWidth)")
            
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(x: x, y: y)
        }
    }
}

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementView()
    }
}
