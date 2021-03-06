//
//  CoreDataTests.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import Foundation
import CoreData
import Foundation
@testable import CoreSummit

final class CoreDataTests: XCTestCase {
    
    func testSummits() {
        
        for summitID in SummitJSONIdentifiers {
            
            let context = testContext()
                        
            // load test data
            let testJSON = loadJSON("Summit\(summitID)")
            
            guard let summit = Summit(json: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
            
            // decode
            var managedObject: SummitManagedObject!
            
            do {
                
                // cache
                managedObject = try summit.save(context)
                
                // persist and validate
                try context.save()
            }
            
            catch { XCTFail("\(error)"); return }
            
            let decodedSummit = Summit(managedObject: managedObject)
            
            dump(summit, "CoreDataTests" + "Summit" + "\(summitID)" + "Dump.txt")
            
            dump(decodedSummit, "CoreDataTests" + "Decoded" + "Summit" + "\(summitID)" + "Dump.txt")
            
            XCTAssert(summit == decodedSummit, "Original summit \(summitID) must equal decoded summit")
        }
    }
    
    func testMembers() {
        
        for memberID in MemberJSONIdentifiers {
            
            let context = testContext()
            
            // load test data
            let testJSON = loadJSON("Member\(memberID)")
            
            guard let member = MemberResponse.Member(json: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
            
            // cache in CoreData
            do { let _ = try member.save(context) }
                
            catch { XCTFail("\(error)"); return }
        }
    }
    
    func testValidationError() {
        
        // recover from NSDetailedErrors
        
        let context = testContext()
        
        let model = context.persistentStoreCoordinator!.managedObjectModel
        
        let eventEntity = model[EventManagedObject.self]!
        
        let _ = try! context.findOrCreate(eventEntity, resourceID: 1 as NSNumber, identifierProperty: Entity.identifierProperty)
        
        do { try context.validateAndSave() }
        
        catch { XCTFail("\(error)") }
    }
}

// MARK: - Utilitites

private extension CoreDataTests {
    
    func testContext() -> NSManagedObjectContext {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.undoManager = nil
        managedObjectContext.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel.summitModel)
        try! managedObjectContext.persistentStoreCoordinator!.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        
        return managedObjectContext
    }
}
