//
//  ScanFileViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/18.
//

import UIKit
import VisionKit
import Vision
import SnapKit

class ScanFileViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Scan Document", for: .normal)
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
        scanButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        view.addSubview(scanButton)
        
        scanButton.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
    
    @objc func scanDocument() {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        
        for pageIndex in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: pageIndex)
            recognizeText(from: scannedImage)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        print("Scanning failed with error: \(error.localizedDescription)")
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Text recognition error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    print("Recognized Text: \(topCandidate.string)")
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error.localizedDescription)")
        }
    }
}
