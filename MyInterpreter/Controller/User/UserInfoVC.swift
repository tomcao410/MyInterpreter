//
//  UserInfoVC.swift
//  MyInterpreter
//
//  Created by Tom on 6/4/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserInfoVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let tableHeaderHeight: CGFloat = 300.0
    private let tableHeaderCutAway: CGFloat = 40.0
    
    var header: DetailHeaderView!
    var headerMaskLayer: CAShapeLayer!
    var userInfo: [String] = ["Name", "1st language", "2nd language","Email", "Booking status"]
    
    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // MARK: Work place
    private func setUI()
    {
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonClicked))
        
        navigationItem.setCustomNavBar(title: "Profile")
        navigationItem.rightBarButtonItem = logOutButton
        
        customTableView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func logOutButtonClicked()
    {
        try! Auth.auth().signOut()
        
        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ---Custom TableView---
    func customTableView()
    {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        header = tableView.tableHeaderView as? DetailHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(header)
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight + 64)
        
        // cut away header view
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        header.layer.mask = headerMaskLayer
        
        let effectiveHeight = tableHeaderHeight - tableHeaderCutAway/2
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        updateHeaderView()
    }
    
    func updateHeaderView()
    {
        let effectiveHeight = tableHeaderHeight - tableHeaderCutAway/2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        
        if tableView.contentOffset.y < -effectiveHeight
        {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + tableHeaderCutAway/2
        }
        
        header.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - tableHeaderCutAway))
        
        headerMaskLayer.path = path.cgPath
    }
}

// MARK: Delegate --------TABLEVIEW--------
extension UserInfoVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell") as! UserInfoCell
        
        return cell
    }
}

extension UserInfoVC: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
}
