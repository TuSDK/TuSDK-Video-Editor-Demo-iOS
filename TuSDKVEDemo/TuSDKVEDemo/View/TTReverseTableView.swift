//
//  TTReverseTableView.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/5/28.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

protocol TTReverseViewDelegate: NSObjectProtocol {
    func reverseView(_ reverseView: TTReverseView, didSelectIndexAt section: Int, event: TTReverseEvents)
}
class TTReverseView: UIView, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    weak var delegate: TTReverseViewDelegate?
    var events:[[TTReverseEvents]] = []
    private(set) var eventSection: Int = 0 
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 49
        tableView.isScrollEnabled = false
        tableView.register(TTReverseTableViewCell.self, forCellReuseIdentifier: "TTReverseView")
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .black
        tableView.transform = CGAffineTransform(rotationAngle: .pi) // 倒转
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func update(section: Int) {
        guard section < events.count, section != eventSection else { return }
        eventSection = section
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard events.count > eventSection else { return 0 }
        return events[eventSection].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TTReverseView", for: indexPath)
        cell.textLabel?.text = events[eventSection][indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[eventSection][indexPath.row]
        self.delegate?.reverseView(self, didSelectIndexAt: eventSection, event: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

