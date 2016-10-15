//
//  Contacts.swift
//  Colorue
//
//  Created by Dylan Wight on 6/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Contacts


struct ContactStore {
    
    fileprivate var contacts = Set<Contact>()
    
    let searchBar = UISearchBar()
    
    init() {
        
        let contactStore = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                // Put them into "contacts"
                for result in containerResults {
                    let contact = Contact(name: result.givenName + " " + result.familyName)
                    
                    for phoneNumber:CNLabeledValue in result.phoneNumbers {
                        let number = phoneNumber.value
                        if let phoneLabel = phoneNumber.label {
                            if let phoneType = phoneType(rawValue: phoneLabel) {
                                contact.addPhoneNumber(number.stringValue, type: phoneType)
                            } else {
                                print(phoneNumber.label, contact.name)
                            }
                        }
                    }
                    
                    if contact.getPhoneNumber() != nil {
                        contacts.insert(contact)
                    }
                }
            } catch {
                print("Error fetching results for container")
            }
        }
    }
    
    func getContacts() -> Set<Contact> {
        return self.contacts
    }
}
