//
//  MemberDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class MemberDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_deserialize_completeAndValidJSON_ReturnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let track = Track();
        track.id = 2
        deserializerStorage.add(track)
        let venueRoom = VenueRoom()
        venueRoom.id = 19
        deserializerStorage.add(venueRoom)
        let eventType = EventType()
        eventType.id = 3
        deserializerStorage.add(eventType)
        let summitType = SummitType()
        summitType.id = 1
        deserializerStorage.add(summitType)
        let speaker1 = PresentationSpeaker()
        speaker1.id = 1761
        deserializerStorage.add(speaker1)
        let speaker2 = PresentationSpeaker()
        speaker2.id = 1861
        deserializerStorage.add(speaker2)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":5290,\"title\":\"Windows in OpenStack\",\"description\":\"test description\", \"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":2,\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[1761,1861]}"
        
        //Act
        let event = try! deserializer.deserialize(json) as! SummitEvent
        
        //Assert
        XCTAssertEqual(5290,event.id)
        XCTAssertEqual("Windows in OpenStack",event.title)
        XCTAssertEqual("test description",event.eventDescription)
        XCTAssertEqual(eventType.id,event.eventType.id)
        XCTAssertEqual(venueRoom.id,event.venueRoom!.id)
        XCTAssertEqual(2,event.presentation?.speakers.count)
    }}