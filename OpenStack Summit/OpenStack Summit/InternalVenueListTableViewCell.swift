//
//  InternalVenueListTableViewCell.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 3/12/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

final class InternalVenueListTableViewCell: UITableViewCell, VenueListTableViewCellProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    // MARK: - Accessors
    
    var name: String {
        
        get { return nameLabel.text ?? "" }
        set { nameLabel.text = newValue }
    }
    
    var address: String {
        get { return addressLabel.text ?? "" }
        set { addressLabel.text = newValue }
    }
    
    var backgroundImageURL: String = "" {
        didSet {
            if backgroundImageURL.isEmpty {
                backgroundImageView.image = nil
            }
            else {

                let picUrl = backgroundImageURL
                
                backgroundImageView.hnk_setImageFromURL(URL(string: picUrl)!)
            }
        }
    }
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundImageView.contentMode = .scaleAspectFill
    }
}
