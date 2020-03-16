//
//  SearchUserTableViewCell.swift
//  BetIT
//
//  Created by joseph on 8/26/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ContactsUI

class SearchUserTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabelContainerView: UIView!
    @IBOutlet weak var initialNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    // MARK: - Variables
    private let defaultUsernameLabelCenterYValue = CGFloat(0)
    private let activeUsernameLabelCenterYValue = -(CGFloat(8.0) + CGFloat(14.0)) / CGFloat(2.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setup() {
        imageContainerView.layer.cornerRadius = min(imageContainerView.frame.width, imageContainerView.frame.height) / CGFloat(2.0)
        thumbnailView.layer.cornerRadius = min(thumbnailView.frame.width, thumbnailView.frame.height) / CGFloat(2.0)
        nameLabelContainerView.layer.cornerRadius = min(nameLabelContainerView.frame.width, nameLabelContainerView.frame.height) / CGFloat(2.0)
    
        thumbnailView.isHidden = true
        phoneNumberLabel.isHidden = true
        usernameLabelCenterYConstraint.constant = 0
        
        nameLabelContainerView.isHidden = false
        initialNameLabel.text = nil
    }
    
    private func reset() {
        
    }
    
    func layout(with user: User) {
        usernameLabel.text = user.fullName
        usernameLabelCenterYConstraint.constant = 0
        phoneNumberLabel.isHidden = true
        if let thumbnail = user.thumbnail, thumbnail.isValidThumbnail() {
            thumbnailView.sd_setImage(with: UploadManager.shared.getReference(for: thumbnail))
            thumbnailView.isHidden = false
            nameLabelContainerView.isHidden = true
        } else {
            nameLabelContainerView.isHidden = false
            thumbnailView.isHidden = true
            if let firstName = user.firstName {
                initialNameLabel.text = String(firstName[firstName.startIndex])
            }
        }
    }
    
    func layout(with contact: CNContact) {
        usernameLabelCenterYConstraint.constant = activeUsernameLabelCenterYValue
        phoneNumberLabel.isHidden = false
        phoneNumberLabel.text = contact.phoneNumbers.first?.value.stringValue.formattedNumber()
        if let data = contact.thumbnailImageData, let image = UIImage(data: data) {
            thumbnailView.image = image
            thumbnailView.isHidden = false
            nameLabelContainerView.isHidden = true
        } else {
            thumbnailView.isHidden = true
            nameLabelContainerView.isHidden = false
            let firstName = contact.givenName.capitalized
            if firstName.count > 0 {
                initialNameLabel.text = String(firstName[firstName.startIndex])
            }
        }
        usernameLabel.text = "\(contact.givenName) \(contact.familyName)"
    }
    
    private func showIconView() {
        thumbnailView.isHidden = false
        nameLabelContainerView.isHidden = true
    }
    
    private func showDefaultIconView() {
        thumbnailView.isHidden = true
        nameLabelContainerView.isHidden = false
    }
}
