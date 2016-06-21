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
                        if let phoneType = phoneType(rawValue: phoneNumber.label) {
                            contact.addPhoneNumber(number.stringValue, type: phoneType)
                        } else {
                            print(phoneNumber.label, contact.name)
                        }
                    }
                    if let _ = contact.getPhoneNumber() {
                        let index = contacts.insertionIndexOf(contact) { $0.name < $1.name } // Or: myArray.indexOf(c, <)
                        contacts.insert(contact, atIndex: index)
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
        var i = 0
        for contact in contacts {
            if let user = contact.getUser() {
                users.append(user)
//                contacts.removeAtIndex(i)
            }
            i += 1
        }
        return users
    }
}


extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}