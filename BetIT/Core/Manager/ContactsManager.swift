//
//  ContactsManager.swift
//  BetIT
//
//  Created by joseph on 8/26/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import ContactsUI

internal final class PhoneContactsManager {
    static let shared = PhoneContactsManager()
    
    private init() {
        setup()
    }
    
    private func setup() {
        
    }
    
    func getContacts() -> [CNContact] {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey
            ] as [Any]
        
        var allContainers = [CNContainer]()
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("[DEBUG] ContactsManager.getContacts() - Error fetching containers")
        }
        
        var results = [CNContact]()
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("[DEBUG] ContactsManager.getContacts() - Error fetching contacts")
            }
        }
        return results
    }
}
