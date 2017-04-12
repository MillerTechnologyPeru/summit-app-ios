//
//  EventFiltersInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventFiltersInterfaceController: WKInterfaceController {
    
    static let identifier = "EventFilters"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    // MARK: - Loading
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue], webpageURL: nil)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Actions
    
    @IBAction func search(_ sender: AnyObject? = nil) {
        
        presentTextInputControllerWithSuggestions(forLanguage: { self.autosuggestions(for: $0) }, allowedInputMode: .plain) { (input) in
            
            guard let inputText = input as? [String]
                else { return }
            
            let filteredEvents = Store.shared.cache?.schedule.filter({
                
                for string in inputText {
                    
                    if $0.name.localizedCaseInsensitiveContainsString(string) {
                        
                        return true
                    }
                }
                
                return false
                
            })
            
            self.pushControllerWithName(EventsInterfaceController.identifier, context: Context(filteredEvents))
        }
    }
    
    // MARK: - Private Methods
    
    /// Provide suggestions for the following language (e.g. `en-US`).
    fileprivate func autosuggestions(for language: String) -> [String] {
        
        #if DEBUG
            return ["WAN", "OpenStack"]
        #else
            
            /*
             let firstNames = Store.shared.cache!.speakers.map({ $0.firstName })
             
             let lastNames = Store.shared.cache!.speakers.map({ $0.lastName })
             
             return firstNames + lastNames
             */
            
            return []
            
        #endif
    }
}
