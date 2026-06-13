//
//  TestViewController.swift
//  Printer
//
//  Created by ding on 2022/12/19.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit

class WifiTest: UIViewController {
    var test:WifiManager!
    var test2:WifiManager!
    var isConnectedGlobal:Bool=false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        test.disConnectPrinter();
    }
    func ConnectPrinter(){
        let queue = DispatchQueue(label: "com.receipt.printer1", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        queue.async {
            var isConnected:Bool;
            self.test=WifiManager.share(0,threadID: "com.receipt.printer1");
            isConnected=self.test.connectWifiPrinter("192.168.3.48", port: 9100);
            //isConnected=self.test.connectWifiPrinter("192.168.3.22", port: 9100);
            self.isConnectedGlobal=isConnected;
            if(isConnected){
                print("connect printer1 succeessfully\n");
                self.test.startMonitor();
            }else{
                print("connect printer1 failed\n");
            }
        }
//        let queue2 = DispatchQueue(label: "com.receipt.printer2", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//        queue2.async {
//            var isConnected:Bool;
//            self.test2=WifiManager.share(0,threadID: "com.receipt.printer2");
//            isConnected=self.test2.connectWifiPrinter("192.168.3.88", port: 9100);
//            if(isConnected){
//                print("connect printer2 succeessfully\n");
//                self.test2.startMonitor();
//            }else{
//                print("connect printer2 failed\n");
//            }
//        }
    }
    //To monitor the status of the machine, you need to enable the no-lost order function in advance
    @IBAction func PrintTest(_ sender: Any) {
        let copies:Int=1;
        for i in 1...copies{
        let str:String="Page_"+String(i);
        if(!self.isConnectedGlobal){
            ConnectPrinter();
        }
        sleep(2);
        if(self.isConnectedGlobal){
            let queue = DispatchQueue(label: "com.receipt.printer1", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            queue.async {
                var printSucceed:Bool;
                //printSucceed=test.sendData(toPrinter:Data("hello priner\n".utf8));
                let image=UIImage(named: "test.jpeg");
                var imgData:Data=Data();
                imgData.append(PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering));
                printSucceed=self.test.sendReceipt(toPrinter: imgData);
                //printSucceed=self.test.sendReceipt(toPrinter: Data("hello priner\n".utf8));
                if(printSucceed){
                    print(str+",printer1 succeessfully\n");
                }else{
                    print(str+",printer1 failed\n");
                    print(self.test.getPrinterStatus());
                }
                //Only machines with large boards can frequently disconnect and connect ports
                self.test.disConnectPrinter();
                self.isConnectedGlobal=false;
            }
        }else{
            print(str+",printer1 failed\n");
            print("printer offline or printer error");
        }
        if(copies>1){
            sleep(3);//When printing multiple tests on the same port continuously, you need to wait for the port to be disconnected, otherwise the connection will fail; printing with multiple ports does not increase the delay
        }
//        let queue2 = DispatchQueue(label: "com.receipt.printer2", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//        queue2.async {
//            var printSucceed:Bool;
//            //printSucceed=test.sendData(toPrinter:Data("hello swift\n".utf8));
//            let image=UIImage(named: "test.jpeg");
//            let imgData:Data=PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering);
//            printSucceed=self.test2.sendReceipt(toPrinter: imgData);
//            if(printSucceed){
//                print("print2 succeessfully\n");
//            }else{
//                print("print2 failed\n");
//                print(self.test2.getPrinterStatus());
//            }
//        }
        }
    }
}
