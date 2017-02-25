//
//  ViewController.swift
//  Immigrants
//
//  Created by Mohamed Ayadi on 2/25/17.
//  Copyright © 2017 Mohamed Ayadi. All rights reserved.
//

import UIKit
import MapKit
import PubNub
import Firebase

class ViewController: UIViewController,MKMapViewDelegate,PNObjectEventListener {
    var numbers = [String]()
    var locationManager = CLLocationManager()
    var client: PubNub!
    let ref = FIRDatabase.database().reference()
    
    override func viewWillAppear(_ animated: Bool) {
        self.getInfoFromFirebase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopUpdatingLocation()
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: "pub-c-dcd8efaa-91ad-4e93-a946-e781d06ebd78", subscribeKey: "sub-c-ca5efc94-fb9d-11e6-afcf-02ee2ddab7fe")
        configuration.uuid = "MoPhone"
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        //self.client.subscribeToPresenceChannels(["test"])
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func alertButtonPressed(_ sender: Any) {
        for number in self.numbers{
            sendAlertTo(number: number)
        }
    }

    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        print("Received message: \(message.data.message) on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
    }
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    // Select last object from list of channels and send message to it.
                    let targetChannel = client.channels().last!
                    client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
                                   compressed: false, withCompletion: { (publishStatus) -> Void in
                                    
                                    if !publishStatus.isError {
                                        self.pubNubIsReady()
                                        // Message successfully published to specified channel.
                                    }
                                    else {
                                        
                                        /**
                                         Handle message publish error. Check 'category' property to find out
                                         possible reason because of which request did fail.
                                         Review 'errorData' property (which has PNErrorData data type) of status
                                         object to get additional information about issue.
                                         
                                         Request can be resent using: publishStatus.retry()
                                         */
                                    }
                    })
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories 
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,  
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }
    
    func pubNubIsReady(){
        //enable UI
   }
    
    func getInfoFromFirebase(){
        let condition = ref.child("phoneNumbers")
        condition.observe(.childAdded, with: { (snapshot) in
            self.numbers.append((snapshot.value as? String)!)
            print("new number added")
        })
    }
    
    func sendAlertTo(number: String){
        let message = [
            "body": "ICE on level 4 in the business section legal help needed.",
            "to" : "\(numbers)"
        ]
        client.publish(message, toChannel: "clicksend-text") { (PNPublishStatus) in
            
        }
    }
}

