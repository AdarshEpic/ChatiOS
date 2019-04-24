//
//  MPCManager.swift
//  ChatApp
//
//  Created by Adarsh Manoharan on 18/04/19.
//  Copyright © 2019 Adarsh Manoharan. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class WiFiChatTableViewController: UITableViewController,UITextFieldDelegate {

    var messagesArray: [Dictionary<String, String>] = []
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //txtChat.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMPCReceivedDataWithNotification(_:)), name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: nil)
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func endChat(sender: AnyObject) {
        let messageDictionary: [String: String] = ["message": "_end_chat_"]
        if appDelegate!.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate!.mpcManager.session.connectedPeers[0]) {
            self.dismiss(animated: true, completion: { () -> Void in
                self.appDelegate?.mpcManager.session.disconnect()
            })
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    var _inputAccessoryView: UIView!
    
    override var inputAccessoryView: UIView? {
        
        if _inputAccessoryView == nil {
            
            _inputAccessoryView = CustomView()
            _inputAccessoryView.backgroundColor = UIColor.groupTableViewBackground
            
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.delegate = self
            _inputAccessoryView.addSubview(textField)
            
            _inputAccessoryView.autoresizingMask = .flexibleHeight
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            textField.leadingAnchor.constraint(
                equalTo: _inputAccessoryView.leadingAnchor,
                constant: 8
                ).isActive = true
            
            textField.trailingAnchor.constraint(
                equalTo: _inputAccessoryView.trailingAnchor,
                constant: -8
                ).isActive = true
            
            textField.topAnchor.constraint(
                equalTo: _inputAccessoryView.topAnchor,
                constant: 8
                ).isActive = true
            
            // this is the important part :
            
            textField.bottomAnchor.constraint(
                equalTo: _inputAccessoryView.layoutMarginsGuide.bottomAnchor,
                constant: -8
                ).isActive = true
        }
        
        return _inputAccessoryView
    }
    

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messagesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MsgTableViewCell", for: indexPath) as? MsgTableViewCell {
            let currentMessage = messagesArray[indexPath.row] as Dictionary<String, String>
            
            if let sender = currentMessage["sender"] {
                var senderLabelText: String
                var senderColor: UIColor
                
                if sender == "self"{
                    senderLabelText = "I said:"
                    senderColor = UIColor.red
                }
                else{
                    senderLabelText = sender + " said:"
                    senderColor = UIColor.orange
                }
                
                cell.title.text = senderLabelText
                cell.title.textColor = senderColor
            }
            
            if let message = currentMessage["message"] {
                cell.msg.text = message
            }
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let messageDictionary: [String: String] = ["message": textField.text ?? ""]
        
        if appDelegate!.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate!.mpcManager.session.connectedPeers[0]) {
           
            let dictionary: [String: String] = ["sender": "self", "message": textField.text ?? ""]
            messagesArray.append(dictionary)
            
            self.updateTableview()
        }
        else{
            print("Could not send data")
        }
        
        textField.text = ""
        
        return true
    }
    
    // MARK: Custom method implementation
    
    func updateTableview(){
        tableView.reloadData()
        
        if self.tableView.contentSize.height > self.tableView.frame.size.height {
            tableView.scrollToRow(at: NSIndexPath(row: messagesArray.count - 1, section: 0) as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    
    @objc func handleMPCReceivedDataWithNotification(_ notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as? Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary?["data"] as? NSData
        let fromPeer = receivedDataDictionary?["fromPeer"] as? MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as? Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary?["message"] {
            // Make sure that the message is other than "_end_chat_".
            if message != "_end_chat_"{
                // Create a new dictionary and set the sender and the received message to it.
                let messageDictionary: [String: String] = ["sender": fromPeer?.displayName ?? "", "message": message]
                
                // Add this dictionary to the messagesArray array.
                messagesArray.append(messageDictionary)
                
                // Reload the tableview data and scroll to the bottom using the main thread.
                OperationQueue.main.addOperation({ () -> Void in
                    self.updateTableview()
                })
            }
            else{
                // In this case an "_end_chat_" message was received.
                // Show an alert view to the user.
                let alert = UIAlertController(title: "", message: "\(String(describing: fromPeer?.displayName)) ended this chat.", preferredStyle: UIAlertController.Style.alert)
                
                let doneAction: UIAlertAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { (alertAction) -> Void in
                    self.appDelegate!.mpcManager.session.disconnect()
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(doneAction)
                
                OperationQueue.main.addOperation({ () -> Void in
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
}
class CustomView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
