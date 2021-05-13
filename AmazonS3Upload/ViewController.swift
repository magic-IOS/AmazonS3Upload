//
//  ViewController.swift
//  AmazonS3Upload
//
//  Created by Magic-IOS on 12/18/16.
//  Copyright © Magic-IOS. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

class ViewController: UIViewController {

	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

    @IBAction func uploadButtonAction(_ sender: UIButton) {
        uploadButton.isHidden = true
        activityIndicator.startAnimating()
        
        let remoteName = "test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let image = UIImage(named: "test")
        let data = image!.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: fileURL)
        }
        catch {}
        
        let objUploadTask = AWSUploadTaskModel.init(objChat: "" as AnyObject, localPath: fileURL,remotePath: "Temp/")
        objUploadTask.delegate = self
        AWSS3Manager.shared.activeUploads.append(objUploadTask)
        
        if AWSS3Manager.shared.index == 0 {
            AWSS3Manager.shared.sequenceUpload()
        }
        
    }
    
    func uploadImageDefault() {
        
        let S3BucketName = ""
        let remoteName = "test.jpg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
        let image = UIImage(named: "test")
        let data = image!.jpegData(compressionQuality: 1)
        do {
            try data?.write(to: fileURL)
        }
        catch {}
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.body = fileURL
        uploadRequest.key = remoteName
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.acl = .publicRead
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
            DispatchQueue.main.async {
                self?.uploadButton.isHidden = false
                self?.activityIndicator.stopAnimating()
            }
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                }
            }
            
            return nil
        }
        
    }
	
}

extension ViewController : AWSUploadTaskDelegate {
    func progress(progress: Double, objAwsModel: AWSUploadTaskModel) {
        print(progress)
    }
    
    func UploadCompleted(CompletionData: Any?, error: Error?, objAwsModel: AWSUploadTaskModel) {
        print(error)
        print(CompletionData)
    }
}
