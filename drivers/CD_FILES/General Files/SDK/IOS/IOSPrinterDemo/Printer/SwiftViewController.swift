//
//  SwiftViewController.swift
//  Printer
//
//  Created by ding on 2021/4/26.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController,POSWIFIManagerDelegate {
    @IBOutlet weak var PrintButton: UIButton!
    var wifiManager = POSWIFIManager.share();
    @objc func connect() -> Void {
        // 先断开原来的连接
        wifiManager?.posDisConnect();
        wifiManager?.posConnect(withHost: "192.168.3.241", port: 9100, completion: { (isConnect) in
        })
        
    }
    @IBAction func Print(_ sender: Any) {
        let data = Data("hello\n".utf8);
        wifiManager?.posWriteCommand(with: data);
    }
    override func viewDidLoad() {
        connect();
    }
    func poswifiManager(_ manager: POSWIFIManager!, didConnectedToHost host: String!, port: UInt16) {

    }

    func poswifiManager(_ manager: POSWIFIManager!, willDisconnectWithError error: Error!) {

    }

    func poswifiManager(_ manager: POSWIFIManager!, didWriteDataWithTag tag: Int) {

    }

    func poswifiManager(_ manager: POSWIFIManager!, didRead data: Data!, tag: Int) {
       
    }

    func poswifiManagerDidDisconnected(_ manager: POSWIFIManager!) {

    }
    
}
