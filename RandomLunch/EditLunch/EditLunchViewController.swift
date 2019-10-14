//
//  EditLunchViewController.swift
//  RandomLunch
//
//  Created by Cüneyt AYVAZ on 11.10.2019.
//  Copyright © 2019 Cüneyt AYVAZ. All rights reserved.
//

import UIKit

class Place: Codable {
    
    @objc var name = ""
    @objc var rate = 0
    @objc var selected = false
    
    init(name: String, rate: Int, selected: Bool) {
        self.name = name
        self.rate = rate
        self.selected = selected
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let rate = aDecoder.decodeObject(forKey: "rate") as! Int
        
        self.init(name: name, rate: rate, selected: false)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(rate, forKey: "rate")
    }
}

class Lunch: Codable {
    
    @objc var place = ""
    @objc var date = Date()
    
    init(place: String, date: Date) {
        self.place = place
        self.date = date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let place = aDecoder.decodeObject(forKey: "place") as! String
        let date = aDecoder.decodeObject(forKey: "date") as! Date
        
        self.init(place: place, date: date)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(place, forKey: "place")
        aCoder.encode(date, forKey: "date")
    }
}

class EditLunchViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    static let PLACES_KEY = "places"
    static let LUNCHES_KEY = "lunches"
    
    var editBarButton: UIBarButtonItem!
    var lastTenLunchesBarButton: UIBarButtonItem!
    var flexibleSpace: UIBarButtonItem!
    var deleteBarButton: UIBarButtonItem!
    var addBarButton: UIBarButtonItem!
    var selectBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    
    var places: [Place] = []
    
    var selectionEnabled = false {
        didSet {
            if selectionEnabled {
                navigationItem.rightBarButtonItem = cancelBarButton
            }
            else {
                navigationItem.rightBarButtonItem = selectBarButton
            }
            if addBarButton != nil {
                addBarButton.isEnabled = !selectionEnabled
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Random Lunch"

        let longPressTableViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(tableViewLongPress(gesture:)))
        tableView.addGestureRecognizer(longPressTableViewGesture)
        
        tableView.register(PlaceTableViewCell.nib, forCellReuseIdentifier: PlaceTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        prepareBarButtonItems()
        
        updatePlaces()
        reloadTableView()
    }

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            var placeList: [String] = []
            for place in places {
                for _ in 0..<place.rate {
                    placeList.append(place.name)
                }
            }
            let index = Int.random(in: 0 ..< placeList.count)
            showAlert(message: placeList[index]) {
                self.addLunch(lunch: Lunch(place: placeList[index], date: Date()))
            }
        }
    }
    
    func prepareBarButtonItems() {
        selectBarButton = UIBarButtonItem(title: "Seç", style: .plain, target: self, action: #selector(selectBarButtonItemTapped))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonItemTapped))
        deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonItemTapped))
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItemTapped))
        lastTenLunchesBarButton = UIBarButtonItem(title: "Son 10 Yemek", style: .plain, target: self, action: #selector(lastTenLunchesBarButtonItemTapped))
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        navigationItem.rightBarButtonItem = selectBarButton
        setToolbarItems([deleteBarButton, flexibleSpace, addBarButton, flexibleSpace, lastTenLunchesBarButton], animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @objc func lastTenLunchesBarButtonItemTapped() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "dd MMM hh:mm"
        
        let lunches = getLunches()
        var message = ""
        for lunch in lunches {
            message = message + "- " + lunch.place + ", " + dateFormatter.string(from: lunch.date) + "\n"
        }
        
        if !message.isEmpty {
            message.removeLast()
        }
        showAlert(message: message)
    }
    
    @objc func deleteBarButtonItemTapped() {
        selectionEnabled = false
        places = places.filter({ item -> Bool in
            !item.selected
        })
        savePlaces()
        reloadTableView()
    }
    
    @objc func addBarButtonItemTapped() {
        
        let alert = UIAlertController(title: "Yeni Mekan", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Mekan Adı"
        }
        alert.addTextField { textField in
            textField.placeholder = "Rate"
        }
        
        let button = UIAlertAction(title: "Tamam", style: .default) { _ in
            let newPlaceName = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let newPlaceRate = Int(alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
            
            if newPlaceName.isEmpty {
                self.showAlert(message: "Mekan adı boş olmamalı.")
                return
            }
            
            if newPlaceRate <= 0 {
                self.showAlert(message: "Rate 0'dan büyük olmalı.")
                return
            }
            
            if !self.places.filter({ item -> Bool in
                item.name.lowercased() == newPlaceName.lowercased()
            }).isEmpty {
                self.showAlert(message: "Bu mekan zaten var.")
                return
            }
            
            self.places.append(Place(name: newPlaceName, rate: newPlaceRate, selected: false))
            self.savePlaces()
            self.reloadTableView()
        }
        
        alert.addAction(button)
        
        let cancelButton = UIAlertAction(title: "İptal", style: .cancel) { _ in
            
        }
        alert.addAction(cancelButton)
        presentViewController(viewController: alert)
    }
    
    @objc func selectBarButtonItemTapped() {
        selectionEnabled = true
    }
    
    @objc func cancelBarButtonItemTapped() {
        selectionEnabled = false
        for i in 0..<places.count {
            places[i].selected = false
        }
        reloadTableView()
    }
    
    @objc func tableViewLongPress(gesture: UILongPressGestureRecognizer!) {
        if selectionEnabled {
            return
        }
        
        let point = gesture.location(in: self.tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        selectionEnabled = true
        places[indexPath.row].selected = !places[indexPath.row].selected
        reloadTableView()
    }
    
    func editPlace(arrayIndex: Int) {
        
        let alert = UIAlertController(title: "Mekan Düzenle", message: places[arrayIndex].name, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Rate"
            textField.text = self.places[arrayIndex].rate.description
        }
        
        let button = UIAlertAction(title: "Tamam", style: .default) { _ in
            let newPlaceRate = Int(alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? 0
            
            if newPlaceRate <= 0 {
                self.showAlert(message: "Rate 0'dan büyük olmalı.")
                return
            }
            
            self.places[arrayIndex].rate = newPlaceRate
            self.savePlaces()
            self.reloadTableView()
        }
        
        alert.addAction(button)
        
        let cancelButton = UIAlertAction(title: "İptal", style: .cancel) { _ in
            
        }
        alert.addAction(cancelButton)
        presentViewController(viewController: alert)
    }
    
    func savePlaces() {
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: EditLunchViewController.PLACES_KEY)
    }
    
    func updatePlaces() {
        guard let data = UserDefaults.standard.value(forKey: EditLunchViewController.PLACES_KEY) as? Data else { return }
        guard let places = try? JSONDecoder().decode(Array.self, from: data) as [Place] else { return }
        self.places = places
    }
    
    func reloadTableView() {
        if deleteBarButton != nil {
            deleteBarButton.isEnabled = !self.places.filter({ item -> Bool in
                item.selected
            }).isEmpty
        }
        tableView.reloadData()
    }
    
    func addLunch(lunch: Lunch) {
        var lunches = getLunches()
        lunches = lunches.reversed()
        lunches.append(lunch)
        if lunches.count > 10  {
            lunches.removeFirst()
        }
        guard let data = try? JSONEncoder().encode(lunches) else { return }
        UserDefaults.standard.set(data, forKey: EditLunchViewController.LUNCHES_KEY)
    }
    
    func getLunches() -> [Lunch] {
        guard let data = UserDefaults.standard.value(forKey: EditLunchViewController.LUNCHES_KEY) as? Data else { return [] }
        guard let lunches = try? JSONDecoder().decode(Array.self, from: data) as [Lunch] else { return [] }
        return lunches
    }
    
}


extension EditLunchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionEnabled {
            places[indexPath.row].selected = !places[indexPath.row].selected
            reloadTableView()
        }
        else {
            editPlace(arrayIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as! PlaceTableViewCell
        cell.configure(with: places[indexPath.row])
        return cell
    }
}

