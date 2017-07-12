//
//  QRScannerViewController.swift
//  QRCodeReader
//
//  Created by TPCG II on 11/07/17.
//  Copyright © 2017 TPCG II. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var qrCodeFrameView: UIView?
    fileprivate var barCodes = [AVMetadataObjectTypeQRCode,
                                AVMetadataObjectTypeUPCECode,
                                AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,
                                AVMetadataObjectTypeCode93Code,
                                AVMetadataObjectTypeCode128Code,
                                AVMetadataObjectTypeEAN8Code,
                                AVMetadataObjectTypeEAN13Code,
                                AVMetadataObjectTypeAztecCode,
                                AVMetadataObjectTypePDF417Code,
                                AVMetadataObjectTypeDataMatrixCode,
                                AVMetadataObjectTypeITF14Code,
                                ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton.layer.cornerRadius = 15

        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
            
            let captureMetadatOP = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadatOP)
            
            captureMetadatOP.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadatOP.metadataObjectTypes = barCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            view.bringSubview(toFront: self.closeButton)
           
            
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        }catch{
            print(error)
            return
        }
        
      
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        //print(metadataObjects)
        
        for metadata in metadataObjects {
            
            for barcodeType in barCodes {
                
                let metaobj = metadata as! AVMetadataMachineReadableCodeObject
                if metaobj.type == barcodeType {
                    let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metaobj)
                    qrCodeFrameView?.frame = barCodeObject!.bounds
                    
                    if metaobj.stringValue != nil {
                        
                        self.showAlert(captureText: metaobj.stringValue)
                        //print(metaobj.stringValue)
                        self.captureSession?.stopRunning()
                    }
                }
            
            }
        }
       
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToHome", sender: self)

    }
    
    func showAlert(captureText : String){
        
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: captureText, preferredStyle: .alert)
        
        let search: UIAlertAction = UIAlertAction(title: "Search", style: .default, handler: { action in
            
            let url = URL(string: "http://www.google.com/#q=\(captureText)")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            self.captureSession?.startRunning()
            self.qrCodeFrameView?.frame = CGRect.zero
        })
        
        
        let ReScan : UIAlertAction = UIAlertAction(title: "cancel", style: .cancel,         handler: { action in
            self.captureSession?.startRunning()
            self.qrCodeFrameView?.frame = CGRect.zero
        })
        
        actionSheet.addAction(search)
        actionSheet.addAction(ReScan)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

}
