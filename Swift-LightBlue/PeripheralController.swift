//
//  PeripheralController.swift
//  Swift-LightBlue
//
//  Created by Pluto Y on 16/1/11.
//  Copyright © 2016年 Pluto-y. All rights reserved.
//

import UIKit
import CoreBluetooth

let BLUE_GIGA_SERVICES = "1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0"
let BLUE_GIGA_CONTROL_TX = "0xF7BF3564-FB6D-4E53-88A4-5E37E0326063"
let BLUE_GIGA_DATANOACK_RX = "0x984227F3-34FC-4045-A5D0-2C581f81A153"

class PeripheralController : UIViewController, UITableViewDelegate, UITableViewDataSource ,BluetoothDelegate {
    

    fileprivate let bluetoothManager = BluetoothManager.getInstance()
    fileprivate var showAdvertisementData = false
    fileprivate var services : [CBService]?
    fileprivate var characteristicsDic = [CBUUID : [CBCharacteristic]]()
    
    //nitaa1213
    //var characteristic: CBCharacteristic!
    //var writeType: CBCharacteristicWriteType?
    
    var lastAdvertisementData : Dictionary<String, AnyObject>?
    fileprivate var advertisementDataKeys : [String]?
    
    @IBOutlet var peripheralNameLbl: UILabel!
    @IBOutlet var peripheralUUIDLbl: UILabel!
    @IBOutlet var connectFlagLbl: UILabel!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var dataTableView: UITableView!
    
    
    // Alvin add here for trigger box
    // step 1: enter DFU mode and reset
    // step 2: reconnect the peripheral
    // step 3: readDFUBlocks
    // step 4: send and reset
    
    //nitaa 
    var OTAStepArray = ["enter DFU mode","Reconnect","readDFUBlocks","OTA n reset"]
    
    enum BluegigaServices {
        static let ota: String = "1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0";
    }
    
    enum BluegigaCharacteristics {
         static let control: String = "f7bf3564-fb6d-4e53-88a4-5e37e0326063";
         static let dataNoAck: String = "984227f3-34fc-4045-a5d0-2c581f81a153";
    }
    

    /*---------------------------------------------------
    fileprivate func readDFUBlocks() {
        
        
        //full or only app update?
        let file = BallManager.shared.ball!.softwareVersion < Settings.shared.ballLastFullVersion ? Settings.shared.ballSoftwareFullFile : Settings.shared.ballSoftwareAppFile
        //let file = Settings.shared.ballSoftwareFullFile
        
        print("Updating from: \(file)")
        if let path =  Bundle.main.path(forResource: file, ofType: nil) {
            if let fileData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                
                self.totalBytes = fileData.count //store total file size to calculate percentage
                self.blocks = [Data]()
                var blockStart = 0
                var blockSize = 0
                while blockStart < fileData.count {
                    blockSize = self.readBlockSize(data:fileData, start:blockStart) + CBService.HEADER_LENGTH //16 is block header size
                    
                    print("Block Size: \(blockSize)")
                    let range:Range<Data.Index> = Data.Index(blockStart)..<Data.Index(blockStart + blockSize)
                    self.blocks!.append(fileData.subdata(in: range))
                    
                    blockStart = blockStart + blockSize
                }
            }
        } else {
            print("FILE NOT FOUND: \(file)")
        }
    }
    
    fileprivate func readBlockSize(data:Data, start:Int) -> Int {
        var header = [UInt8](repeating: 0, count: CBService.HEADER_LENGTH)
        (data as NSData).getBytes(&header, range:NSMakeRange(start,CBService.HEADER_LENGTH))
        
        var blockSize = UInt32(header[8]) & 0xff
        blockSize = blockSize | ((UInt32(header[9]) << 8) & 0xff00)
        blockSize = blockSize | ((UInt32(header[10]) << 16) & 0xff0000)
        blockSize = blockSize | ((UInt32(header[11]) << 24) & 0xff000000)
        
        return Int(blockSize)
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothManager.delegate = self
    }
    
    func BGM111_FW_OTA() {
        
        // Alvin add here for trigger box
        // step 1: enter DFU mode and reset
        // step 2: reconnect the peripheral
        // step 3: readDFUBlocks
        // step 4: send and reset
        
        
    }
    
    // MARK: custom functions
    func initAll() {
        self.title = "Peripheral"
        advertisementDataKeys = ([String](lastAdvertisementData!.keys)).sorted()
        bluetoothManager.discoverCharacteristics()
        services = bluetoothManager.connectedPeripheral?.services
        
        peripheralNameLbl.text = bluetoothManager.connectedPeripheral?.name
        peripheralUUIDLbl.text = bluetoothManager.connectedPeripheral?.identifier.uuidString
        reloadTableView()
    }
    
    /**
     The callback function of the Show Advertisement Data button click
     */
    func showAdvertisementDataBtnClick() {
        print("PeripheralController --> showAdvertisementDataBtnClick")
        showAdvertisementData = !showAdvertisementData
        reloadTableView()
    }
    
    /**
     Reload tableView
     */
    func reloadTableView() {
        dataTableView.reloadData()
        
        // Fix the contentSize.height is greater than frame.size.height bug(Approximately 20 unit)
        tableViewHeight.constant = dataTableView.contentSize.height
    }
    
    /**
     According the characteristic property array get the properties string
     
     - parameter array: characteristic property array
     
     - returns: properties string
     */
    func getPropertiesFromArray(_ array : [String]) -> String {
        var propertiesString = "Properties:"
        let containWrite = array.contains("Write")
        for property in array {
            if containWrite && property == "Write Without Response" {
                continue
            }
            propertiesString += " " + property
        }
        return propertiesString
    }
    
    
    // MARK: Delegate
    // Mark: UITableViewDelegate
    /*  ----------------------------------------------------  */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nitaa 3 section:\(section)")
        if section == 0 {
            // The first section, we put steps
           
            // nitaa 1215 
            return 4
            
            // Alvin add here for trigger box
            // step 1: enter DFU mode and reset
            // step 2: reconnect the peripheral
            // step 3: readDFUBlocks
            // step 4: send and reset
            
            
            // Original setting for AdvertisementData
            if showAdvertisementData {
                return advertisementDataKeys!.count
            } else {
                return 0
            }
 
        }
        let characteristics = characteristicsDic[services![section - 1].uuid]
        print("nitaa !:\(characteristics)")
        return characteristics == nil ? 0 : characteristics!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView:\(bluetoothManager.connectedPeripheral!.services!.count + 1)")
        print("nitaa num of connect services\(bluetoothManager.connectedPeripheral!.services!.count + 1)")
        return bluetoothManager.connectedPeripheral!.services!.count + 1
    }
    
    /*  ----------------------------------------------------  */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "serviceCell")
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        }
        if (indexPath as NSIndexPath).section == 0 {
            
            // Nitaa 12.16
            cell?.textLabel?.text = OTAStepArray[(indexPath as NSIndexPath).row]
            
            /*
            cell?.textLabel?.text = CBAdvertisementData.getAdvertisementDataStringValue(lastAdvertisementData!, key: advertisementDataKeys![(indexPath as NSIndexPath).row])
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            
            cell?.detailTextLabel?.text = CBAdvertisementData.getAdvertisementDataName(advertisementDataKeys![(indexPath as NSIndexPath).row])
            */
            

        } else {
            let characteristic = characteristicsDic[services![(indexPath as NSIndexPath).section - 1].uuid]![(indexPath as NSIndexPath).row]
            cell?.textLabel?.text = characteristic.name
            cell?.detailTextLabel?.text = getPropertiesFromArray(characteristic.getProperties())
            
            print("nitaa@ \(characteristic.name)")
            print("nitaa@@ \(cell?.detailTextLabel?.text) \n")
        }
        return cell!
    }
    
    /*  ----------------------------------------------------  */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("nitaa 1 section:\(section)")
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        
        let serviceNameLbl = UILabel(frame: CGRect(x: 10, y: 20, width: UIScreen.main.bounds.size.width - 100, height: 20))
        serviceNameLbl.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        
        view.addSubview(serviceNameLbl)
        
        if section == 0 {
            //Nitaa 12.15
            serviceNameLbl.text = "TriggerBox OTA"

            /*
            serviceNameLbl.text = "ADVERTISEMENT DATA"
            let showBtn = UIButton(type: .system)
            showBtn.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 20, width: 60, height: 20)
            if showAdvertisementData {
                showBtn.setTitle("Hide", for: UIControlState())
            } else {
                showBtn.setTitle("Show", for: UIControlState())
            }

            showBtn.addTarget(self, action: #selector(self.showAdvertisementDataBtnClick), for: .touchUpInside)
            view.addSubview(showBtn)
            */
            
        } else {
            let service = bluetoothManager.connectedPeripheral!.services![section - 1]
            serviceNameLbl.text = service.name
            print("nitaa :: \(serviceNameLbl.text)")
        }
        
        return view
    }
    
    // Need overide this method for fix start section from 1(not 0) in the method 'tableView:viewForHeaderInSection:' after iOS 7
    /*  ----------------------------------------------------  */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("nitaa 2 section:\(section)")
        return 60
    }
    
    /*  ----------------------------------------------------  */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("nitaa1 section:\(section)")
        
        if (indexPath as NSIndexPath).section == 0 {
            // Alvin: do all Row selection here
            
            
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            print(currentCell.textLabel!.text ?? "unknown")
            
            switch indexPath.row {
                // step 1: enter DFU mode and reset
                // step 2: reconnect the peripheral
                // step 3: readDFUBlocks
                // step 4: send and reset
            case 0:  // Send DFU command
                
                print("nitaa did select :: Click at section: \((indexPath as NSIndexPath).section), row: \((indexPath as NSIndexPath).row)")
                
                var resetCommand: UInt8 = 1
                
                let resetData = NSData(bytes: &resetCommand, length: 1)
                print("Nitaa Enter DFU mode++")
                
                
                let controller = CharacteristicController()
                
                
                for i in 0..<services!.count {
                    controller.characteristic = characteristicsDic[services![i].uuid]![(indexPath as NSIndexPath).row]
                    if (controller.characteristic?.name == BLUE_GIGA_CONTROL_TX)
                    {
                        bluetoothManager.writeValue(data: resetData as Data, forCahracteristic: controller.characteristic!, type: .withoutResponse)
                        print("nitaa")
                    }
                }

                print("Nitaa Enter DFU mode--")
            
                break
            case 1:
                print("nitaa reconnect +)")
                
                bluetoothManager.connectPeripheral(bluetoothManager.connectedPeripheral!)
                print("nitaa reconnect -")
                break
            case 2:
                print("nitaa did select :: Click at section: \((indexPath as NSIndexPath).section), row: \((indexPath as NSIndexPath).row)")
                // readDFUBlocks
                
                //BlueteethUtils
                
                break
            default: break
            }
            
 
        } else {
            //Edit UUID writeValue
            print("Click at section: \((indexPath as NSIndexPath).section), row: \((indexPath as NSIndexPath).row)")
            let controller = CharacteristicController()
            controller.characteristic = characteristicsDic[services![(indexPath as NSIndexPath).section - 1].uuid]![(indexPath as NSIndexPath).row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    /*  ----------------------------------------------------  */
    func toByteArray<T>( value: T) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        data.withUnsafeMutableBufferPointer {
            UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
        }
        return data
    }
    
    
    // MARK: BluetoothDelegate
    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {
        print("PeripheralController --> didDisconnectPeripheral")
        connectFlagLbl.text = "Disconnected. Data is Stale."
        connectFlagLbl.textColor = UIColor.red
        
    }
    
    func didDiscoverCharacteritics(_ service: CBService) {
        print("Service.characteristics:\(service.characteristics)")
        characteristicsDic[service.uuid] = service.characteristics
        print("nitaa:\(characteristicsDic[service.uuid])")
        reloadTableView()
    }
    
    /**
     The callback function when central manager connected the peripheral successfully.
     
     - parameter connectedPeripheral: The peripheral which connected successfully.
     */
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {
        print("MainController --> didConnectedPeripheral")
        connectFlagLbl.text = "Interrogating..."
        connectFlagLbl.textColor = UIColor.blue
    }
    
    
}

