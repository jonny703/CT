//
//  ChartDetailController.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import skpsmtpmessage
import KRProgressHUD
import KRPullLoader

protocol ChartDetailControllerDelegate {
    func reloadDataWhenNewPosted()
    func reloadDataWhenNewCommented()
}

class ChartDetailController: UIViewController {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    let SocialViewXPosition = (DEVICE_WIDTH - 240) / 2
    
    var longClickedCell: PostCell?
    var longClickedPost: Post?
    
    var lastTimestamp: NSNumber?
    var canScroll: Bool = true
    
    var posts = [Post]()
    
    var chartHistories = [ChartCoinTradeHistory]()
    
    var chartCoin: ChartCoin? {
        didSet {
            fetchTradeHistoryWith(bitName: (chartCoin?.id)!)
        }
    }
    
    var jlLineChart: JLLineChart?
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.backgroundColor = UIColor.lightGray
        colView.alwaysBounceVertical = true
        colView.showsVerticalScrollIndicator = false
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
        return colView
    }()

    lazy var socialView: SocialView = {
        
        let view = SocialView()
        
        view.backgroundColor = .white
        
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.socialViewDelegate = self
        return view
    }()
    
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .gray
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        return refreshControl
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        setupNavAndBackground()
        
        observePostsByTenWith(page: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

//MARK: handle show ctuser profile
extension ChartDetailController {
    
    func handleShowCTUserProfile(ctUserId: String) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if currentUserId == ctUserId { return }
        
        let layout = UICollectionViewFlowLayout()
        let profileController = ProfileController(collectionViewLayout: layout)
        profileController.ctUserId = ctUserId
        let navController = UINavigationController(rootViewController: profileController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
}

//MARK: handle refrest
//extension ChartDetailController {
//    func handleRefresh() {
//        self.observePostsByTenWith(page: 2)
//    }
//}

//MARK: handle reload data when new posted
extension ChartDetailController: ChartDetailControllerDelegate {
    func reloadDataWhenNewPosted() {
        observePostsByTenWith(page: 0)
    }
    func reloadDataWhenNewCommented() {
        collectionView.reloadData()
    }
}

//MARK: handle postcell delegate
extension ChartDetailController: PostCellDelegate {
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }

    
    fileprivate func handleFirebaseWith(status: String, userId: String, postId: String, cell: PostCell, index: Int) {
        let interestsRef = Database.database().reference().child("interests").child(postId)
        interestsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(userId) {
                interestsRef.child(userId).removeValue(completionBlock: { (error, ref) in
                    
                    if error != nil {
                        
                        KRProgressHUD.dismiss()
                        return
                    }
                    self.posts[index].status = status
                    self.resetLikeButtonWith(status: status, cell: cell)
                    self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
                    KRProgressHUD.dismiss()
                })
                
            } else {
                
                let value = ["status": status]
                interestsRef.child(userId).updateChildValues(value, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        
                        KRProgressHUD.dismiss()
                        return
                    }
                    self.posts[index].status = status
                    self.resetLikeButtonWith(status: status, cell: cell)
                    self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
                    KRProgressHUD.dismiss()
                    
                })
            }
        })
    }
    
    func didClickLikeButton(index: Int, post: Post, cell: PostCell) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.postId else { return }
        KRProgressHUD.show()
        
        if let status = post.status {
            if status == "none" {
                self.handleFirebaseWith(status: "like", userId: userId, postId: postId, cell: cell, index: index)
            } else {
                self.handleFirebaseWith(status: "none", userId: userId, postId: postId, cell: cell, index: index)
            }
        }
    }
    
    fileprivate func resetLikeButtonWith(status: String, cell: PostCell) {
        var imageName: String
        if status == "like" {
            imageName = AssetName.likeActive.rawValue
            
        } else if status == "love" {
            imageName = AssetName.emoticonLove.rawValue
        } else if status == "haha" {
            imageName = AssetName.emoticonHappy.rawValue
        } else if status == "confused" {
            imageName = AssetName.emoticonConfused.rawValue
        } else if status == "sad" {
            imageName = AssetName.emoticonSad.rawValue
        } else if status == "angry" {
            imageName = AssetName.emoticonAngry.rawValue
        } else {
            imageName = AssetName.likeInactive.rawValue
        }
        
        var image = UIImage()
        
        if status == "none" {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))!
            cell.likeButton.setTitle("like", for: .normal)
            cell.likeButton.tintColor = .darkGray
            cell.likeButton.setTitleColor(.darkGray, for: .normal)
        } else if status == "like" {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))!
            cell.likeButton.setTitle("like", for: .normal)
            cell.likeButton.tintColor = StyleGuideManager.likeButtonActiveBlueColor
            cell.likeButton.setTitleColor(StyleGuideManager.likeButtonActiveBlueColor, for: .normal)
        } else {
            image = (UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal))!
            cell.likeButton.setTitle(status, for: .normal)
            cell.likeButton.tintColor = nil
            if status == "angry" {
                cell.likeButton.setTitleColor(StyleGuideManager.likeButtonAngryColor, for: .normal)
            } else {
                cell.likeButton.setTitleColor(StyleGuideManager.likeButtonEmoticonColor, for: .normal)
            }
            
        }
        
        cell.likeButton.setImage(image, for: .normal)
        
    }
    
    func didClickCommentButton(index: Int, post: Post) {
        print("clicked comment button-", index)
        
        let postCommentsController = PostCommentsController()
        if let category = self.chartCoin?.symbol {
            postCommentsController.category = category
        }
        
        
        postCommentsController.currentPost = post
        postCommentsController.chartDetailControllerDelegate = self
        let navController = UINavigationController(rootViewController: postCommentsController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func didLongClickLikeButton(index: Int, post: Post, gesture: UILongPressGestureRecognizer, cell: PostCell) {
        print("long clicked like button-", index)
        
        let touchPoint = gesture.location(in: self.view)
        
        var yPosition: CGFloat
        if touchPoint.y > DEVICE_HEIGHT / 2 {
            yPosition = touchPoint.y - 60.0
        } else {
            yPosition = touchPoint.y + 40.0
        }
        
        longClickedCell = cell
        longClickedPost = post
        
        addSocialView(yPosition: yPosition)
    }
}

//MARK: handle social view delegate
extension ChartDetailController: SocialViewDelegate {
    func addSocialView(yPosition: CGFloat) {
        
        socialView.frame = CGRect(x: SocialViewXPosition, y: yPosition, width: 240, height: 40)
        view.addSubview(socialView)
        
    }
    
    func didClickEmoticon(index: Int) {
        
        print("selected emoticon-", index)
        socialView.removeFromSuperview()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let postId = longClickedPost?.postId else { return }
        guard let cell = longClickedCell else { return }
        
        var status: String
        if index == 0 {
            status = "like"
        } else if index == 1 {
            status = "love"
        } else if index == 2 {
            status = "haha"
        } else if index == 3 {
            status = "confused"
        } else if index == 4 {
            status = "sad"
        } else {
            status = "angry"
        }
        
        KRProgressHUD.show()
        
        let interestsRef = Database.database().reference().child("interests").child(postId)
        let value = ["status": status]
        interestsRef.child(userId).updateChildValues(value, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                KRProgressHUD.dismiss()
                return
            }
            self.posts[index].status = status
            self.resetLikeButtonWith(status: status, cell: cell)
            self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
            KRProgressHUD.dismiss()
            
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        socialView.removeFromSuperview()
        
    }
}


//MARK: handle collection view delegate

extension ChartDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        
//        if self.posts.count - 1 == indexPath.item {
//            if (self.canScroll) {
//                self.observePostsByTenWith(page: 1)
//            }
//            
//        }
//        
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostCell
        cell.chartDetailController = self
        cell.postCellDelegate = self
        cell.postCellStatus = .chart
        cell.textView.delegate = self
        cell.index = indexPath.item
        cell.moreButton.tag = indexPath.item
        cell.moreButton.addTarget(self, action: #selector(handleBlockAndReport(sender:)), for: .touchUpInside)
        
        let post = posts[indexPath.item]
        
        cell.post = post
        
        
        if let seconds = post.timestamp?.doubleValue {
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
            
        }
        
        
        setupStuffWith(post: post, cell: cell)
        setupCell(cell: cell, post: post)
        setupSocialViewWith(post: post, cell: cell)
        
        cell.setNeedsDisplay()
        return cell

        
    }
    
    fileprivate func resetInterestsLabelWith(postId: String, userId: String, cell: PostCell) {
        let interstsRef = Database.database().reference().child("interests").child(postId)
        interstsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let count = snapshot.childrenCount as NSNumber
            
            print("interested count: ", count)
            let numberStr = self.returnNumberStringWith(number: count)
            cell.interestedLabel.text = "\(numberStr) interested"
            
//            if snapshot.hasChild(userId) {
//                print("interests exist")
//                
//                interstsRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let dictionary = snapshot.value as? [String: AnyObject] {
//                        let status = dictionary["status"] as! String
//                        self.resetLikeButtonWith(status: status, cell: cell)
//                    }
//                })
//                
//            } else {
//                self.resetLikeButtonWith(status: "none", cell: cell)
//            }
        })
    }
    
    fileprivate func resetCommentsLabelWith(postId: String, cell: PostCell) {
        if let childName = self.chartCoin?.symbol {
            let commentsRef = Database.database().reference().child("posts-comments").child(childName).child(postId)
            commentsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let count = snapshot.childrenCount as NSNumber
                
                print("interested count: ", count)
                let numberStr = self.returnNumberStringWith(number: count)
                cell.commentedLabel.text = "\(numberStr) commented"
            })
        }
    }
    
    private func setupSocialViewWith(post: Post, cell: PostCell) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let postId = post.postId {
            
            self.resetInterestsLabelWith(postId: postId, userId: userId, cell: cell)
            
            self.resetCommentsLabelWith(postId: postId, cell: cell)
        }
        
        if let status = post.status {
            self.resetLikeButtonWith(status: status, cell: cell)
        }
    }
    
    private func returnNumberStringWith(number: NSNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let numberStr = numberFormatter.string(from: number)! as String
        return numberStr
    }
    
    private func setupStuffWith(post: Post, cell: PostCell) {
        if let seconds = post.timestamp?.doubleValue {
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
            
        }
        
        
        if post.imageUrl != "" {
            cell.postImageView.isHidden = false
        } else {
            cell.postImageView.isHidden = true
        }
        
        if let postImageUrl = post.imageUrl {
            
            if postImageUrl != "" {
                
                cell.postImageView.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
                cell.postImageView.isHidden = false
            } else {
                cell.postImageView.isHidden = true
            }
            
        }
    }
    
    private func setupCell(cell: PostCell, post: Post) {
        
        if let userId = post.fromId {
            let ref = Database.database().reference().child("users").child(userId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let profileImageUrl = dictionary["profilePictureURL"] as? String
                    if profileImageUrl != "" {
                        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
                    } else {
                        cell.profileImageView.image = UIImage(named: "iTunesArtwork")
                    }
                    cell.usernameLabel.text = dictionary["username"] as? String
                }
                
                
            }, withCancel: nil)
        }
        
        if post.text != "" {
            
            let postStr = post.text
            
            let postAttributedString = NSMutableAttributedString(string: postStr!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: postStr!, options: [], range: NSRange(location: 0, length: (postStr!.utf16.count)))
            
            if matches.count > 0 {
                for match in matches {
                    if let url = postStr?.substring(with: match.range.range(for: postStr!)!) {
                        //                        print("urlPost", url)
                        
                        
                        if let range = postStr?.range(of: url) {
                            if let index = postStr?.distance(from: (postStr?.startIndex)!, to: range.lowerBound) {
                                
                                let urlRange = NSMakeRange(index, url.characters.count)
                                
                                postAttributedString.addAttribute(NSLinkAttributeName, value: url, range: urlRange)
                                
                                postAttributedString.removeAttribute(NSFontAttributeName, range: urlRange)
                                postAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: urlRange)
                                
                                let linkAttribute: [String: Any] = [NSForegroundColorAttributeName: StyleGuideManager.likeButtonActiveBlueColor, NSUnderlineColorAttributeName: StyleGuideManager.likeButtonActiveBlueColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
                                cell.textView.linkTextAttributes = linkAttribute
                                cell.textView.attributedText = postAttributedString
                            }
                        }
                    }
                    
                }
            }
            else  {
                cell.textView.attributedText = nil
                cell.textView.typingAttributes = Dictionary()
                cell.textView.text = post.text
                cell.textView.font = UIFont.systemFont(ofSize: 16)
            }
            
            cell.textView.isHidden = false
            let height = estimateFrameForText(text: post.text!).height + 20
            cell.textViewHeightConstraint?.constant = height
            
        } else {
            cell.textView.isHidden = false
            cell.textViewHeightConstraint?.constant = 15
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 65
        
        let post = posts[indexPath.item]
        height = estimateFrameForText(text: post.text!).height + 55
        
        if post.imageUrl != "" {
            height += 150
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height + 60)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 210.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView? = nil
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ChartCellHeader
            
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 210)
            headerView.backgroundColor = .white
            
            if let chartView = self.jlLineChart {
                print("chartview")
                headerView.nothingLabel.isHidden = true
                
                headerView.chartContainerView.addSubview(chartView)
                chartView.stroke()
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleChartView(sender:)))
                chartView.addGestureRecognizer(tap)
                
            } else {
                print("nothingLabel")
                headerView.nothingLabel.isHidden = false
            }
            
            reusableView = headerView
            
        }
        
        return reusableView!
        
    }
    
    
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH - 70, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
    
    
}

//MARK: handle report and block

extension ChartDetailController: SKPSMTPMessageDelegate {
    
    func handleBlockAndReport(sender: UIButton) {
        
        let moreButton = sender
        
        let post = posts[moreButton.tag]
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            self.handleReportEmailWith(content: "report")
        }
        
        let blockAction = UIAlertAction(title: "Block", style: .default) { (action) in
            self.handleReportEmailWith(content: "block")
            self.handleBlockWith(post: post, index: moreButton.tag)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }

    
    fileprivate func handleBlockWith(post: Post, index: Int) {
        
        if let postId = post.postId, let childPost = self.chartCoin?.name  {

            let postsRef = Database.database().reference().child("posts").child(childPost).child(postId)
            
            let value = ["isBlock": "true"] as [String: AnyObject]
            postsRef.updateChildValues(value
                , withCompletionBlock: { (error, postRef) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    self.posts.remove(at: index)
                    self.collectionView.reloadData()
            })
        }
    }
    
    fileprivate func handleReportEmailWith(content: String) {
        
        let userId = Auth.auth().currentUser?.uid
        let ctUser = CTUser()
        
        let ref = Database.database().reference().child("users").child(userId!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            ctUser.userId = userId
            
            ctUser.setValuesForKeys(dictionary)
            
        }, withCancel: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            
            if let toEmail = ctUser.email {
                let emailMessage = SKPSMTPMessage()
                emailMessage.fromEmail = "zhichaocaesar702@gmail.com"
                emailMessage.toEmail = toEmail
                emailMessage.subject = "CoinVerse"
                emailMessage.relayHost = "smtp.gmail.com"
                emailMessage.requiresAuth = true
                emailMessage.login = "zhichaocaesar702@gmail.com"
                emailMessage.pass = "juliuscaesar0703"
                emailMessage.wantsSecure = true
                emailMessage.delegate = self
                
                let messageBody = "Thank you for taking a moment to " + content + " a user/content on CoinVerse. It is a great help us to have our own members assist us in keeping the CrptoTweets steams as informative and constructive as possible. We are presently processing your report. CoinVerse"
                
                let plainPart: NSDictionary = [kSKPSMTPPartContentTypeKey: "text/plain", kSKPSMTPPartMessageKey: messageBody, kSKPSMTPPartContentTransferEncodingKey: "8bit"]
                emailMessage.parts = [plainPart]
                emailMessage.send()
            }
            
        })
        
        
    }
    
    func messageSent(_ message: SKPSMTPMessage!) {
        print("email sent")
    }
    
    func messageFailed(_ message: SKPSMTPMessage!, error: Error!) {
        print("email sending fail")
    }
    
    
}


//MARK: handle to tap chart view

extension ChartDetailController {
    
    func handleChartView(sender: UIGestureRecognizer) {
        
        goingToLandscapeController()
        
    }
    
    fileprivate func goingToLandscapeController() {
        let chartViewLandscapeController = ChartViewLandscapeController()
        chartViewLandscapeController.chartCoin = self.chartCoin
        self.present(chartViewLandscapeController, animated: false, completion: nil)
    }
    
}

//MARK: handle swift chart() 

extension ChartDetailController {
    fileprivate func fetchTradeHistoryWith(bitName: String) {

        
        let request = String(format: CoinMarketCapService.TradeHistoryWeek.rawValue, bitName)
        
        API?.executeHTTPRequest(Get, url: request, parameters: nil, completionHandler: { (responseDic) in
            self.parseResponseWith(response: responseDic!)
        }, errorHandler: { (error) in
            KRProgressHUD.dismiss()
            print("history", error!)
        })
        
    }
    
    private func parseResponseWith(response: [AnyHashable: Any]) {
        
        
        let historyDic = response["history"] as! [String: [String: Any]]
        
        for history in historyDic {
            
            let currentDateKey = history.key
            
            let dateFormatterForDay = DateFormatter()
            
            dateFormatterForDay.dateFormat = "hh-dd-MM-yyyy"
            
            let currentDate = dateFormatterForDay.date(from: currentDateKey)
            
            let yesterday = Date().yesterday
            
            if currentDate?.isGreaterThanDate(dateToCompare: yesterday) == true {
                
                let priceDic = history.value["price"] as! [String: Any]
                let price = String(describing: priceDic["usd"] as! NSNumber)
                let volumeDic = history.value["volume24"] as! [String: Any]
                let volume = String(describing: volumeDic["usd"] as! NSNumber)
                
                let chartCoinTradeHistory = ChartCoinTradeHistory()
                chartCoinTradeHistory.date = currentDateKey
                chartCoinTradeHistory.price = price
                chartCoinTradeHistory.volume = volume
                self.chartHistories.append(chartCoinTradeHistory)
            }
        }
        self.createJLLineChart()
        
    }
    
    private func createJLLineChart() {
        
        if chartHistories.count == 0 {
            print("counted 0")
            return
        }
        
        
        jlLineChart = JLLineChart(frame: CGRect(x: 0, y: 15, width: self.view.frame.width, height: 180))
        
        let data = JLLineChartData()
        
        data.lineColor = .green
        let set = JLChartPointSet()
        
        for i in 0 ..< self.chartHistories.count {
            
            let point = JLChartPointItem(rawX: self.chartHistories[i].date, andRowY: self.chartHistories[i].volume) as JLChartPointItem
            set.items.add(point)
            
        }
        
        data.sets.add(set)
        
        jlLineChart?.chartDatas = NSMutableArray(object: data)
        
        collectionView.reloadData()
        KRProgressHUD.dismiss()
    }
}

//MARK: - handleImage, Video
extension ChartDetailController {
    
    
    
    //my custom zooming logic
    
    func performZoomingForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                
                let height = (self.startingImageView?.image?.size.height)! / (self.startingImageView?.image?.size.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
                //                zoomOutImageView.removeFromSuperview()
                
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}

//MARK: handle krpullloader delegate
extension ChartDetailController: KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        if type == .loadMore {
            switch state {
                
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    if (self.canScroll) {
                        self.observePostsByTenWith(page: 1)
                    }
                }
                
            default:
                break
            }
            
            return
        }
        
        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""
            
        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = "Pull more. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            } else {
                pullLoadView.messageLabel.text = "Release to refresh. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            }
            
        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = "Updating..."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                self.observePostsByTenWith(page: 2)
            }
        }
        
    }
}



//MARK: setup background

extension ChartDetailController {
    
    fileprivate func setupViews() {
        
        
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(ChartCellHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: -70).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
//        self.collectionView.addSubview(refreshControl)
        
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        collectionView.addPullLoadableView(refreshView, type: .refresh)
        
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        collectionView.addPullLoadableView(loadMoreView, type: .loadMore)
    }

    
    fileprivate func setupNavAndBackground() {
        view.backgroundColor = .white
        self.navigationItem.titleView = nil
        self.navigationItem.title = self.chartCoin?.name
        
        let dismissButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleDismiss))
        dismissButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = dismissButton
        
        let image = UIImage(named: AssetName.addPost.rawValue)?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handlePost))
    }
}

//MARK: handle Post

extension ChartDetailController {
    
    func handlePost() {
        
        print("add post")
        
        let createPostController = CreatePostController()
        createPostController.selectedControllerStatus = .Other
        createPostController.postChildName = self.chartCoin?.symbol
        createPostController.chartDetailControllerDelegate = self
        let navController = UINavigationController(rootViewController: createPostController)
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
}

//MARK: fetch posts Data

extension ChartDetailController {
    
//    fileprivate func observePosts() {
//        
//        let childPost = self.chartCoin?.symbol
//        self.posts.removeAll()
//        
//        let postsRef = Database.database().reference().child("posts").child(childPost!)
//        postsRef.observe(.childAdded, with: { (snapshot) in
//            
//            guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                return
//            }
//            
//            let post = Post(dictionary: dictionary)
//            
//            if let isBlock = post.isBlock {
//                if isBlock == "false" {
//                    self.posts.insert(post, at: 0)
//                }
//            }
//            
//            DispatchQueue.main.async {
//                print("collectionView reloaddata")
//                self.collectionView.reloadData()
////                KRProgressHUD.dismiss()
//            }
//
//            
//        }, withCancel: nil)
//        
//    }
    
    fileprivate func observePostsByTenWith(page: Int) {
        if page == 0 {
            KRProgressHUD.set(style: .black)
            KRProgressHUD.set(activityIndicatorViewStyle: .color(.white))
            KRProgressHUD.show()
        }
        let childName = self.chartCoin?.symbol
        
        var postsRef: DatabaseQuery
        if page == 0 || page == 2 {
            postsRef = Database.database().reference().child("posts").child(childName!).queryOrdered(byChild: "timestamp")
        } else {
            postsRef = Database.database().reference().child("posts").child(childName!).queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        }
        
        var tempPosts = [Post]()
        
        postsRef.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount < 10 {
                self.canScroll = false
            }
            
            //            let groupKeys = snapshot.children.flatMap { $0 as? DataSnapshot }.map { $0.key }
            
            
            let group = DispatchGroup()
            
            
            for child in snapshot.children.reversed() as! [DataSnapshot] {
                
                if let dictionary = child.value as? [String: AnyObject] {
                    let post = Post(dictionary: dictionary)
                    if let timestamp = post.timestamp {
                        self.lastTimestamp = timestamp.intValue - 1 as NSNumber
                    }
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    
                    group.enter()
                    let interstsRef = Database.database().reference().child("interests").child(child.key).child(userId)
                    interstsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        group.leave()
                        
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let status = dictionary["status"] as! String
                            post.status = status
                            if let isBlock = post.isBlock {
                                if isBlock == "false" {
                                    tempPosts.append(post)
                                }
                            }
                        } else {
                            post.status = "none"
                            if let isBlock = post.isBlock {
                                if isBlock == "false" {
                                    tempPosts.append(post)
                                }
                            }
                        }
                    })
                }
            }
            
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    if page == 0 || page == 2 {
                        self.posts.removeAll()
                    }
                    
                    tempPosts.forEach({ (post) in
                        self.posts.append(post)
                    })
                    
                    self.collectionView.reloadData()
                    KRProgressHUD.dismiss()
                    
                    if page == 2 {
                        self.canScroll = true
                    }
                }
            })
        })
    }

}


//MARK: setup handle dismiss

extension ChartDetailController {
    @objc fileprivate func handleDismiss() {
        
        self.navigationController?.popViewController(animated: true)
    }
}
