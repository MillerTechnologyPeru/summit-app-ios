//
//  EventFeedbackRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func feedback(summit: Identifier? = nil, event: Identifier, page: Int, objectsPerPage: Int, completion: (ErrorValue<Page<Review>>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/events/\(event)/feedback?expand=owner&page=\(page)&per_page=\(objectsPerPage)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<Review>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try page.items.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(page))
        }
    }
    
    func averageFeedback(summit: Identifier? = nil, event: Identifier, completion: (ErrorValue<Double>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/events/\(event)/published?fields=id,avg_feedback_rate&relations=none"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let averageFeedbackJSON = jsonObject[Event.JSONKey.avg_feedback_rate.rawValue]
                else { completion(.Error(Error.InvalidResponse)); return }
            
            let averageFeedback: Double
            
            if let doubleValue = averageFeedbackJSON.rawValue as? Double {
                
                averageFeedback = doubleValue
                
            } else if let integerValue = averageFeedbackJSON.rawValue as? Int {
                
                averageFeedback = Double(integerValue)
                
            } else {
                
                completion(.Error(Error.InvalidResponse)); return
            }
                        
            // update cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try EventManagedObject.find(event, context: context) {
                    
                    managedObject.averageFeedback = averageFeedback
                }
                
                try context.save()
            }
            
            // success
            completion(.Value(averageFeedback))
        }
    }
    
    func addFeedback(summit: Identifier? = nil, event: Identifier, rate: Int, review: String, completion: (ErrorValue<Identifier>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v2/summits/\(summitID)/events/\(event)/feedback"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDJSON)
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["rate"] = rate
        jsonDictionary["note"] = review
        
        let context = privateQueueManagedObjectContext
        
        http.POST(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let identifier = Int(responseObject as! String)!
            
            // create new feedback in cache
            try! context.performErrorBlockAndWait {
                
                if let member = try self.authenticatedMember(context),
                    let attendee = member.attendeeRole {
                    
                    let feedback = AttendeeFeedback(identifier: identifier, rate: rate, review: review, date: Date(), event: event, member: member.identifier, attendee: attendee.identifier)
                    
                    let managedObject = try feedback.save(context)
                    
                    attendee.feedback.insert(managedObject)
                    
                    try context.save()
                }
            }
            
            completion(.Value(identifier))
        }
    }
}
