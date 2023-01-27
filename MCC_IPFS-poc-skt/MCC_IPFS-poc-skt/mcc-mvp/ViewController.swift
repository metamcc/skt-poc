//
//  ViewController.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 5. 16..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit
import SwiftIpfsApi
import SwiftMultihash
import SwiftMultiaddr

class ViewController: UIViewController {

    var hostString      = "13.125.49.171"
    let hostPort        = 5001
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getIds() {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/4001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            
            try api.id(completionHandler: { (json : JsonType) in
                print(json);
            })
        } catch {
            print("testIds error:\(error)")
        }
    }
    func getInfo() {
        do {
            //                        let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("QmPw2d1MgmiE8ikZjTt4skX9ZUCwbhJ8J3ut3wpYG1SbCb")
            try api.id(completionHandler: { (json : JsonType) in
                print(json);
            })
            //            try api.version({ (version) in
            //                print(version);
            //            })
        } catch {
            print("testIds error:\(error)")
        }
    }
    func getIPFSConfig() {
        do {
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("QmPw2d1MgmiE8ikZjTt4skX9ZUCwbhJ8J3ut3wpYG1SbCb")
            try api.config.show() {result in
                print(result);
                print(result);
            }
        } catch {
            
        }
    }
    func getFileList() {
        do {
            //                        let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            var path = "/ipns/QmfUSeirhrNxhuF7SDAsMLjBzW2CTPHBRhaQSjv3tk9ZGE"
            try api.file.ls(path){result in
                print(result)
                print(result)
            }
            //            try api.version({ (version) in
            //                print(version);
            //            })
        } catch {
            print("testIds error:\(error)")
        }
    }
    func catHash() {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("QmPw2d1MgmiE8ikZjTt4skX9ZUCwbhJ8J3ut3wpYG1SbCb")
            try api.cat(multihash) {
                result in
                //                let data = NSData(bytes: result, length: result.count)
                //                print("cat:",String(bytes: result, encoding: String.Encoding.utf8)!)
                
                //                let tpMultiaddr = newMultiaddrBytes(result)
                
                let nsdata = NSData(bytes: result as [UInt8], length: result.count)
                let image  = CIImage(data: nsdata as Data);
                print(nsdata)
                //                dispatchGroup.leave()
            }
        } catch {
            print("testIds error:\(error)")
        }
    }
    func catData(hash : SwiftMultihash.Multihash) {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            //            let multihash = try fromB58String(hash.hexString())
            try api.cat(hash) {
                result in
                let nsdata = NSData(bytes: result as [UInt8], length: result.count)
                let image  = CIImage(data: nsdata as Data);
                print(nsdata)
                //                dispatchGroup.leave()
            }
        } catch {
            print("testIds error:\(error)")
        }
    }
    func catJsonData() {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("QmZz6XibEtb7h2jNDW6k8mw2M2pJAWfL8JqgpBpDTNw8oU")
            try api.cat(multihash) {
                result in
                let nsdata = NSData(bytes: result as [UInt8], length: result.count)
                let string = NSString(data: nsdata as Data, encoding: String.Encoding.utf8.rawValue)
                print(string)
                print(nsdata)
                
                //                dispatchGroup.leave()
            }
        } catch {
            print("testIds error:\(error)")
        }
    }
    func getJsonData() {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("Qmb7NcZ4Y6WN88uJsdNDvujzQU18PSxDmqBGmjMSX9ZKPZ")
            try api.get(multihash) {
                result in
                let nsdata = NSData(bytes: result as [UInt8], length: result.count)
                let string = NSString(data: nsdata as Data, encoding: String.Encoding.utf8.rawValue)
                print(string)
                print(nsdata)
            }
        } catch {
            print("testIds error:\(error)")
        }
    }
    func catOtherImage() {
        do {
            //            let api = try IpfsApi(addr: "/ip4/172.30.1.14/tcp/5001")
            let api = try IpfsApi(host: hostString, port: hostPort)
            let multihash = try fromB58String("QmdG9x9mFFjCBm1YNAPwMW3dh1sWt8vBCm36XxoWMsqbZ5")
            try api.cat(multihash) {
                result in
                let nsdata = NSData(bytes: result as [UInt8], length: result.count)
                let image  = CIImage(data: nsdata as Data);
                print(nsdata)
                //                dispatchGroup.leave()
            }
        } catch {
            print("testIds error:\(error)")
        }
    }
    func addImage() {
        let image = UIImage(named: "94f483531bccae1dda49e09f8c855c1b.jpg")
        let imageData = UIImagePNGRepresentation(image!)
        do {
            let api = try IpfsApi(host: hostString, port: hostPort)
            try api.add(imageData!) { result  in
                guard result.count == 1, let hash = result[0].hash else {
                    return
                }
                self.catData(hash: hash);
            }
            
        } catch {
            print("testIds error:\(error)")
        }
    }
    @IBAction func didTouchAction() {
        //        getFileList()
        
        
        //        getInfo()
        //        catHash()
        getIds()
        //        swapPeers()
        //        return
        //        addImage();
        //        catOtherImage();
        
        //        catJsonData();
        //        getJsonData();
        
        
        //        let image = UIImage(named: "images.jpeg")
        //        let imageData = UIImagePNGRepresentation(image!)
        
        //        if nodeIdString.count == 0 {
        //            let refsLocal = { (dispatchGroup: DispatchGroup) throws -> Void in
        //                let api = try IpfsApi(host: self.hostString, port: self.hostPort)
        //
        //                try api.refs.local() {
        //                    (localRefs: [Multihash]) in
        //
        //                    for mh in localRefs {
        //                        print(b58String(mh))
        //                    }
        //                    dispatchGroup.leave()
        //                }
        //            }
        //
        //            tester(refsLocal)
        //            return;
        //        }
        //
        //        do {
        //            //            let api = try IpfsApi(host: self.hostString, port: self.hostPort, ssl: true)
        //            let api = try IpfsApi(host: self.hostString, port: self.hostPort)
        //            let idString = self.nodeIdString
        //
        //            let id = { (dispatchGroup: DispatchGroup) throws -> Void in
        //                try api.id(idString) {
        //                    result in
        //
        //                    ////                    XCTAssert(result.object?["ID"]?.string == idString)
        //                    print("idstring : " + idString)
        ////                    XCTAssert(result.object?[IpfsCmdString.ID.rawValue]?.string == idString)
        //
        //                    dispatchGroup.leave()
        //                }
        //            }
        //
        //            tester(id)
        //
        //            let idDefault = { (dispatchGroup: DispatchGroup) throws -> Void in
        //                try api.id() {
        //                    result in
        //
        ////                    XCTAssert(result.object?["ID"]?.string == idString)
        //                    dispatchGroup.leave()
        //                }
        //            }
        //
        //            tester(idDefault)
        //
        //        } catch {
        //            print("testIds error:\(error)")
        //        }
    }
    
    func tester(_ test: (_ dispatchGroup: DispatchGroup) throws -> Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        
        do {
            /// Perform the test.
            try test(group)
            
        } catch  {
            print("tester error: \(error)")
        }
        
        _ = group.wait(timeout: DispatchTime.distantFuture)
    }
}

