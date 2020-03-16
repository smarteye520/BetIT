//
//  LIVRequestRetrier.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

/*
import Alamofire

class APIRequestRetrier: RequestRetrier {
 
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
 
    func should(_ manager: SessionManager, retry request: Alamofire.Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        if let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            !(request.request?.url?.absoluteString.contains(Paths.Token.refresh) ?? false) {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                isRefreshing = true
                API.shared.refreshToken()
                    .done {  [weak self] (token) in
                        if let currentUser = AppManager.shared.currentUser {
                            currentUser.token = token
                        }

                        guard let strongSelf = self else { return }
                        strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                        strongSelf.requestsToRetry.forEach { $0(true, 0.0) }
                        strongSelf.requestsToRetry.removeAll()
                    }
                    .ensure { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.isRefreshing = false
                    }
                    .catch {  [weak self] (error) in
                        NotificationCenter.default.post(name: .forceLogout, object: nil, userInfo: nil)

                        guard let strongSelf = self else { return }
                        strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                        strongSelf.requestsToRetry.forEach { $0(false, 0.0) }
                        strongSelf.requestsToRetry.removeAll()
                    }
            }
        } else {
            completion(false, 0.0)
        }
    }
}
*/
