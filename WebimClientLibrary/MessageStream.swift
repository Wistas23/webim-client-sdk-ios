//
//  MessageStream.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 07.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

/**
 - SeeAlso:
 `WebimSession.getStream(`
 */
public protocol MessageStream {
    
    /**
     - returns:
     Current chat state.
     - SeeAlso:
     `ChatState`
     */
    func getChatState() -> ChatState
    
    /**
     - returns:
     Current LocationSettings of the MessageStream.
     */
    func getLocationSettings() -> LocationSettings
    
    /**
     - returns:
     Operator of the current chat.
     */
    func getCurrentOperator() -> Operator?
    
    /**
     - parameter id:
     ID of the operator.
     - returns:
     Previous rating of the operator or 0 if it was not rated before.
     */
    func getLastRatingOfOperatorWith(id: String) -> Int
    
    /**
     Rates an operator.
     To get an ID of the current operator use `getCurrentOperator()`.
     - parameter id:
     ID of the operator to be rated.
     - parameter rate:
     A number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func rateOperatorWith(id: String,
                          byRating rating: Int) throws
    
    /**
     Changes `ChatState` to `ChatState.QUEUE`.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func startChat() throws
    
    /**
     Changes `ChatState` to `ChatState.CLOSED_BY_VISITOR`.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func closeChat() throws
    
    /**
     This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter.
     - parameter draftMessage:
     Current message content.
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func setVisitorTyping(draftMessage: String?) throws
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` (see new(messageTracker messageListener:)). `MessageListener.added(message newMessage:,after previousMessage:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - parameter message:
     Text of the message.
     - parameter isHintQuestion:
     Optional. Shows to server if a visitor chose a hint (true) or wrote his own text (false).
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func send(message: String,
              isHintQuestion: Bool?) throws -> String
    
    /**
     Sends a text message.
     When calling this method, if there is an active `MessageTracker` (see new(messageTracker messageListener:)). `MessageListener.added(message newMessage:,after previousMessage:)`) with a message `MessageSendStatus.SENDING` in the status is also called.
     - parameter message:
     Text of the message.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func send(message: String) throws -> String
    
    /**
     Sends a file message.
     When calling this method, if there is an active `MessageTracker` (see new(messageTracker messageListener:)), `MessageListener.added(message newMessage:,after previousMessage:)` with a message `MessageSendStatus.SENDING` in the status is also called.
     - parameter path:
     Path of the file to send.
     - parameter mimeType:
     MIME type of the file to send.
     - parameter completionHandler:
     Completion handler that executes when operation is done.
     - returns:
     ID of the message.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func send(file: Data,
              filename: String,
              mimeType: String,
              completionHandler: SendFileCompletionHandler?) throws -> String
    
    /**
     `MessageTracker` (via `MessageTracker.getNextMessages(byLimit:completion:)`) allows to request the messages which are above in the history. Each next call `MessageTracker.getNextMessages(byLimit:completion:)` returns earlier messages in relation to the already requested ones.
     Changes of user-visible messages (e.g. ever requested from `MessageTracker`) are transmitted to `MessageListener`. That is why `MessageListener` is needed when creating `MessageTracker`.
     - important:
     For each `MessageStream` at every single moment can exist the only one active `MessageTracker`. When creating a new one at the previous there will be automatically called `MessageTracker.destroy()`.
     - parameter messageListener:
     A listener of message changes in the tracking range.
     - returns:
     A new `MessageTracker` for this stream.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func new(messageTracker messageListener: MessageListener) throws -> MessageTracker
    
    /**
     Sets the `ChatState` change listener.
     -  parameter chatStateListener:
     The `ChatState` change listener.
     */
    func set(chatStateListener: ChatStateListener)
    
    /**
     Sets the current `Operator` change listener.
     - parameter currentOperatorChangeListener:
     Current `Operator` change listener.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func set(currentOperatorChangeListener: CurrentOperatorChangeListener)
    
    /**
     Sets the listener of the "operator typing" status changes.
     - parameter operatorTypingListener:
     The listener of the "operator typing" status changes.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func set(operatorTypingListener: OperatorTypingListener)
    
    /**
     Sets the listener of the MessageStream LocationSettings changes.
     - parameter locationSettingsChangeListener:
     The listener of MessageStream LocationSettings changes.
     - throws:
     `AccessError.invalidThread` if the method was called not from the thread the WebimSession was created in.
     `AccessError.invalidSession` if WebimSession was destroyed.
     */
    func set(locationSettingsChangeListener: LocationSettingsChangeListener)
    
}

/**
 - SeeAlso:
 `MessageStream.send(file:filename:mimeType:completionHandler:)`
 */
public protocol SendFileCompletionHandler {
    
    /**
     Executed when operation is done successfully.
     - parameter messageID:
     ID of the message.
     */
    func onSuccess(messageID: String)
    
    /**
     Executed when operation is failed.
     - parameter messageID:
     ID of the message.
     - parameter error:
     Error.
     - SeeAlso:
     `SendFileError`.
     */
    func onFailure(messageID: String,
                   error: SendFileError)
    
}

/**
 Interface that provides methods for handling MessageStream LocationSettings which are received from server.
 */
public protocol LocationSettings {
    
    /**
     This method shows to an app if it should show hint questions to visitor.
     - returns:
     True if an app should show hint questions to visitor, false otherwise.
     */
    func areHintsEnabled() -> Bool
    
}

/**
 - SeeAlso:
 `MessageStream.set(chatStateListener:)`
 `MessageStream.getChatState()`
 */
public protocol ChatStateListener {
    
    /**
     Called during `ChatState` transition.
     - parameter previousState:
     Previous state.
     - parameter newState:
     New state.
     */
    func changed(state previousState: ChatState,
                 to newState: ChatState)
    
}

/**
 - SeeAlso:
 `MessageStream.set(currentOperatorChangeListener:)`
 `MessageStream.getCurrentOperator()`
 */
public protocol CurrentOperatorChangeListener {
    
    /**
     Called when `Operator` of the current chat changed.
     - parameter previousOperator:
     Previous operator.
     - parameter newOperator:
     New operator.
     */
    func changed(operator previousOperator: Operator,
                 to newOperator: Operator)
    
}

/**
 - SeeAlso:
 `MessageStream.set(operatorTypingListener:)`
 */
public protocol OperatorTypingListener {
    
    /**
     Called when operator typing state changed.
     - parameter isTyping:
     True if operator is typing, false otherwise.
     */
    func onOperatorTypingStateChanged(isTyping: Bool)
    
}

/**
 Interface that provides methods for handling changes in MessageStream LocationSettings.
 */
public protocol LocationSettingsChangeListener {
    
    /**
     Method called by an app when new MessageStream LocationSettings received.
     - parameter previousLocationSettings:
     Previous LocationSettings state.
     - parameter newLocationSettings:
     New LocationSettings state.
     */
    func changed(locationSettings previousLocationSettings: LocationSettings,
                 to newLocationSettings: LocationSettings)
    
}


/**
 A chat is seen in different ways by an operator depending on ChatState.
 The initial state is `NONE`.
 Then if a visitor sends a message (`MessageStream.send(message:,isHintQuestion:)`), the chat changes it's state to `QUEUE`. The chat can be turned into this state by calling `MessageStream.startChat()`.
 After that, if an operator takes the chat to process, the state changes to `CHATTING`. The chat is being in this state until the visitor or the operator closes it.
 When closing a chat by the visitor `MessageStream.closeChat()`, it turns into the state `CLOSED_BY_VISITOR`, by the operator - `CLOSED_BY_OPERATOR`.
 When both the visitor and the operator close the chat, it's state changes to the initial – `NONE`. A chat can also automatically turn into the initial state during long-term absence of activity in it.
 Furthermore, the first message can be sent not only by a visitor but also by an operator. In this case the state will change from the initial to `INVITATION`, and then, after the first message of the visitor, it changes to `CHATTING`.
 */
public enum ChatState {
    
    /**
     Means the absence of a chat as such, e.g. a chat has not been started by a visitor nor by an operator.
     From this state a chat can be turned into:
     - `QUEUE`, if the chat is started by a visitor (by the first message or by calling `MessageStream.startChat()`;
     - `INVITATION`, if the chat is started by an operator.
     */
    case NONE
    
    /**
     The state is undefined.
     This state is set as the initial when creating a new session, until the first response of the server containing the actual state is got. This state is also used as a fallback if SDK can not identify the server state (e.g. if the server has been updated to a version that contains new states).
     */
    case UNKNOWN
    
    /**
     Means that a chat has been started by a visitor and at this moment is being in the queue for processing by an operator.
     From this state a chat can be turned into:
     - `CHATTING`, if an operator takes the chat for processing;
     - `NONE`, if a visitor closes the chat (by calling (`MessageStream.closeChat()`) before it is taken for processing;
     - `CLOSED_BY_OPERATOR`, if an operator closes the chat without taking it for processing.
     */
    case QUEUE
    
    /**
     Means that an operator has taken a chat for processing.
     From this state a chat can be turned into:
     - `CLOSED_BY_OPERATOR`, if an operator closes the chat;
     - `CLOSED_BY_VISITOR`, if a visitor closes the chat (`MessageStream.closeChat()`);
     - `NONE`, automatically during long-term absence of activity.
     */
    case CHATTING
    
    /**
     Means that a visitor has closed the chat.
     From this state a chat can be turned into:
     - `NONE`, if the chat is also closed by an operator or automatically during long-term absence of activity;
     - `QUEUE`, if a visitor sends a new message (`MessageStream.send(message:,isHintQuestion:)`).
     */
    case CLOSED_BY_VISITOR
    
    /**
     Means that an operator has closed the chat.
     From this state a chat can be turned into:
     - `NONE`, if the chat is also closed by a visitor (`MessageStream.closeChat()`), or automatically during long-term absence of activity;
     - `QUEUE`, if a visitor sends a new message (`MessageStream.send(message:,isHintQuestion:)`).
     */
    case CLOSED_BY_OPERATOR
    
    /**
     Means that a chat has been started by an operator and at this moment is waiting for a visitor's response.
     From this state a chat can be turned into:
     - `CHATTING`, if a visitor sends a message (`MessageStream.send(message:,isHintQuestion:)`);
     - `NONE`, if an operator or a visitor closes the chat (`MessageStream.closeChat()`).
     */
    case INVITATION
    
}

/**
 - SeeAlso:
 `SendFileCompletionHandler.onFailure(messageID:error:)`
 */
public enum SendFileError: Error {
    
    /**
     The server may deny a request if the file type is not allowed.
     The list of allowed file types is configured on the server.
     */
    case FILE_TYPE_NOT_ALLOWED
    
    /**
     The server may deny a request if the file size exceeds a limit.
     The maximum size of a file is configured on the server.
     */
    case FILE_SIZE_EXCEEDED
    
}
