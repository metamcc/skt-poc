//
//  OrderStep1VC.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 9. 16..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class OrderStep1VC: UIViewController, UITableViewDelegate, UITableViewDataSource, OrderListDetailVCDelegate {

    @IBOutlet weak var tableView : UITableView!
    
    var dataSource : [String?] = [nil,nil,nil]
    
    var nextBtn : UIButton?
    
    func mainTitle(index : Int)->String {
        switch index {
        case 0:
            return "성별"
        case 1:
            return "연령"
        case 2:
            return "거주자"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : OrderStepMainTVCell = tableView.dequeueReusableCell(withIdentifier: "OrderStepMainTVCell", for: indexPath) as! OrderStepMainTVCell
        cell.titleLabel?.text = self.mainTitle(index: indexPath.row)
        
        if let subString = self.dataSource[indexPath.row] {
            cell.subTitleLabel?.text = subString;
            cell.subTitleLabel?.textColor = UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1)
            // cell.subTitleLabel?.text = dataSource[indexPath.row];
        } else {
            cell.subTitleLabel?.text = "선택안됨"
            cell.subTitleLabel?.textColor = UIColor.lightGray
        }
        
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var selectType = SelectType(rawValue: 0)
        
        if indexPath.row == 0 {
            print("성별")
            selectType = SelectType.gender
        }
        else if indexPath.row == 1 {
            print("연령")
            selectType = SelectType.ageRange
        }
        else if indexPath.row == 2 {
            print("거주지")
            selectType = SelectType.liveLocation
        }
        self.performSegue(withIdentifier: MCCSegueKeys.showOrderListDetailVC, sender: selectType)
    }
    
    func OrderListDetailVCDidSelectedCell(vc: OrderListDetailVC, selectString: String, selectIndex: Int) {
        print(selectString)
        self.dataSource[(vc.listType?.rawValue)!] = selectString
        if vc.listType == SelectType.gender {
            DataCreate.Shared.createCreditModel.gender = selectIndex
        } else if vc.listType == SelectType.ageRange {
            DataCreate.Shared.createCreditModel.minage = selectIndex
            DataCreate.Shared.createCreditModel.maxage = selectIndex
        } else if vc.listType == SelectType.liveLocation {
            DataCreate.Shared.createCreditModel.livelocation = selectIndex
        }
        
        if DataCreate.Shared.createCreditModel.gender != NSNotFound && DataCreate.Shared.createCreditModel.minage != NSNotFound &&
            DataCreate.Shared.createCreditModel.maxage != NSNotFound && DataCreate.Shared.createCreditModel.livelocation != NSNotFound{
            self.nextBtn?.isEnabled = true
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let address : String = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)!
        if !address.isEmpty {
            DataCreate.Shared.createCreditModel.clearAll()
            DataCreate.Shared.createCreditModel.owneraddress = address
        }
        
        
//        let rightBarButton = UIBarButtonItem(title: "다음 >", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchNextAction))
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "img-right"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchNextAction))
        rightBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
//        let leftBarButton = UIBarButtonItem(title: "╳", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        
//
//        self.nextBtn = UIButton.init(type: .custom)
//        self.nextBtn?.setTitle("다음", for: .normal)
//        self.nextBtn?.setTitle("다음", for: .highlighted)
//        self.nextBtn?.setTitleColor(UIColor.white, for: .normal)
//        self.nextBtn?.setTitleColor(UIColor.white, for: .highlighted)
//        self.nextBtn?.tintColor = UIColor.white
//        self.nextBtn?.addTarget(self, action: #selector(didTouchNextAction), for: .touchUpInside)
//        let next = UIBarButtonItem.init(customView: self.nextBtn!)
//        self.navigationItem.rightBarButtonItems = [next]
//        self.nextBtn?.isEnabled = false
        
        
//        let closeBtn = UIButton.init(type: .custom)
//        closeBtn.setTitle("닫기", for: .normal)
//        closeBtn.setTitle("닫기", for: .highlighted)
//        closeBtn.setTitleColor(UIColor.white, for: .normal)
//        closeBtn.setTitleColor(UIColor.white, for: .highlighted)
//        closeBtn.addTarget(self, action: #selector(didTouchCloseAction), for: .touchUpInside)
//        let close = UIBarButtonItem.init(customView: closeBtn)
//        self.navigationItem.leftBarButtonItems = [close]
        
    }
    func showAlert(message : String, actionMesage : String, actionStyle : UIAlertActionStyle, actionBlock : alertAction?) {
        // Alert generation.
        let alert: UIAlertController = UIAlertController(title: "MCC", message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        // Cancel action generation.
        let OkAction = UIAlertAction(title: actionMesage, style: actionStyle) { (action: UIAlertAction!) -> Void in
            print("확인")
            if actionBlock != nil {
                actionBlock!()
            }
        }
        alert.addAction(OkAction)
        // Activate Alert.
        present(alert, animated: true, completion: nil)
    }
    @IBAction func didTouchNextAction() {
        
        var isCanNext = 0
        for r in self.dataSource as [String?] {
            if r != nil {
                isCanNext += 1
            }
        }
        
        if isCanNext == self.dataSource.count {
            self.performSegue(withIdentifier: MCCSegueKeys.showOrderStep2VC, sender: nil)
        }
        else{
            self.showAlert(message: "각 항목을 선택해야 다음단계로 진행할수 있습니다.", actionMesage: "확인", actionStyle: UIAlertActionStyle.destructive, actionBlock: nil)
        }
        
    }
    @IBAction func didTouchCloseAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            DataCreate.Shared.createCreditModel.clearAll()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if MCCSegueKeys.showOrderListDetailVC ==  segue.identifier {
            let orderListDetailVC = segue.destination as! OrderListDetailVC
            orderListDetailVC.delegate = self as OrderListDetailVCDelegate;
            orderListDetailVC.listType = sender as? SelectType
        }
    }
 

}
