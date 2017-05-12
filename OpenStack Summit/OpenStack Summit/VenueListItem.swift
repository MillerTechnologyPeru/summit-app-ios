//
//  VenueListItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit
import struct CoreLocation.CLLocationCoordinate2D

public struct VenueListItem: Named {
        
    public let identifier: Identifier
    
    public let name: String
    
    public let descriptionText: String
    
    public let address: String
    
    public let location: CLLocationCoordinate2D?
    
    public let backgroundImageURL: String?
    
    public let maps: [URL]
    
    public let images: [URL]
    
    public let isInternal: Bool
}

// MARK: - CoreDataDecodable

extension VenueListItem: CoreDataDecodable {
    
    public init(managedObject venue: VenueManagedObject) {
        
        assert(venue.name != "", "Empty venue: \(venue)")
        
        self.identifier = venue.id
        self.name = venue.name
        self.descriptionText = venue.descriptionText ?? ""
        self.address = VenueListItem.address(for: venue)
        self.backgroundImageURL = venue.images.first?.url
        self.isInternal = venue.locationType == Venue.LocationType.Internal.rawValue
        
        let floors = venue.floors.sorted { $0.number < $1.number }
        self.maps = venue.maps.map { URL(string: $0.url) } + floors.map { $0.imageURL ?? "" }.filter { $0.isEmpty == false }
        self.images = venue.images.map { URL(string: $0.url)! }
        
        // location
        if let latitude = Double(venue.latitude ?? ""),
            let longitude = Double(venue.longitude ?? "") {
            
            self.location = CLLocationCoordinate2DMake(latitude, longitude)
            
        } else {
            
            self.location = nil
        }
    }
    
    static func address(for venue: VenueManagedObject) -> String {
        
        var fullAddress = venue.address ?? ""
        
        var separator = fullAddress.isEmpty ? "" : ", "
        if let city = venue.city {
            fullAddress += "\(separator)\(city)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let state = venue.state {
            fullAddress += "\(separator)\(state)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let zipCode = venue.zipCode {
            fullAddress += "\(separator)(\(zipCode))"
            separator = fullAddress.isEmpty ? "" : ", "
        }
        
        if venue.country.isEmpty == false {
            fullAddress += "\(separator)\(venue.country)"
        }
        
        return fullAddress
    }
}

// MARK: - Equatable

public func == (lhs: VenueListItem, rhs: VenueListItem) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.address == rhs.address
        && lhs.location?.latitude == rhs.location?.latitude
        && lhs.location?.longitude == rhs.location?.longitude
        && lhs.backgroundImageURL == rhs.backgroundImageURL
        && lhs.maps == rhs.maps
}
