//
//
//  Created by Tapash Majumder on 3/5/19.
//  Copyright © 2019 Iterable. All rights reserved.
//

import Foundation

protocol InAppDisplayerProtocol {
    func isShowingInApp() -> Bool

    /// Shows an IterableMessage.
    /// - parameter message: The Iterable message to show
    /// - parameter callback: the code to execute when user clicks on a link or button on the message.
    /// - returns: A Bool indicating whether the message was opened.
    func showInApp(message: IterableInAppMessage, withCallback callback: ITBURLCallback?) -> Bool
}

class InAppDisplayer : InAppDisplayerProtocol {
    func isShowingInApp() -> Bool {
        return InAppDisplayer.isShowingIterableMessage()
    }
    
    func showInApp(message: IterableInAppMessage, withCallback callback: ITBURLCallback?) -> Bool {
        return InAppDisplayer.show(iterableMessage: message, withCallback: callback)
    }
    
    /**
     Creates and shows a HTML InApp Notification with trackParameters, backgroundColor with callback handler
     
     - parameters:
     - htmlString:      The NSString containing the dialog HTML
     - trackParams:     The track params for the notification
     - callbackBlock:   The callback to send after a button on the notification is clicked
     - backgroundAlpha: The background alpha behind the notification
     - padding:         The padding around the notification
     - returns:
     true if IterableInAppHTMLViewController was shown.
     */
    @discardableResult static func showIterableHtmlMessage(_ htmlString: String,
                                                           trackParams: IterableNotificationMetadata? = nil,
                                                           backgroundAlpha: Double = 0,
                                                           padding: UIEdgeInsets = .zero,
                                                           callbackBlock: ITBURLCallback?
        ) -> Bool {
        guard let topViewController = getTopViewController() else {
            return false
        }
        if topViewController is IterableHtmlMessageViewController {
            ITBError("Skipping the in-app notification. Another notification is already being displayed.")
            return false
        }
        
        let parameters = IterableHtmlMessageViewController.Parameters(html: htmlString,
                                                             padding: padding,
                                                             callback: callbackBlock,
                                                             trackParams: trackParams,
                                                             isModal: true)
        let baseNotification = IterableHtmlMessageViewController(parameters: parameters)
        
        topViewController.definesPresentationContext = true
        baseNotification.view.backgroundColor = UIColor(white: 0, alpha: CGFloat(backgroundAlpha))
        baseNotification.modalPresentationStyle = .overCurrentContext
        
        topViewController.present(baseNotification, animated: false)
        return true
    }
    
    static func showSystemNotification(_ title: String,
                                               body: String,
                                               buttonLeft: String?,
                                               buttonRight: String?,
                                               callbackBlock: ITEActionBlock?) {
        guard let topViewController = getTopViewController() else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        
        if let buttonLeft = buttonLeft {
            addAlertActionButton(alertController: alertController, keyString: buttonLeft, callbackBlock: callbackBlock)
        }
        if let buttonRight = buttonRight {
            addAlertActionButton(alertController: alertController, keyString: buttonRight, callbackBlock: callbackBlock)
        }
        
        topViewController.show(alertController, sender: self)
    }
    
    fileprivate static func isShowingIterableMessage() -> Bool {
        guard Thread.isMainThread else {
            ITBError("Must be called from main thread")
            return false
        }
        guard let topViewController = getTopViewController() else {
            return false
        }
        
        return topViewController is IterableHtmlMessageViewController
    }
    
    private static func getTopViewController() -> UIViewController? {
        guard let rootViewController = IterableUtil.rootViewController else {
            return nil
        }
        var topViewController = rootViewController
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
    @discardableResult fileprivate static func show(iterableMessage: IterableInAppMessage, withCallback callback:ITBURLCallback?) -> Bool {
        guard let content = iterableMessage.content as? IterableHtmlInAppContent else {
            ITBError("Invalid content type")
            return false
        }
        
        let notificationMetadata = IterableNotificationMetadata.metadata(fromInAppOptions: iterableMessage.messageId)
        
        return showIterableHtmlMessage(content.html,
                                       trackParams: notificationMetadata,
                                       backgroundAlpha: content.backgroundAlpha,
                                       padding: content.edgeInsets,
                                       callbackBlock: callback)
    }
    
    /**
     Creates and adds an alert action button to an alertController
     
     - parameter alertController:  The alert controller to add the button to
     - parameter keyString:        the text of the button
     - parameter callbackBlock:    the callback to send after a button on the notification is clicked
     
     - remarks:            passes the string of the button clicked to the callbackBlock
     */
    private static func addAlertActionButton(alertController: UIAlertController, keyString: String, callbackBlock: ITEActionBlock?) {
        let button = UIAlertAction(title: keyString, style: .default) { (action) in
            alertController.dismiss(animated: false)
            callbackBlock?(keyString)
        }
        alertController.addAction(button)
    }
}
