//
//  Created by Tapash Majumder on 6/13/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation
import UserNotifications
import XCTest

@testable import IterableSDK

// Note: This is used only by swift tests. So can't put this in Common
class MockNotificationStateProvider: NotificationStateProviderProtocol {
    var notificationsEnabled: Bool {
        return enabled
    }
    
    func registerForRemoteNotifications() {
        expectation?.fulfill()
    }
    
    init(enabled: Bool, expectation: XCTestExpectation? = nil) {
        self.enabled = enabled
        self.expectation = expectation
    }
    
    private let enabled: Bool
    private let expectation: XCTestExpectation?
}
