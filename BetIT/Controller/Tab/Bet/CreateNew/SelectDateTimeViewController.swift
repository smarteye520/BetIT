//
//  SelectDateTimeViewController.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import FSCalendar

class SelectDateTimeViewController: ModalViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var saveButton: UIButton!
    
    private let enabledColor = UIColor(red: 31.0 / 255.0, green: 62.0 / 255.0, blue: 147.0 / 255.0, alpha: 1.0)
    private let disabledColor = UIColor(white: 0.92, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendar.delegate = self
        calendar.appearance.headerMinimumDissolvedAlpha = 0;
        calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase;
        datePicker.minimumDate = Date()

        saveButton.setTitleColor(enabledColor, for: .normal)
        saveButton.setTitleColor(disabledColor, for: .disabled)
        datePicker.addTarget(self,
                             action: #selector(dateChanged(_:)),
                             for: .valueChanged)
    }
    
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        guard let deadline = formatDate(calendar.selectedDate ?? Date()) else { return }
        // datePicker.date = deadline
        
        if deadline < Date() {
            disableSaveButton()
        } else {
            enableSaveButton()
        }
    }
    
    @IBAction func onPrev(_ sender: Any) {
        let date = calendar.currentPage
        calendar.currentPage = date.adding(.month, value: -1)
    }
    
    @IBAction func onNext(_ sender: Any) {
        let date = calendar.currentPage
        calendar.currentPage = date.adding(.month, value: 1)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let selectedDate = calendar.selectedDate {
            guard let deadline = formatDate(selectedDate) else { return }
            guard deadline > Date() else {
                //showAlert("Cannot set deadline in the past")
                print("[DEBUG] SelectDateTimeViewController.saveButtonPressed() - Invalid deadline in past ;returning")
                return
            }
            NotificationCenter.default.post(name: .DidSetDeadline,
                                            object: nil,
                                            userInfo: ["deadline": deadline])
        } else {
            guard let deadline = formatDate(Date()) else { return }
            NotificationCenter.default.post(name: .DidSetDeadline,
                                            object: nil,
                                            userInfo: ["deadline": deadline])
        }
        print("[DEBUG] SelectDateTimeViewController.saveButtonPressed() - Dismissing calendar view")
        self.dismiss(animated: true)
    }
    
    private func disableSaveButton() {
        saveButton.isEnabled = false
    }
    
    private func enableSaveButton() {
        saveButton.isEnabled = true
    }
    
    func formatDate(_ date: Date) -> Date? {
        var comps = DateComponents()
        comps.year = date.year
        comps.month = date.month
        comps.day = date.day
        comps.hour = datePicker.date.hour
        comps.minute = datePicker.date.minute
        comps.second = 0
        return Calendar.current.date(from: comps)
    }
}

extension SelectDateTimeViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        /*
        var comps = DateComponents()
        comps.year = date.year
        comps.month = date.month
        comps.day = date.day
        comps.hour = datePicker.date.hour
        comps.minute = datePicker.date.minute
        comps.second = 0
        */
        
        guard let deadline = formatDate(date) else { return }
        datePicker.date = deadline
        
        if deadline < Date() {
            disableSaveButton()
            // saveButton.isEnabled = false
        } else {
            enableSaveButton()
            // saveButton.isEnabled = true
        }
    }
}
