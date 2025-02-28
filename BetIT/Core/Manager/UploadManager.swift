//
//  UploadManager.swift
//  BetIT
//
//  Created by joseph on 8/26/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation


import Foundation
import FirebaseStorage

class UploadManager {
    static let shared = UploadManager()
    private let storage = Storage.storage()
    private var currentUploadTask: StorageUploadTask?
    
    private init() { }
    private func setup() { }
    
    func configure() {
        setup()
    }
    
    func uploadImage(_ url: URL, usingKey key: String, completionHandler: ((StorageMetadata?, Error?) -> Void)? = nil) {
        let bucketKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard bucketKey.count > 0 else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        uploadImageData(data, usingKey: key, completionHandler: completionHandler)
    }

    func uploadImage(_ image: UIImage, usingKey key: String, completionHandler: ((StorageMetadata?, Error?) -> Void)? = nil) {
        // TODO: Add error handler on guard statements
        let bucketKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard bucketKey.count > 0 else { return }
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        uploadImageData(data, usingKey: key, completionHandler: completionHandler)
    }
    
    func uploadImageData(_ imageData: Data, usingKey key: String, completionHandler: ((StorageMetadata?, Error?) -> Void)? = nil) {
        let storageRef = storage.reference()
        let imageRef = storageRef.child(key)

        let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let metadata = metadata else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "No photo upload metadata available"
                    ])
                completionHandler?(nil, error)
                return
            }
            completionHandler?(metadata, nil)
        }
        currentUploadTask = uploadTask

    }

    func getReference(for path: String) -> StorageReference {
        // Used for downloading firebase photos into image views using SDWebImage
        let storageRef = storage.reference()
        let reference = storageRef.child(path)
        return reference
    }
}

