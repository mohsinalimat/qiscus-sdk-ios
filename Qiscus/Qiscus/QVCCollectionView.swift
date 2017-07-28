//
//  QVCCollectionView.swift
//  Example
//
//  Created by Ahmad Athaullah on 5/16/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit

// MARK: - CollectionView dataSource, delegate, and delegateFlowLayout
extension QiscusChatVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    // MARK: CollectionView Data source
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let room = self.chatRoom {
            let commentGroup = room.commentGroup(index: section)!
            return commentGroup.commentsCount
        }else{
            return 0
        }
    }
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let room = self.chatRoom {
            if room.commentsGroupCount > 0 {
                self.welcomeView.isHidden = true
            }else{
                self.welcomeView.isHidden = false
            }
            return room.commentsGroupCount
        }else{
            return 0
        }
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        let comment = commentGroup.comment(index: indexPath.row)!
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: comment.cellIdentifier, for: indexPath) as! QChatCell
        cell.comment = comment
        cell.delegate = self
        if let audioCell = cell as? QCellAudio{
            audioCell.audioCellDelegate = self
            cell = audioCell
        }
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        
        if kind == UICollectionElementKindSectionFooter{
            if commentGroup.senderEmail == QiscusMe.sharedInstance.email{
                let footerCell = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellFooterRight", for: indexPath) as! QChatFooterRight
                return footerCell
            }else{
                let footerCell = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellFooterLeft", for: indexPath) as! QChatFooterLeft
                footerCell.sender = commentGroup.sender
                return footerCell
            }
        }else{
            let headerCell = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cellHeader", for: indexPath) as! QChatHeaderCell
        
            headerCell.dateString = commentGroup.date
            return headerCell
        }
    }
    
    // MARK: CollectionView delegate
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        let comment = commentGroup.comment(index: indexPath.row)!
        
        if let selectedIndex = self.selectedCellIndex {
            if indexPath.section == selectedIndex.section && indexPath.item == selectedIndex.item{
                cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
            }
        }
        if comment.status != .read && comment.status != .failed && comment.status != .sending{
            if comment.id > self.chatRoom!.lastReadCommentId {
                QRoom.publishStatus(roomId: self.chatRoom!.id, commentId: comment.id, status: .read)
            }
        }
        if let participant = self.chatRoom?.participant(withEmail: QiscusMe.sharedInstance.email){
            participant.updateLastReadId(commentId: comment.id)
        }
        if indexPath.section == (self.chatRoom!.commentsGroupCount - 1){
            if indexPath.row == commentGroup.commentsCount - 1{
                isLastRowVisible = true
            }
        }
        
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        
        if let selIndex = self.selectedCellIndex {
            if selIndex.section == indexPath.section && selIndex.item == indexPath.item{
                cell.backgroundColor = UIColor.clear
                self.selectedCellIndex = nil
            }
        }
        
        if indexPath.section == (self.chatRoom!.commentsGroupCount - 1){
            if indexPath.row == commentGroup.commentsCount - 1{
                let visibleIndexPath = collectionView.indexPathsForVisibleItems
                if visibleIndexPath.count > 0{
                    var visible = false
                    for visibleIndex in visibleIndexPath{
                        if visibleIndex.row == indexPath.row && visibleIndex.section == indexPath.section{
                            visible = true
                            break
                        }
                    }
                    isLastRowVisible = visible
                }else{
                    isLastRowVisible = true
                }
            }
        }
    }
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        let comment = commentGroup.comment(index: indexPath.row)
        var show = false
        switch action.description {
        case "copy:":
            if comment?.type == .text{
                show = true
            }
            break
        case "resend":
            if comment?.status == .failed && Qiscus.sharedInstance.connected {
                if comment?.type == .text{
                    show = true
                }else if comment!.type == .video || comment!.type == .image || comment!.type == .audio || comment!.type == .file {
                    if let file = comment!.file {
                        if QiscusHelper.isFileExist(inLocalPath: file.localPath){
                            show = true
                        }
                    }
                }
//                else{
//                    if let file = QiscusFile.file(forComment: commentData){
//                        if file.isUploaded || file.isOnlyLocalFileExist{
//                            show = true
//                        }
//                    }
//                }
            }
            break
        case "deleteComment":
            if comment?.status == .failed  {
                show = true
            }
            break
        case "reply":
            if comment?.type != .postback && comment?.type != .account && comment?.status != .failed && comment?.type != .system && Qiscus.sharedInstance.connected{
                show = true
            }
            break
        case "forward":
            if self.forwardAction != nil && Qiscus.sharedInstance.connected && comment?.type != .postback && comment?.type != .account && comment?.status != .failed && comment?.type != .system && comment?.status != .sending {
                show = true
            }
        default:
            break
        }
    
        return show
    }
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        let comment = commentGroup.comment(index: indexPath.row)!
        
        if action == #selector(UIResponderStandardEditActions.copy(_:)) && comment.type == .text{
            UIPasteboard.general.string = comment.text
        }
    }
    // MARK: CollectionView delegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height = CGFloat(0)
        if section > 0 {
            let commentGroup = self.chatRoom!.commentGroup(index: section)!
            let commentGroupBefore = self.chatRoom!.commentGroup(index: section - 1)!
            if commentGroup.date != commentGroupBefore.date{
                height = 35
            }
        }else{
            height = 35
        }
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var height = CGFloat(0)
        var width = CGFloat(0)
        let commentGroup = self.chatRoom!.commentGroup(index: section)!
        if commentGroup.senderEmail != QiscusMe.sharedInstance.email{
            let firstComment = commentGroup.comment(index: 0)
            if firstComment?.type != .system {
                height = 44
                width = 44
            }
        }
        return CGSize(width: width, height: height)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let commentGroup = self.chatRoom!.commentGroup(index: section)!
        if commentGroup.senderEmail != QiscusMe.sharedInstance.email{
            return UIEdgeInsets(top: 0, left: 0, bottom: -44, right: 0)
        }else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let commentGroup = self.chatRoom!.commentGroup(index: indexPath.section)!
        let comment = commentGroup.comment(index: indexPath.row)!
        var size = comment.textSize
        size.width = QiscusHelper.screenWidth() - 16
        
        switch comment.type {
        case .video, .image:
            size.height = 190
            break
        case .audio:
            size.height = 83
            break
        case .file:
            size.height = 67
            break
        case .reply:
            size.height += 88
            break
        case .system:
            size.height += 40
            break
        case .text:
            size.height += 15
            break
        default:
            size.height += 20
            break
        }
        
        if (comment.type != .system && indexPath.row == 0) {
            size.height += 20
        }
        return size
    }
    
}
