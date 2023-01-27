//
//  OrderListDetailVC.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 9. 16..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

public enum SelectType : Int {
    case gender = 0
    case ageRange = 1
    case liveLocation = 2
}

protocol OrderListDetailVCDelegate : NSObjectProtocol {
    func OrderListDetailVCDidSelectedCell( vc : OrderListDetailVC, selectString : String, selectIndex : Int)
}

class OrderListDetailVC: UITableViewController {

    
    internal weak var delegate : OrderListDetailVCDelegate!
    
    var isSeledtedIndex = NSNotFound
    
    var listType = SelectType(rawValue: 0)
    
    var dataSource : [String] = []
    
    func dataSource(selectType : SelectType) ->[String] {
        if selectType == .gender {
            return ["남자", "여자"]
        } else if selectType == .ageRange {
            return ["20대", "30대", "40대", "50대", "60대"]
        } else {
            return ["서울", "인천", "경기도", "그외 지역"]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self.dataSource(selectType: self.listType!)
        
//        let leftBarButton = UIBarButtonItem(title: "⟨", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStepSelectTVCell", for: indexPath) as! OrderStepSelectTVCell
        cell.titleLabel?.text = self.dataSource[indexPath.row]
        return cell;
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let result = self.dataSource[indexPath.row];
        print(result)
        self.delegate.OrderListDetailVCDidSelectedCell(vc: self, selectString: result, selectIndex: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func didTouchCloseAction() {
        self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
