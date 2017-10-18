//
//  ChatViewController.swift
//  peaca
//
//  Created by kimkkikki on 2017. 9. 18..
//  Copyright © 2017년 peaca. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import SideMenu

class ChatViewController: JSQMessagesViewController {
    var partyMembers:[PartyMember]!
    
    @IBAction func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sideMenuNavigationController = segue.destination as? UISideMenuNavigationController {
            if let controller = sideMenuNavigationController.viewControllers.first as? ChatMemberViewController {
                controller.partyMembers = self.partyMembers
            }
        }
    }
    
    var ref: DatabaseReference = Database.database().reference()
    var chatroom:String!
    lazy var memberRef: DatabaseReference = self.ref.child("members").child(self.chatroom)
    lazy var chatRef: DatabaseReference = self.ref.child("chats").child(self.chatroom)
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeMessages()
        
        // No avatars
//        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
//        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    // Avatar Image
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let defaultImage = UIImage(named: "userAvatar")
        let image = JSQMessagesAvatarImageFactory.avatarImage(with: defaultImage, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        return image
    }
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        let messageQuery = chatRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!, let photoURL = messageData["photoURL"] as String! {
//                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
//                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
//
//                    if photoURL.hasPrefix("gs://") {
//                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
//                    }
//                }
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            chatRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            chatRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = chatRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "type": "text",
            "text": text!,
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
//        isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        print("accessory")
    }
}


//// 설명 텍스트 (닉네임?)
//override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//    let message = messages[indexPath.item]
//    
//    if message.senderId == senderId {
//        return nil
//    } else {
//        guard let senderDisplayName = message.senderDisplayName else {
//            assertionFailure()
//            return nil
//        }
//        let attributedString = NSAttributedString(string: senderDisplayName)
//        var range = NSRange(location: 0, length: attributedString.length)
//        attributedString.attribute(NSForegroundColorAttributeName, at: 1, effectiveRange: &range)
//        return attributedString
//    }
//}
//
//override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//    let message = messages[indexPath.item]
//    
//    if message.senderId == senderId {
//        return nil
//    } else {
//        guard let senderDisplayName = message.senderDisplayName else {
//            assertionFailure()
//            return nil
//        }
//        let attributedString = NSAttributedString(string: senderDisplayName)
//        var range = NSRange(location: 0, length: attributedString.length)
//        attributedString.attribute(NSForegroundColorAttributeName, at: 1, effectiveRange: &range)
//        return attributedString
//    }
//}
//
//override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
//    let message = messages[indexPath.item]
//    
//    if message.senderId == senderId {
//        return 0
//    } else {
//        return 17.0
//    }
//}
//
//// 설명 텍스트 Height
//override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
//    //return 17.0
//    let message = messages[indexPath.item]
//    
//    if message.senderId == senderId {
//        return 0
//    } else {
//        return 17.0
//    }
//}
