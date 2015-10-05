//
//  DataUpdateRemoteStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol IDataUpdateRemoteDataStore {
    func getGeneralUpdatesAfterId(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void)
}

public class DataUpdateRemoteDataStore: NSObject {

    var httpFactory: HttpFactory!
    var deserializerFactory: DeserializerFactory!
    
    func getGeneralUpdatesAfterId(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void)  {
        let attendeeEndpoint = "https://dev-resource-server//api/v1/summits/current/entity-events"
        let http = httpFactory.create(HttpType.ServiceAccount)
        http.GET(attendeeEndpoint, parameters: nil) { (responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? NSString {
                let data = json.dataUsingEncoding(NSUTF8StringEncoding)
                let jsonObject = JSON(data: data!)
                
                var dataUpdates = [DataUpdate]()
                var dataUpdate: DataUpdate!
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.DataUpdate)
                for (_, dataUpdateJSON) in jsonObject {
                    do {
                        dataUpdate = try deserializer.deserialize(dataUpdateJSON) as! DataUpdate
                    }
                    catch {
                        let error: NSError? = NSError(domain: "There was an error parsing data updates", code: 2000, userInfo: nil)
                        completionBlock(nil, error)
                    }
                    dataUpdates.append(dataUpdate)
                }
                completionBlock(dataUpdates, error)
            }
            else {
                let error: NSError? = NSError(domain: "There was an error parsing data updates API response", code: 2001, userInfo: nil)
                completionBlock(nil, error)
            }
        }
    }
}