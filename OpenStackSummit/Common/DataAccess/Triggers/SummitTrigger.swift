	//
//  DonwloadImagesTrigger.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Haneke

public class SummitTrigger: NSObject, ITrigger {

    public func run(entity: BaseEntity, type: TriggerTypes, operation: TriggerOperations, completitionBlock : ((Void) -> Void)!) {
        if (entity is Summit) {
            run(entity as! Summit, type: type, operation: operation, completitionBlock : completitionBlock)
        }
        else {
            NSException(name: "InvalidArgument",reason: "entity is not of type Summit", userInfo: nil).raise()
        }
    }
    
    private func run(entity: Summit, type: TriggerTypes, operation: TriggerOperations, completitionBlock : ((Void) -> Void)!) {
        if (entity.venues.count > 0) {

            for venue in entity.venues {	
             
                if (!venue.map.isEmpty) {
                    Shared.imageCache.fetch(URL: NSURL(string: venue.map)!)
                }
            }
        }
        
        if (completitionBlock != nil) {
            completitionBlock()
        }
        
    }
}
