//
//  MyTableViewController.swift
//  TableWIthPickers
//
//  Created by Don Mag on 2/1/20.
//  Copyright © 2020 Don Mag. All rights reserved.
//

import UIKit

// date formatting extension
extension Date {
	static let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
		return formatter
	}()
	var formatted: String {
		return Date.formatter.string(from: self)
	}
}

class LabelCell: UITableViewCell {
	
	@IBOutlet var leftLabel: UILabel!
	@IBOutlet var rightLabel: UILabel!
	
}

// PickerCell has a UIDatePicker and a UIPickerView in a vertical stack view
// set .isHidden to show / hide the desired picker
class PickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
	
	@IBOutlet var datePicker: UIDatePicker!
	@IBOutlet var valuePicker: UIPickerView!
	
	var dateCallback: ((Date) -> ())?
	var valueCallback: ((String) -> ())?
	
	var values: [String] = [String]()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		commonInit()
	}
	
	func commonInit() -> Void {
		if valuePicker != nil {
			valuePicker.dataSource = self
			valuePicker.delegate = self
		}
		if datePicker != nil {
			datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
		}
	}
	
	@objc func handleDatePicker(_ datePicker: UIDatePicker) {
		dateCallback?(datePicker.date)
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return values.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return values[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		valueCallback?(values[row])
	}
	
}

enum RowType {
	case textOnly
	case textDate
	case textValue
	case datePicker
	case valuePicker
}

struct SampleItem {
	var dataType: RowType = .textOnly
	var leftValue: String = "Left"
	var rightValue: String = "Right"
	var dateValue: Date = Date()
	var pickerShowing: Bool = false
}

class MyTableViewController: UITableViewController {

	// this would be the data we are tracking / saving
	var sampleItems: [SampleItem] = [
		SampleItem(dataType: .textOnly, leftValue: "First", rightValue: "Bob"),
		SampleItem(dataType: .textOnly, leftValue: "Last", rightValue: "Smith"),
		SampleItem(dataType: .textDate, leftValue: "Date", rightValue: ""),
		SampleItem(dataType: .textOnly, leftValue: "Other", rightValue: "Something"),
		SampleItem(dataType: .textValue, leftValue: "Pick", rightValue: ""),
		SampleItem(dataType: .textOnly, leftValue: "Last", rightValue: "Row"),
	]

	// we'll use a copy of the actual data, because we'll be inserting / deleting items
	// to use as picker rows
	// when finished "editing" the values, we'll want to update our persistent data
	// with the new vales from curItems
	var curItems: [SampleItem] = [SampleItem]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		curItems = sampleItems
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return curItems.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let item = curItems[indexPath.row]
		
		if item.dataType == .datePicker {
			
			// it's a date picker row
			let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
			// show the date picker
			cell.datePicker.isHidden = false
			// hide the value picker
			cell.valuePicker.isHidden = true
			
			// closure to update the data and the row above this one
			cell.dateCallback = { val in
				self.curItems[indexPath.row - 1].dateValue = val
				let iPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
				if let c = tableView.cellForRow(at: iPath) as? LabelCell {
					c.rightLabel.text = val.formatted
				}
			}
			
			return cell
			
		} else if item.dataType == .valuePicker {
			
			// it's a value picker row
			let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell
			// show the value picker
			cell.valuePicker.isHidden = false
			// hide the date picker
			cell.datePicker.isHidden = true
			
			// give it some values to pick
			cell.values = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"]
			
			// closure to update the data and the row above this one
			cell.valueCallback = { val in
				self.curItems[indexPath.row - 1].rightValue = val
				let iPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
				if let c = tableView.cellForRow(at: iPath) as? LabelCell {
					c.rightLabel.text = val
				}
			}
			
			return cell
		}
		
		// it's not a picker row
		let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
		
		cell.leftLabel.text = item.leftValue
		if item.dataType == .textDate {
			cell.rightLabel.text = item.dateValue.formatted
		} else {
			cell.rightLabel.text = item.rightValue
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let item = curItems[indexPath.row]
		
		// if the row is .textDate or .textValue
		if item.dataType == .textDate || item.dataType == .textValue {
			// if the picker is currently showing, remove the next row / item from the array
			// else, insert a row / item defined as .datePicker or .valuePicker
			if item.pickerShowing {
				curItems.remove(at: indexPath.row + 1)
			} else {
				let newItem = SampleItem(dataType: item.dataType == .textDate ? .datePicker : .valuePicker)
				curItems.insert(newItem, at: indexPath.row + 1)
			}
			// update data with pickerShowing
			curItems[indexPath.row].pickerShowing = !curItems[indexPath.row].pickerShowing
			// reload the table
			tableView.reloadData()
		}
	}
}
