//
//  GeneralScheduleFilterViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import UIKit
import SwiftFoundation
import CoreSummit

final class GeneralScheduleFilterViewController: UITableViewController {
    
    // MARK: - Properties
    
    fileprivate var filters = [Section]()
    
    fileprivate var filterObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup table view
        tableView.estimatedRowHeight = 48
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        
        // https://github.com/mac-cain13/R.swift/issues/144
        tableView.register(R.nib.tableViewHeaderViewLight(), forHeaderFooterViewReuseIdentifier: TableViewHeaderView.reuseIdentifier)
        
        // observe filter
        filterObserver = FilterManager.shared.filter.observe { [weak self] _ in self?.configureView() }
        
        //  setup UI
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FilterManager.shared.filter.value.update()
    }
    
    // MARK: - Actions
    
    @IBAction func filterChanged(_ sender: UISwitch) {
        
        let buttonOrigin = sender.convert(.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonOrigin)!
        let filter = self[indexPath].filter
        
        if sender.isOn {
            
            FilterManager.shared.filter.value.enable(filter: filter)
            
        } else {
            
            FilterManager.shared.filter.value.disable(filter: filter)
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject? = nil) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    fileprivate func configureView() {
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        let context = Store.shared.managedObjectContext
        
        // load table data from current schedule filter
        filters = []
        
        func identifier(for filter: Filter) -> Identifier {
            
            switch filter {
            case let .trackGroup(identifier): return identifier
            case let .venue(identifier): return identifier
            case .activeTalks, .level: fatalError("Invalid filter: \(filter)")
            }
        }
        
        func name(for filter: Filter) -> String {
            
            switch filter {
            case .activeTalks: return "Hide Past Talks"
            case let .level(level): return level
            case .trackGroup, .venue: fatalError("Invalid filter: \(filter)")
            }
        }
        
        if let activeTalksSection = scheduleFilter.allFilters[.activeTalks] {
            
            let items = activeTalksSection.map { Item(filter: $0, enabled: scheduleFilter.activeFilters.contains($0), name: name(for: $0), color: nil) }
            
            filters.append(Section(category: .activeTalks, items: items))
        }
        
        if let levelsSection = scheduleFilter.allFilters[.level] {
            
            let items = levelsSection.map { Item(filter: $0, enabled: scheduleFilter.activeFilters.contains($0), name: name(for: $0), color: nil) }
            
            filters.append(Section(category: .level, items: items))
        }
        
        if let trackGroupsSection = scheduleFilter.allFilters[.trackGroup] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = trackGroupsSection.map { NSNumber(longLong: Int64(identifier(for: $0))) }
            
            let predicate = NSPredicate(format: "id IN %@", identifiers)
            
            let trackGroups = try! context.managedObjects(TrackGroup.self, predicate: predicate, sortDescriptors: TrackGroup.ManagedObject.sortDescriptors)
            
            let items = trackGroups.map { Item(filter: .trackGroup($0.identifier), enabled: scheduleFilter.activeFilters.contains(.trackGroup($0.identifier)), name: $0.name, color: $0.color) }
            
            filters.append(Section(category: .trackGroup, items: items))
        }
        
        if let venuesSection = scheduleFilter.allFilters[.venue] {
            
            // fetch from CoreData because it caches fetch request results and is more efficient
            let identifiers = venuesSection.map { NSNumber(longLong: Int64(identifier(for: $0))) }
            
            let predicate = NSPredicate(format: "id IN %@", identifiers)
            
            let venues = try! context.managedObjects(Venue.self, predicate: predicate, sortDescriptors: Venue.ManagedObject.sortDescriptors)
            
            let items = venues.map { Item(filter: .venue($0.identifier), enabled: scheduleFilter.activeFilters.contains(.venue($0.identifier)), name: $0.name, color: nil) }
            
            filters.append(Section(category: .venue, items: items))
        }
    }
    
    fileprivate subscript (indexPath: IndexPath) -> Item {
        
        let section = self.filters[indexPath.section]
        
        return section.items[indexPath.row]
    }
    
    fileprivate func configure(cell: GeneralScheduleFilterTableViewCell, at indexPath: IndexPath) {
        
        let item = self[indexPath]
        
        cell.nameLabel.text = item.name
        cell.enabledSwitch.isOn = item.enabled
        
        if let colorHex = item.color,
            let color = UIColor(hexString: colorHex) {
            
            cell.circleContainerView.isHidden = false
            cell.circleView.backgroundColor = color
            
        } else {
            
            cell.circleContainerView.isHidden = true
            cell.circleView.backgroundColor = .clear
        }
    }
    
    fileprivate func configure(header headerView: TableViewHeaderView, for section: Int) {
        
        let filterCategory = self.filters[section].category
        
        let title: String
        
        switch filterCategory {
        case .activeTalks: title = "ACTIVE TALKS"
        case .trackGroup: title = "CATEGORIES"
        case .level: title = "LEVELS"
        case .venue: title = "VENUES"
        }
        
        headerView.titleLabel.text = title
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = self.filters[section]
        
        return section.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.generalScheduleFilterTableViewCell, forIndexPath: indexPath)!
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewHeaderView.reuseIdentifier) as! TableViewHeaderView
        
        configure(header: headerView, for: section)
        
        return headerView
    }
}

// MARK: - Supporting Types

private extension GeneralScheduleFilterViewController {
    
    struct Section {
        
        let category: FilterCategory
        let items: [Item]
    }
    
    /// Item for each cell, to improve performance.
    struct Item {
        
        let filter: Filter
        let enabled: Bool
        let name: String
        let color: String?
    }
}

final class GeneralScheduleFilterTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate(set) weak var circleView: UIView!
    @IBOutlet fileprivate(set) weak var circleContainerView: UIView!
    @IBOutlet fileprivate(set) weak var nameLabel: UILabel!
    @IBOutlet fileprivate(set) weak var enabledSwitch: UISwitch!
}
