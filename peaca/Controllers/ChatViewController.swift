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
import ImageLoader
import Alamofire
import SwiftDate
import SwiftRichString

class ChatViewController: JSQMessagesViewController {
    var partyMembers:[PartyMember]!
    var party:Party!
    var profileImages = [String:UIImage]()
    
    enum ComparePrevResult {
        case overMinEqualId
        case overMinDefferentId
        case notOverMinEqualId
        case notOverMinDefferentId
        case firstMessageOfMe
        case firstMessageOfAnother
    }
    
    @IBAction func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sideMenuNavigationController = segue.destination as? UISideMenuNavigationController {
            if let controller = sideMenuNavigationController.viewControllers.first as? ChatMemberViewController {
                controller.partyMembers = self.partyMembers
            }
        } else if let controller = segue.destination as? ProfileViewController {
            if let data = sender as? String {
                controller.profileId = data
            }
        }
    }
    
    var ref: DatabaseReference = Database.database().reference()
    var chatroom:String!
    lazy var memberRef: DatabaseReference = self.ref.child("members").child(self.chatroom)
    lazy var chatRef: DatabaseReference = self.ref.child("chats").child(self.chatroom)
    
    var messages = [JSQMessage]()
    lazy var outgoingTailBubble: JSQMessagesBubbleImage = self.setupOutgoingBubble(tail: true)
    lazy var incomingTailBubble: JSQMessagesBubbleImage = self.setupIncomingBubble(tail: true)
    lazy var outgoingTaillessBubble: JSQMessagesBubbleImage = self.setupOutgoingBubble(tail: false)
    lazy var incomingTaillessBubble: JSQMessagesBubbleImage = self.setupIncomingBubble(tail: false)
    
    private func setupOutgoingBubble(tail: Bool) -> JSQMessagesBubbleImage {
        if tail {
            let bubbleImageFactory = JSQMessagesBubbleImageFactory()
            return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.uglyYellow)
        } else {
            let tailessBubble = JSQMessagesBubbleImageFactory.init(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero)
            return tailessBubble!.outgoingMessagesBubbleImage(with: UIColor.uglyYellow)
        }
    }
    
    private func setupIncomingBubble(tail: Bool) -> JSQMessagesBubbleImage {
        if tail {
            let bubbleImageFactory = JSQMessagesBubbleImageFactory()
            return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.init(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0))
        } else {
            let tailessBubble = JSQMessagesBubbleImageFactory.init(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero)
            return tailessBubble!.incomingMessagesBubbleImage(with: UIColor.init(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0))
        }
    }
    
    func comparePrevMessage(indexPath: IndexPath) -> ComparePrevResult {
        let message = messages[indexPath.item]
        if messages.indices.contains(indexPath.item - 1) {
            let prevMessage = messages[indexPath.item - 1]
            
            let prevDate = prevMessage.date
            let date = message.date
            
            if date! - prevDate! <= 60 {
                if message.senderId == prevMessage.senderId {
                    return ComparePrevResult.notOverMinEqualId
                } else {
                    return ComparePrevResult.notOverMinDefferentId
                }
            } else {
                if message.senderId == prevMessage.senderId {
                    return ComparePrevResult.overMinEqualId
                } else {
                    return ComparePrevResult.overMinDefferentId
                }
            }
        } else {
            if message.senderId == senderId {
                return ComparePrevResult.firstMessageOfMe
            } else {
                return ComparePrevResult.firstMessageOfAnother
            }
        }
    }
    
    func initialToolbar() {
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("전송", for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.white, for: .normal)
        self.inputToolbar.contentView.backgroundColor = UIColor.uglyYellow
        self.inputToolbar.contentView.textView.placeHolder = "내용을 입력해 주세요"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialToolbar()
        observeMessages()
        
        // No avatars
//        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
//        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for member in partyMembers {
            ImageLoader.request(with: member.userPictureUrl, onCompletion: { (image, error, operation) in
                if error == nil {
                    self.profileImages[member.user.id] = image
                }
            })
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset <= 10.0 {
            print("need update more")
            //TODO: 여기 해결
//            let more = chatRef.queryStarting(atValue: nil, childKey: self.firstMessageKey).queryLimited(toFirst: 25 + 1)
//            more.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//
//                for child in snapshot.children {
//                    if let childSnapshot = child as? DataSnapshot {
//                        let messageData = childSnapshot.value as! Dictionary<String, Any>
//
//                        if let id = messageData["senderId"] as? String, let name = messageData["senderName"] as? String, let text = messageData["text"] as? String, let timestamp = messageData["timestamp"] as? Double, text.count > 0 {
//                            let x = timestamp / 1000
//                            let date = Date(timeIntervalSince1970: x).inLocalRegion()
//
//                            self.addMessage(withId: id, name: name, text: text, date: date.absoluteDate)
//                            self.finishReceivingMessage()
//
//                            print("addmore!!")
//                        }
//                    }
//                }
//            })
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView!.textColor = UIColor.black
        cell.textView!.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        var isOver:Bool!
        
        switch comparePrevMessage(indexPath: indexPath) {
        case .notOverMinEqualId:
            isOver = false
        case .notOverMinDefferentId, .overMinDefferentId, .firstMessageOfAnother, .overMinEqualId, .firstMessageOfMe:
            isOver = true
        }
        
        if messages[indexPath.item].senderId == senderId {
            if isOver {
                return outgoingTailBubble
            } else {
                return outgoingTaillessBubble
            }
        } else {
            if isOver {
                return incomingTailBubble
            } else {
                return incomingTaillessBubble
            }
        }
    }
    
    // Avatar Image
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        switch comparePrevMessage(indexPath: indexPath) {
        case .firstMessageOfAnother, .firstMessageOfMe, .overMinDefferentId, .overMinEqualId, .notOverMinDefferentId:
            let message = messages[indexPath.item]
            guard let image = profileImages[message.senderId] else {
                return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "userAvatar"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
            let avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            return avatarImage
        case .notOverMinEqualId:
            return nil
        }
    }
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private func addMessage(withId id: String, name: String, text: String, date: Date) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            messages.append(message)
        }
    }
    
    private func observeMessages() {
        let messageQuery = chatRef.queryOrdered(byChild: "timestamp")
        //.queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, Any>
            
            if let id = messageData["senderId"] as? String, let name = messageData["senderName"] as? String, let text = messageData["text"] as? String, let timestamp = messageData["timestamp"] as? Double, text.count > 0 {
                let x = timestamp / 1000
                let date = Date(timeIntervalSince1970: x).inLocalRegion()
                
                self.addMessage(withId: id, name: name, text: text, date: date.absoluteDate)
                self.finishReceivingMessage()
            }
            
//            self.firstMessageKey = (snapshot.children.allObjects.first as! DataSnapshot).key
            
//            else if let id = messageData["senderId"] as! String, let photoURL = messageData["photoURL"] as! String {
//                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
//                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
//
//                    if photoURL.hasPrefix("gs://") {
//                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
//                    }
//                }
//            } else {
//                print("Error! Could not decode message data")
//            }
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
        let itemRef = chatRef.childByAutoId()
        let messageItem = ["senderId": senderId!, "senderName": senderDisplayName!, "type": "text", "text": text!, "timestamp": Firebase.ServerValue.timestamp()] as [String : Any]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
//        isTyping = false
        
        let params: Parameters = ["message": text!]
        NetworkManager.sendPushToPartyMembers(partyId: party.id, params: params, completion: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        print("accessory")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        //TODO: 프로필 데이터 전달 필요
        
        let message = messages[indexPath.item]
        
        self.performSegue(withIdentifier: "go_profile", sender: message.senderId)
    }
    
    // 풍선 위
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        let date = message.date.string(custom: "hh:mma")
        
        let style = Style.default {
            $0.font = FontAttribute("NotoSansCJKkr-Regular", size: 11.0)
            $0.color = UIColor.black
        }
        
        if message.senderId == senderId {
            style.align = .right
        } else {
            style.align = .left
        }
        
        let attributedString = date.set(style: style)
        
        return attributedString
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        switch comparePrevMessage(indexPath: indexPath) {
        case .overMinDefferentId, .overMinEqualId, .firstMessageOfMe, .firstMessageOfAnother:
            return 17.0
        case .notOverMinDefferentId, .notOverMinEqualId:
            return 0.0
        }
    }
    
    // Cell 위
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if messages.indices.contains(indexPath.item - 1) {
            let message = messages[indexPath.item]
            let prevMessage = messages[indexPath.item - 1]
            
            let prevDate = prevMessage.date.string(custom: "yyyyMMdd")
            let date = message.date.string(custom: "yyyyMMdd")
            
            if prevDate == date {
                return 0.0
            } else {
                return 17.0
            }
        } else {
            return 17.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        let date = message.date.string(custom: "yyyy.MM.dd eee")
        
        let style = Style.default {
            $0.font = FontAttribute("NotoSansCJKkr-Regular", size: 13.0)
            $0.color = UIColor.black
            $0.align = .center
        }
        let attributedString = date.set(style: style)
        
        return attributedString
    }
}



