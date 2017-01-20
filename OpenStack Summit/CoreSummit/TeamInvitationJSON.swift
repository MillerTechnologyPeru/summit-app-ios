//
//  TeamInvitationJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

private enum TeamInvitationJSONKey: String {
    
    case id, team, team_id, invitee, inviter, permission, created_at, updated_at, is_accepted
}

extension TeamInvitation: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        typealias JSONKey = TeamInvitationJSONKey
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let inviteeJSON = JSONObject[JSONKey.invitee.rawValue],
            let invitee = Member(JSONValue: inviteeJSON),
            let inviterJSON = JSONObject[JSONKey.inviter.rawValue],
            let inviter = Member(JSONValue: inviterJSON),
            let permissionString = JSONObject[JSONKey.permission.rawValue]?.rawValue as? String,
            let permission = TeamPermission(rawValue: permissionString),
            let created = JSONObject[JSONKey.created_at.rawValue]?.rawValue as? Int,
            let updated = JSONObject[JSONKey.updated_at.rawValue]?.rawValue as? Int,
            let accepted = JSONObject[JSONKey.is_accepted.rawValue]?.rawValue as? Bool
            else { return nil }
        
        self.identifier = identifier
        self.invitee = invitee
        self.inviter = inviter
        self.permission = permission
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.updated = Date(timeIntervalSince1970: TimeInterval(updated))
        self.accepted = accepted
        
        // team relationship fault
        if let teamJSON = JSONObject[JSONKey.team.rawValue],
            let team = Team(JSONValue: teamJSON),
            let fault = TeamFault(fault: Fault<Team>.value(team)) {
            
            self.team = fault
            
        } else if let team = JSONObject[JSONKey.team_id.rawValue]?.rawValue as? Int,
            let fault = TeamFault(fault: Fault<Team>.identifier(team))  {
            
            self.team = fault
            
        } else {
            
            return nil
        }
    }
}
