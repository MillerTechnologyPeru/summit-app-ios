//
//  VenueRoomDataUpdate.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension VenueRoom {
    
    public struct DataUpdate: LocationProtocol {
        
        public let identifier: Identifier
        
        public let name: String
        
        public let descriptionText: String?
        
        public let capacity: Int?
        
        public let venue: Identifier
        
        public let floor: VenueFloor?
    }
}

// MARK: - Equatable

public func == (lhs: VenueRoom.DataUpdate, rhs: VenueRoom.DataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.capacity == rhs.capacity
        && lhs.venue == rhs.venue
        && lhs.floor == rhs.floor
}
