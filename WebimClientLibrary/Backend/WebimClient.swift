//
//  WebimClient.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 10.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

final class WebimClientBuilder {
    
    // MARK: - Properties
    private var appVersion: String?
    private var authorizationData: AuthorizationData?
    private var baseURL: String?
    private var completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?
    private var deltaCallback: DeltaCallback?
    private var deviceID: String?
    private var deviceToken: String?
    private var internalErrorListener: InternalErrorListener?
    private var location: String?
    private var platform: String?
    private var sessionID: String?
    private var sessionParametersListener: SessionParametersListener?
    private var title: String?
    private var visitorFieldsJSONString: String?
    private var visitorJSONString: String?
    
    
    // MARK: - Builder methods
    
    func set(appVersion: String?) -> WebimClientBuilder {
        self.appVersion = appVersion
        return self
    }
    
    func set(baseURL: String) -> WebimClientBuilder {
        self.baseURL = baseURL
        return self
    }
    
    func set(location: String) -> WebimClientBuilder {
        self.location = location
        return self
    }
    
    func set(deltaCallback: DeltaCallback) -> WebimClientBuilder {
        self.deltaCallback = deltaCallback
        return self
    }
    
    func set(sessionParametersListener: SessionParametersListener) -> WebimClientBuilder {
        self.sessionParametersListener = sessionParametersListener
        return self
    }
    
    func set(internalErrorListener: InternalErrorListener) -> WebimClientBuilder {
        self.internalErrorListener = internalErrorListener
        return self
    }
    
    func set(visitorJSONString: String?) -> WebimClientBuilder {
        self.visitorJSONString = visitorJSONString
        return self
    }
    
    func set(visitorFieldsJSONString: String?) -> WebimClientBuilder {
        self.visitorFieldsJSONString = visitorFieldsJSONString
        return self
    }
    
    func set(sessionID: String?) -> WebimClientBuilder {
        self.sessionID = sessionID
        return self
    }
    
    func set(authorizationData: AuthorizationData?) -> WebimClientBuilder {
        self.authorizationData = authorizationData
        return self
    }
    
    func set(completionHandlerExecutor: ExecIfNotDestroyedHandlerExecutor?) -> WebimClientBuilder {
        self.completionHandlerExecutor = completionHandlerExecutor
        return self
    }
    
    func set(platform: String) -> WebimClientBuilder {
        self.platform = platform
        return self
    }
    
    func set(title: String) -> WebimClientBuilder {
        self.title = title
        return self
    }
    
    func set(deviceToken: String?) -> WebimClientBuilder {
        self.deviceToken = deviceToken
        return self
    }
    
    func set(deviceID: String) -> WebimClientBuilder {
        self.deviceID = deviceID
        return self
    }
    
    func build() throws -> WebimClient {
        guard baseURL != nil else {
            throw WebimClientError.invalidParameter("baseURL can't be nil.")
        }
        guard location != nil else {
            throw WebimClientError.invalidParameter("location can't be nil.")
        }
        guard deltaCallback != nil else {
            throw WebimClientError.invalidParameter("deltaCallback can't be nil.")
        }
        guard internalErrorListener != nil else {
            throw WebimClientError.invalidParameter("internalErrorListener can't be nil.")
        }
        guard platform != nil else {
            throw WebimClientError.invalidParameter("platform can't be nil.")
        }
        guard title != nil else {
            throw WebimClientError.invalidParameter("title can't be nil.")
        }
        
        guard completionHandlerExecutor != nil else {
            throw WebimClientError.invalidParameter("completionHandlerExecutor can't be nil.")
        }
        
        guard deviceID != nil else {
            throw WebimClientError.invalidParameter("deviceID can't be nil.")
        }
        
        let actionRequestLoop = ActionRequestLoop(withCompletionHandlerExecutor: completionHandlerExecutor!,
                                                  internalErrorListener: internalErrorListener!)
        actionRequestLoop.set(authorizationData: authorizationData)
        
        let deltaRequestLoop = DeltaRequestLoop(withDeltaCallback: deltaCallback!,
                                                completionHandlerExecutor: completionHandlerExecutor!,
                                                sessionParametersListener: SessionParametersListenerWrapper(withSessionParametersListenerToWrap: sessionParametersListener,
                                                                                                            actionRequestLoop: actionRequestLoop),
                                                internalErrorListener: internalErrorListener!,
                                                baseURL: baseURL!,
                                                platform: platform!,
                                                title: title!,
                                                location: location!,
                                                appVersion: appVersion,
                                                visitorFieldsJSONString: visitorFieldsJSONString,
                                                deviceID: deviceID!,
                                                deviceToken: deviceToken,
                                                visitorJSONString: visitorJSONString,
                                                sessionID: sessionID,
                                                authorizationData: authorizationData)
        
        return WebimClient(withActionRequestLoop: actionRequestLoop,
                           deltaRequestLoop: deltaRequestLoop,
                           webimActions: WebimActions(withBaseURL: baseURL!,
                                                      actionRequestLoop: actionRequestLoop))
    }
    
    
    // MARK: -
    enum WebimClientError: Error {
        case invalidParameter(String)
    }
    
}

// MARK: -
// Need to update deviceToken in DeltaRequestLoop on update in WebimActions.
class WebimClient {
    
    // MARK: - Properties
    private let actionRequestLoop: ActionRequestLoop
    private let deltaRequestLoop: DeltaRequestLoop
    private let webimActions: WebimActions
    
    
    // MARK: - Initialization
    init(withActionRequestLoop actionRequestLoop: ActionRequestLoop,
         deltaRequestLoop: DeltaRequestLoop,
         webimActions: WebimActions) {
        self.actionRequestLoop = actionRequestLoop
        self.deltaRequestLoop = deltaRequestLoop
        self.webimActions = webimActions
    }
    
    
    // MARK: - Methods
    
    func start() {
        actionRequestLoop.start()
        deltaRequestLoop.start()
    }
    
    func pause() {
        actionRequestLoop.pause()
        deltaRequestLoop.pause()
    }
    
    func resume() {
        actionRequestLoop.resume()
        deltaRequestLoop.resume()
    }
    
    func stop() {
        actionRequestLoop.stop()
        deltaRequestLoop.stop()
    }
    
    func set(deviceToken: String) {
        deltaRequestLoop.set(deviceToken: deviceToken)
        webimActions.update(deviceToken: deviceToken)
    }
    
    func getActions() -> WebimActions! {
        return webimActions
    }
    
}

// MARK: -
// Need to update AuthorizationData in ActionRequestLoop on update in DeltaRequestLoop.
final private class SessionParametersListenerWrapper: SessionParametersListener {
    
    // MARK: - Properties
    private let wrappedSessionParametersListener: SessionParametersListener?
    private let actionRequestLoop: ActionRequestLoop
    
    // MARK: - Initializers
    init(withSessionParametersListenerToWrap wrappingSessionParametersListener: SessionParametersListener?,
         actionRequestLoop: ActionRequestLoop) {
        wrappedSessionParametersListener = wrappingSessionParametersListener
        self.actionRequestLoop = actionRequestLoop
    }
    
    // MARK: - SessionParametersListener protocol methods
    func onSessionParametersChanged(visitorFieldsJSONString visitorJSONString: String,
                                    sessionID: String,
                                    authorizationData: AuthorizationData) {
        actionRequestLoop.set(authorizationData: authorizationData)
        
        if wrappedSessionParametersListener != nil {
            wrappedSessionParametersListener?.onSessionParametersChanged(visitorFieldsJSONString: visitorJSONString,
                                                                         sessionID: sessionID,
                                                                         authorizationData: authorizationData)
        }
    }
    
}