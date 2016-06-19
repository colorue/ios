//
//  Contacts.swift
//  Colorue
//
//  Created by Dylan Wight on 6/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Contacts


class ContactsAPI {
    
    private var contacts = [Contact]()
    
    let searchBar = UISearchBar()
    
    init() {
        
        let contactStore = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                // Put them into "contacts"
                for result in containerResults {
                    let contact = Contact(name: result.givenName + " " + result.familyName)
                    
                    for phoneNumber:CNLabeledValue in result.phoneNumbers {
                        let number = phoneNumber.value as! CNPhoneNumber
                        contact.addPhoneNumber(number.stringValue)
                    }
                    if contact.hasNumber() {
                        self.contacts.append(contact)
                    }
                }
            } catch {
                print("Error fetching results for container")
            }
        }
    }
    
    func getContacts() -> [Contact] {
        return self.contacts
    }
    
    func getLinkedUsers() -> [User] {
        var users = [User]()
        for contact in contacts {
            if let user = contact.getUser() {
                users.append(user)
            }
        }
        return users
    }
}