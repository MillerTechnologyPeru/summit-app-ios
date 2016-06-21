//
//  MyProfilePresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol MyProfilePresenterProtocol {
    func getChildViews() -> [UIViewController]
}

public class MyProfilePresenter: MyProfilePresenterProtocol {
    var securityManager: SecurityManager!
    var personalScheduleViewController: ScheduleViewController!
    var memberProfileDetailViewController: MemberProfileDetailViewController!
    var feedbackGivenListViewController: FeedbackGivenListViewController!
    var speakerPresentationsViewController: SpeakerPresentationsViewController!
    
    public func getChildViews() -> [UIViewController] {
        var childViewController: [UIViewController] = []
        
        memberProfileDetailViewController.presenter.attendeeId = 0
        memberProfileDetailViewController.presenter.speakerId = 0
        
        childViewController.append(personalScheduleViewController)
        childViewController.append(memberProfileDetailViewController)
        childViewController.append(feedbackGivenListViewController)
        
        if securityManager.getCurrentMemberRole() == .Speaker {
            childViewController.append(speakerPresentationsViewController)
        }

        return childViewController
    }
}