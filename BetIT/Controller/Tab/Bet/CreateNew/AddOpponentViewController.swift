//
//  AddOpponentViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ContactsUI

class AddOpponentViewController: ModalViewController {
    enum Mode {
        case addOpponent, inviteFriends
    }
    static let shared = AddOpponentViewController()
    private let searchUserReuseIdentifier = "SearchUser"
    private let phoneNumberReuseIdentifier = "PhoneNumber"
    
    private let phoneRegexes: [String] = [
        //"((\\(\\d{3}\) ?)|(\\d{3}-))?\\d{3}-\\d{4}",
        "^\\d{3}-\\d{3}-\\d{4}$",
        "^\\d{10,12}",
        "^\\(\\d{3}\\) \\d{3}-\\d{4}$",
        "^\\d{1} \\(\\d{3}\\) \\d{3}-\\d{4}$"
    ]
    
    var mode: Mode = .addOpponent
    
    private var dataSource = [[Any]]()
    private var users = [User]()
    private var contacts = [CNContact]()
    private var titles = [String]()
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var isPhoneNumber = false
    var isContactsOnly = false
    var didCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchUserTableViewCell", bundle: nil),
                           forCellReuseIdentifier: searchUserReuseIdentifier)
        tableView.register(UINib(nibName: "PhoneNumberTableViewCell", bundle: nil),
                           forCellReuseIdentifier: phoneNumberReuseIdentifier)
        tableView.rowHeight = CGFloat(60)
        tableView.keyboardDismissMode = .onDrag
        // Search user text field
        searchField.delegate = self
        searchField.addTarget(self,
                              action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)

        contacts = PhoneContactsManager.shared.getContacts()
        
        // self.navigationController?.navigationBar.isHidden = true
        
        // Override add opponent title if there is
        if mode == .addOpponent {
            titleLabel.text = "Select Opponent"
        } else {
            titleLabel.text = "Invite Friends"
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchField.becomeFirstResponder()
    }
    
    @IBAction override func onCancel(_ sender: Any) {
        
        if searchField.isFirstResponder {
            didCancel = true
            self.view.endEditing(true)
        } else {
            dismiss(animated: true)
        }
        
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        if didCancel {
            dismiss(animated: true)
        }
    }
    
    @IBAction func clearTextButtonPressed(_ sender: Any) {
        searchField.text = ""
    }
    
    func phoneNumberMatch(_ phoneNumber: String) -> Bool {
        // Check if the first letter starts with a number
        // If true, then check the rest of the string for phone number
        // If false, return false
        
        // Check the rest of the string for phone number
        // If it contains any letters, return false
        // If it contains any dash, continue
        // If it contains any numbers continue
        
        // Get the count of the string excluding any dashes
        // If count is >= 10, return true
        // else return false
        for phoneRegex in phoneRegexes {
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if phoneTest.evaluate(with: phoneNumber) {
                // Handle phone number instead
                return true
            }
        }
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let currentUser = AppManager.shared.currentUser else { return }
        guard let searchQuery = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
    
        clearButton.isHidden = !(searchQuery.count > 0)
        
        if searchQuery.numbersOnly().count > 0 && searchQuery.charactersOnly().count == 0 {
            textField.text = searchQuery.numbersOnly().formattedNumber()
        }
        
        // [START phone_number_match]
        if phoneNumberMatch(searchQuery) {
            isPhoneNumber = true
            tableView.reloadData()
            return
        }
        // [END phone_number_match]
        
        // Prevent fetching users if user is typing phone number
        if searchQuery.numbersOnly().count > 0 {
            return
        }

        isPhoneNumber = false
        
        if searchQuery.count == 0 {
            dataSource.removeAll()
            users.removeAll()
            titles.removeAll()
            tableView.reloadData()
        }

        if isContactsOnly {
            
            dataSource.removeAll()
            users.removeAll()
            titles.removeAll()

            let filteredContacts = contacts.filter({ (contact) -> Bool in
                return "\(contact.givenName) \(contact.familyName)".contains(searchQuery)
            })
            
            if filteredContacts.count > 0 {
                dataSource.append(filteredContacts)
                titles.append("Contacts")
            }
            
            tableView.reloadData()

            return
        }
        
        DatabaseManager.shared.fetchUsers(with: searchQuery) { [weak self] (users, error) in
            guard let strongSelf = self else { return }
            guard error == nil else { return }
            guard let users = users else { return }
            strongSelf.dataSource.removeAll()
            strongSelf.users.removeAll()
            strongSelf.titles.removeAll()
            
            strongSelf.users.append(contentsOf: users.filter({$0 != currentUser}))
            if strongSelf.users.count > 0 {
                strongSelf.dataSource.append(strongSelf.users)
                strongSelf.titles.append("Users on BetIT")
            }
            
            // Fetch contacts
            
            let filteredContacts = strongSelf.contacts.filter({ (contact) -> Bool in
                return "\(contact.givenName) \(contact.familyName)".contains(searchQuery)
            })
            
            if filteredContacts.count > 0 {
                strongSelf.dataSource.append(filteredContacts)
                strongSelf.titles.append("Contacts")
            }
            
            strongSelf.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate

extension AddOpponentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPhoneNumber {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.lightGray
        header.textLabel?.font = UIFont(name: "Interstate-Light", size: 12)
        header.contentView.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPhoneNumber {
            return nil
        }
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Phone number detection
        if isPhoneNumber {
            // Handle phone number detection
            guard let phoneNumber = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            guard phoneNumberMatch(phoneNumber) else { return }
            
            NotificationCenter.default.post(name: .DidSelectPhoneNumber,
                                            object: nil,
                                            userInfo: ["phoneNumber": phoneNumber.formattedNumber()])
            self.dismiss(animated: true)
            return
        }
        
        let obj = dataSource[indexPath.section][indexPath.row]
        NotificationCenter.default.post(name: .DidSelectUser, object: nil, userInfo: ["user": obj])
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension AddOpponentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPhoneNumber {
            return 1
        }
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPhoneNumber {
            return 1
        }
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPhoneNumber {
            // TODO: PhoneNumberCell
            let cell = tableView.dequeueReusableCell(withIdentifier: phoneNumberReuseIdentifier, for: indexPath) as! PhoneNumberTableViewCell
            if let phoneNumber = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if mode == .addOpponent {
                    cell.phoneNumberLabel.text = "Add \"\(phoneNumber)\" as an opponent"

                } else {
                    cell.phoneNumberLabel.text = "Invite \"\(phoneNumber)\" to BetIT"
                }
            }
            return cell
        }
        
        let obj = dataSource[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: searchUserReuseIdentifier, for: indexPath) as! SearchUserTableViewCell
        if let user = obj as? User {
            cell.layout(with: user)
        } else if let contact = obj as? CNContact {
            cell.layout(with: contact)
        }
        return cell

    }
}

// MARK: - UITextFieldDelegate

extension AddOpponentViewController: UITextFieldDelegate {
    
}
