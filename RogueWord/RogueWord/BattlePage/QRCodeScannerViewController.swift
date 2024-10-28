//
//  QRCodeScannerViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/13.
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate: AnyObject {
    func didScanQRCode(with roomID: String)
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    weak var delegate: QRCodeScannerDelegate?

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showScanningNotSupportedAlert()
            return
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            showScanningNotSupportedAlert()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showScanningNotSupportedAlert()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showScanningNotSupportedAlert()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func showScanningNotSupportedAlert() {
        let alert = UIAlertController(title: "無法掃描", message: "你的裝置是不配此類型。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
        captureSession = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let scannedRoomID = metadataObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanQRCode(with: scannedRoomID)
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "掃描錯誤", message: "無法讀取", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true)
        }
    }
}
