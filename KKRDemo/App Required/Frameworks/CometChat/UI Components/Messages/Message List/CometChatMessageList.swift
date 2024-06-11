
//  CometChatMessageList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatMessageList: The CometChatMessageList is a view controller with a list of messages for a particular user or group. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.
import MapKit
import UIKit
import WebKit
import AVKit
import AVFoundation
import QuickLook
import MessageUI
import SafariServices
import AudioToolbox
import CometChatPro

enum MessageMode {
    case edit
    case send
    case reply
}

enum HideView {
    case blockedView
    case smartRepliesView
    case editMessageView
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatMessageList: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    
    struct MessageActionsGroup: RowPresentable {
        let string: String = "MessageActions Group"
        let rowVC: PanModalPresentable.LayoutType = MessageActions()
    }
    
    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused
        
        var buttonImage: UIImage {
            switch self {
            case .ready, .recording:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? UIImage(named: "play")!
                } else {}
            case .recorded, .paused:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "play.fill") ?? UIImage(named: "play")!
                } else {}
            case .playing:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? UIImage(named: "play")!
                } else {}
            }
            return UIImage(named: "microphone-circle")!
        }
        
        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }
    
    // MARK: - Declaration of Outlets
    @IBOutlet weak var messageComposer: CometChatMessageComposer!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var reactionView: CometChatLiveReaction!
    @IBOutlet weak var reaction: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var audioNotePauseButton: UIButton!
    @IBOutlet weak var audioNoteSendButton: UIButton!
    @IBOutlet weak var audioNoteDeleteButton: UIButton!
    @IBOutlet weak var audioNoteActionView: UIView!
    @IBOutlet weak var audioNoteTimer: UILabel!
    @IBOutlet weak var audioNoteView: UIView!
    @IBOutlet private var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var textViewBG: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var blockViewButton: UIButton!
    @IBOutlet weak var blockedView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editViewName: UILabel!
    @IBOutlet weak var editViewMessage: UILabel!
    @IBOutlet weak var blockedMessage: UILabel!
    @IBOutlet weak var blockedDetailedMessage: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smartRepliesView: CometChatSmartRepliesPreview!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    @IBOutlet weak var reactionButtonSpace: NSLayoutConstraint!
    @IBOutlet weak var reactionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var attachmentButtonSpace: NSLayoutConstraint!
    @IBOutlet weak var attachmentButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet{
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    weak var pinnedMessageStickyView: PinnedMessageStickyView?
    @IBOutlet weak var gifyButton: UIButton!
    @IBOutlet weak var messageComposerStackView: UIStackView!
    
    @IBOutlet weak var chatBlockView: UIView!
    @IBOutlet weak var chatBlockViewMessageLbl: UILabel!
    @IBOutlet weak var chatBlockStackBottomConstraint: NSLayoutConstraint!
    
    /// The object that manages autocomplete, from InputBarAccessoryView
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: textView, delegate: self)
      manager.delegate = self
      manager.dataSource = self
      return manager
    }()
    
    // MARK: - Declaration of Variables
    
    var currentUser: CometChatPro.User?
    var currentGroup: CometChatPro.Group?
    var currentReaction: LiveReaction = .heart
    var currentEntity: CometChat.ReceiverType?
    var messageRequest:MessagesRequest?
    var memberRequest: GroupMembersRequest?
    var messages: [BaseMessage] = [BaseMessage]()
    var chatMessages: [[BaseMessage]] = [[BaseMessage]]()
    var filteredMessages:[BaseMessage] = [BaseMessage]()
    var selectedMessages:[BaseMessage] = [BaseMessage]()
    var typingIndicator: TypingIndicator?
    var safeArea: UILayoutGuide!
    let modelName = UIDevice.modelName
    var titleView : UIView?
    var buddyStatus: UILabel?
    var isGroupIs : Bool = false
    var refreshControl: UIRefreshControl!
    var membersCount:String?
    var totalHour = Int()
    var totalMinut = Int()
    var totalSecond = 0
    var timer:Timer?
    var isAnimating = false
    var messageMode: MessageMode = .send
    var selectedIndexPath: IndexPath?
    var selectedMessage: BaseMessage?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var isAudioPaused : Bool = false
    private let viewModel = ViewModel()
    var audioURL:URL?
    var fileName : String?
    private var chronometer: Chronometer?
    var curentLocation: CLLocation?
    var isMessageInPrivateEnabled: Bool = false
    let locationManager = CLLocationManager()
    let calendar = Calendar.current
    var lastMessage: BaseMessage?
    var newSectionMessages = [BaseMessage]()
    var isPinnedMessageList: Bool = false //need condition to display pinned messages
    public var onUnpinCallback: ((BaseMessage) -> Void)?
    
    var listOfUsersInGroup = [CometChatPro.GroupMember]()
    var mentionedMemberArray: [String]? = [String]()
    var mentionedMembersId: String?
    var isMentionedMessageList: Bool = false //need condition to scroll to mentioned messages on click of notification
    var messageID: String?
    
    var showCloseBtn = false
    var matchdetail: Matchdetail?
    var istalkCentralClosingMessageShown = false
    
    //handling media message past in TextView
    //var mediaMessagePasteTriggered =
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.audioNotePauseButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
        }
    }
    private var isAdminOrMod: Bool {
//        return self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator
        switch self.currentGroup?.scope {
        case .admin, .moderator:
            return true
        default:
            return false
        }
    }
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        setupSuperview()
        setupDelegates()
        setupTableView()
        registerCells()
        setupMessageComposer()
        setupKeyboard()
        setupRecorder()
        displayPinnedStickyView()
        setupAutoCompleteManager()
        self.addObsevers()
        LoggedInUser.uid = CometChat.getLoggedInUser()?.uid ?? ""
        LoggedInUser.name = CometChat.getLoggedInUser()?.name ?? ""
        
        chatBlockViewMessageLbl.font = .customFont(customFont: .rubikRegular, size: 14)
        chatBlockViewMessageLbl.textColor = .getAppColor(colorName: .white_FFFFFF)
        chatBlockViewMessageLbl.text = FirebaseModelConfig.sharedFirebaseConfig.appStaticText?.talkCentralClosedMessage ?? .blank
        chatBlockView.roundViewCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 8)
        chatBlockView.isHidden = true
        
        if UIDevice.current.hasNotch {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                let bottomSafeAreaHeight = window.safeAreaInsets.bottom
                chatBlockStackBottomConstraint.constant = bottomSafeAreaHeight + 20
            }
        } else {
            chatBlockStackBottomConstraint.constant = 23
        }
    }
    
    private func setupAutoCompleteManager(){
        // Configure AutocompleteManager
        autocompleteManager.register(
          prefix: "@",
          with: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.getAppColor(colorName: .purple_5B2AC5),
            .backgroundColor: UIColor.clear,
          ])

        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space

        // Set plugins
//        messageInputBar.inputPlugins = [autocompleteManager]
        fetchGroupMembers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarColor(color: ThemeManager.currentTheme.primaryNavBarColor)
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        setupDelegates()
        locationAuthStatus()
        hideSystemBackButton(bool: true)
        //gif edit
        textView.mediaPastListner(onTriggred: onPastMessageCalled)
        //gif edit
        
        if messageMode == .reply {
            self.didReplyPressed()
        }
        self.displayPinMessages()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForChatBlockView()
    }
    
    func checkForChatBlockView() {
        if matchdetail?.match?.recent ?? false {
            if let matchEndTime = CommonUtilities.shared.getMatchEndTimeInTimeInterval(matchEndDate: matchdetail?.match?.endDate,
                                                                                       matchEndTime: matchdetail?.match?.endTime,
                                                                                       offSet: matchdetail?.match?.offset) {
                let talkCentralEndTime = matchEndTime.timeInterval + Double(FirebaseModelConfig.sharedFirebaseConfig.talkCentralClosingDuration ?? .zero)
                
                if talkCentralEndTime < matchEndTime.currentDate.timeIntervalSinceNow {
                    messageComposerStackView.isHidden = true
                    chatBlockView.isHidden = false
                } else {
                    if !istalkCentralClosingMessageShown {
                        istalkCentralClosingMessageShown = true
                        if let talkCentralAlertTiming = FirebaseModelConfig.sharedFirebaseConfig.talkCentralAlertTiming,
                           Double(talkCentralAlertTiming) > talkCentralEndTime {
                            KKRToastView.showToast(withMessage: FirebaseModelConfig.sharedFirebaseConfig.appStaticText?.talkCentralClosedMessage ?? .blank)
                        }
                    }
                    messageComposerStackView.isHidden = false
                    chatBlockView.isHidden = true
                }
            }
        } else {
            chatBlockView.isHidden = true
            messageComposerStackView.isHidden = false
        }
    }
    
    private func setupNavBarColor(color: AppColorName) {
        DispatchQueue.main.async {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .getAppColor(colorName: color)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    //gif edit
    lazy var onPastMessageCalled = {
        print("mediaMessagePasteTriggered called")
        
        
        //handling for string
        if UIPasteboard.general.hasStrings {
            self.textView.text = UIPasteboard.general.string
            self.growingTextViewDidChange(self.textView)
            return
        }
        
        
        //handling for urls
        if UIPasteboard.general.hasURLs {
            self.textView.text = UIPasteboard.general.url?.absoluteString
            return
        }
        
        print("url: \(UIPasteboard.general.data(forPasteboardType: "com.compuserve.gif"))")
        
        let gif = UIPasteboard.general.data(forPasteboardType: "com.compuserve.gif")
        let copiedImage = UIPasteboard.general.image
        
        print("copiedImage url: \(copiedImage)")
        
        //presenting new view controller for past item send conformation
        var viewController: SendMediaMessageViewController?
        viewController = SendMediaMessageViewController.loadFromNib()
        viewController?.setData(image: copiedImage, data: gif)
        
        //this will get called when send button pressed, you can directly handle it that view controller as well
        viewController?.onSendMessageTapped = {
            print("onSendMessageTapped called")
            
            if gif != nil {
                
                //we are saving this with random name, you can use you names as well
                let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                let randomIndex = Int.random(in: 0..<letters.count)
                let randomLetter = letters[letters.index(letters.startIndex, offsetBy: randomIndex)]
                let dataURL = gif?.saveToLocalFile(named: "gif\(randomLetter)")
                
                guard let dataURL = dataURL else {
                    print("not dataURL found")
                    return
                }
                
                self.sendMedia(withURL: dataURL, type: .image)
                
                //if gif all done return called
                return
                
            }
            
            guard let copiedImage = copiedImage else {
                print("NO copiedImage FOUND")
                return
            }
            
            let imageURL = copiedImage.imageURL(formate: copiedImage.imageType() ?? "")
            
            guard let imageURL = imageURL else {
                print("image url not found")
                return
            }
            
            print("image url")
            print(imageURL)
            
            //sending the media url
            self.sendMedia(withURL: imageURL, type: .image)
        }
        
        if #available(iOS 15.0, *) {
            if let presentationController = viewController?.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()] /// change to [.medium(), .large()] for a half *and* full screen sheet
            }
            self.present(viewController!, animated: true)
        } else {
            print("handle for lower version")
        }
    }
    //gif edit
    
    private func reloadVisibleCells() {
        guard let visibleRows = tableView?.indexPathsForVisibleRows else { return }
        DispatchQueue.main.async {
            self.tableView?.reloadRows(at: visibleRows, with: .none)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc public func set(conversationWith: AppEntity, type: CometChat.ReceiverType){
        switch type {
        case .user:
            isGroupIs = false
            guard let user = conversationWith as? CometChatPro.User else{ return }
            currentUser = user
            currentEntity = .user
            fetchUserInfo(user: user)
            
            switch (conversationWith as? CometChatPro.User)!.status {
            case .online:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "ONLINE".localized())
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            case .offline:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "OFFLINE".localized())
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            @unknown default:break
            }
            FeatureRestriction.isMessageHistoryEnabled { (success) in
                if success == .enabled {
                    self.refreshMessageList(forID: user.uid ?? "" , type: .user, scrollToBottom: true)
                }
            }
//            self.addCallingButtons(bool: true)
        case .group:
            isGroupIs = true
            guard let group = conversationWith as? CometChatPro.Group else{
                return
            }
            currentGroup = group
            currentEntity = .group
            
            if self.isPinnedMessageList {
                setupNavigationBar(title: "Pinned Messages")
            } else {
                setupNavigationBar(withTitle: group.name ?? "")
                /*
                if group.membersCount == 1 {
                    setupNavigationBar(withSubtitle: "1 " + "MEMBER".localized())
                }else {
                    setupNavigationBar(withSubtitle: "\(group.membersCount) " + "MEMBERS".localized())
                }
                setupNavigationBar(withSubtitle: "tap here for group info")
                 */
                setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
            }

//            fetchGroup(group: group.guid)
            
            FeatureRestriction.isMessageHistoryEnabled { (success) in
                if success == .enabled {
                    if self.isPinnedMessageList {
                        self.displayPinMessages()
                    } else if self.isMentionedMessageList {
                        self.refreshMessageList(forID: group.guid , type: .group, scrollToBottom: false, scrollForCell: true, messageID: self.messageID)
                    }else {
                        self.refreshMessageList(forID: group.guid , type: .group, scrollToBottom: true)
                    }
                }
            }
//            self.addCallingButtons(bool: true)
        @unknown default:
            break
        }
        
    }
    
    private func setupNavigationBar(title: String) {
        DispatchQueue.main.async {
            self.addBackButton(bool: true)
            self.title = title
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.getAppColor(colorName: .white_FFFFFF)]
        }
    }
    
    private func displayPinMessages() {
        guard let group = self.currentGroup else { return }
        let receiverType = "group"
        CometChat.callExtension(slug: "pin-message", type: .get, endPoint: "v1/fetch?receiverType=\(receiverType)&receiver=\(group.guid)", body: nil, onSuccess: { (response) in
            if let pinnedMessages = response?["pinnedMessages"] as? [[String: Any]] {
                var messages = [BaseMessage]()
                pinnedMessages.forEach { (messageDict) in
                    if let pinMessage = CometChat.processMessage(messageDict).0 {
                        messages.append(pinMessage)
                    }
                }
                
                if self.isPinnedMessageList {
                    self.chatMessages.removeAll()
                    self.chatMessages.append(messages.reversed())
                }
//                self.pinMessages = messages
                DispatchQueue.main.async {
                    self.pinnedMessageStickyView?.configureData(pinCount: messages.count, delegate: self)
                    if self.isPinnedMessageList {
                        self.tableView?.reloadData()
                        self.tableView?.restore()
                        self.tableView?.scrollToBottomRow()
//                        self.refreshControl?.endRefreshing()
                    } else {
                        self.reloadVisibleCells()
                    }
                }
            }
              }) { (error) in
                  DispatchQueue.main.async {
                      self.pinnedMessageStickyView?.configureData(pinCount: self.chatMessages.first?.count ?? 0, delegate: self)
                      self.tableView?.reloadData()
//                      self.tableView?.restore()
                      self.refreshControl?.endRefreshing()
                  }
              }
        }
    
    private func displayPinnedStickyView() {
        DispatchQueue.main.async {
            let pinnedMessageStickyView = PinnedMessageStickyView()
            pinnedMessageStickyView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(pinnedMessageStickyView)
            let safeAreaGuide = self.view.safeAreaLayoutGuide
            pinnedMessageStickyView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor).isActive = true
            pinnedMessageStickyView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor).isActive = true
            pinnedMessageStickyView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor).isActive = true
            pinnedMessageStickyView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            self.pinnedMessageStickyView = pinnedMessageStickyView
        }
    }
    
    func set(liveReaction: LiveReaction) {
        switch liveReaction {
        case .heart:
            self.currentReaction = liveReaction
            reaction.setImage(UIImage(named: "heart", in: UIKitSettings.bundle, compatibleWith: nil), for: .normal)
            reactionView.image1 = UIImage(named: "heart", in: UIKitSettings.bundle, compatibleWith: nil)
        case .thumbsup:
            self.currentReaction = liveReaction
            reaction.setImage(UIImage(named: "thumbsup", in: UIKitSettings.bundle, compatibleWith: nil), for: .normal)
            reactionView.image1 = UIImage(named: "thumbsup", in: UIKitSettings.bundle, compatibleWith: nil)
        }
    }
    
    
    // MARK: - CometChatPro Instance Methods
    
    
    /**
     This method group the new message as per timestamp and append it on UI
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addNewGroupedMessage(messages: [BaseMessage]){
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localized())
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.hide(view: .smartRepliesView, true)
                strongSelf.tableView?.insertSections([0], with: .top)
                let lastSection = strongSelf.tableView?.numberOfSections
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection ?? 0].count - 1, section: lastSection ?? 0)], with: .automatic)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
            }
        }
    }
    
    /**
     This method groups the  messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupMessages(messages: [BaseMessage]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localized())
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async{  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    /**
     This method groups the  previous messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    
    private func groupPreviousMessages(messages: [BaseMessage]){
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        var sortedKeys = groupedMessages.keys.sorted()
        sortedKeys = sortedKeys.reversed()
        sortedKeys.forEach { (key) in
            var values = groupedMessages[key]
            values = values?.reversed()
            values?.forEach { (baseMessage) in
                if let firstMessage = self.chatMessages[0].first {
                    if String().compareDates(newTimeInterval: firstMessage.sentAt, currentTimeInterval: baseMessage.sentAt)   {
                        self.chatMessages[0].insert( baseMessage , at: 0)
                    } else {
                        newSectionMessages.append(baseMessage)
                        self.chatMessages.insert( newSectionMessages  , at: 0)
                        newSectionMessages.removeAll()
                    }
                }
            }

            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    /**
     This method fetches the older messages from the server using `MessagesRequest` class.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: {  [weak self] (fetchedMessages) in
            guard let strongSelf = self else { return }
            if fetchedMessages?.count == 0 {
                DispatchQueue.main.async {
                    strongSelf.refreshControl?.endRefreshing()
                }
            }
            guard let messages = fetchedMessages else { return }
            if fetchedMessages?.count != 0 && messages.count == 0 {
                if let request = strongSelf.messageRequest {
                    self?.fetchPreviousMessages(messageReq: request)
                }
            }
            guard let lastMessage = messages.last else { return }
            strongSelf.lastMessage = lastMessage
            if strongSelf.isGroupIs == true {
                CometChat.markAsDelivered(baseMessage: lastMessage)
                CometChat.markAsRead(baseMessage: lastMessage)
            }else{
                CometChat.markAsDelivered(baseMessage: lastMessage)
                CometChat.markAsRead(baseMessage: lastMessage)
            }
            var oldMessages = [BaseMessage]()
            for msg in messages{ oldMessages.append(msg) }
            var oldMessageArray =  oldMessages
            oldMessageArray.sort { (obj1, obj2) -> Bool in
                return (obj1.sentAt) < (obj2.sentAt)
            }
            strongSelf.groupPreviousMessages(messages: oldMessageArray)
            
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    /**
     This method refreshes the  messages  using `MessagesRequest` class.
     - Parameters:
     - forID: This specifies a string value which takes `uid` or `guid`.
     - type: This specifies `ReceiverType` Object which can be `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func refreshMessageList(forID: String, type: CometChat.ReceiverType, scrollToBottom: Bool, scrollForCell: Bool? = nil, messageID: String? = nil){
        chatMessages.removeAll()
        messages.removeAll()
        
        switch type {
        case .user:
            
            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                switch success {
                
                case .enabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(categories: MessageFilter.fetchMessageCategoriesForUser()).set(types: MessageFilter.fetchMessageTypesForUser()).hideReplies(hide: true).hideDeletedMessages(hide: true).set(limit: 30).build()
                case .disabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(categories: MessageFilter.fetchMessageCategoriesForUser()).set(types: MessageFilter.fetchMessageTypesForUser()).hideReplies(hide: true).set(limit: 30).build()
                }
            }
            
            messageRequest?.fetchPrevious(onSuccess: { [weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
                if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                strongSelf.lastMessage = lastMessage
                CometChat.markAsDelivered(baseMessage: lastMessage)
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.messages.append(contentsOf: messages)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid}
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            if let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage) {
                                if !titles.isEmpty {
                                    strongSelf.smartRepliesView.set(titles: titles)
                                    strongSelf.hide(view: .smartRepliesView, false)
                                }else{
                                    strongSelf.hide(view: .smartRepliesView, true)
                                }
                            }
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .user)
        case .group:
            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                switch success {
                case .enabled: 
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(categories:MessageFilter.fetchMessageCategoriesForGroups()).set(types: MessageFilter.fetchMessageTypesForGroup()).hideReplies(hide: true).hideDeletedMessages(hide: true).set(limit: 30).build()
                case .disabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(categories:MessageFilter.fetchMessageCategoriesForGroups()).set(types: MessageFilter.fetchMessageTypesForGroup()).hideReplies(hide: true).hideDeletedMessages(hide: false).set(limit: 30).build()
                }
            }
            
            messageRequest?.fetchPrevious(onSuccess: {[weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
                if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                strongSelf.lastMessage = lastMessage
                CometChat.markAsDelivered(baseMessage: lastMessage)
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.messages.append(contentsOf: messages)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid }
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            if let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage) {
                                if !titles.isEmpty {
                                    strongSelf.smartRepliesView.set(titles: titles)
                                    strongSelf.hide(view: .smartRepliesView, false)
                                }else{
                                    strongSelf.hide(view: .smartRepliesView, true)
                                }
                            }
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                    if scrollForCell ?? false {
                        for message in messages {
                            if message.messageCategory == .custom {
                                var customMessage = message as? CustomMessage
                                if customMessage?.type == "extension_poll" {
                                    if "\(customMessage?.customData?["id"])" == messageID {
                                        if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.id == customMessage?.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                                            strongSelf.tableView?.scrollToRow(at: indexpath, at: .top, animated: false)
                                        }
                                    }
                                }
                            } else {
                                    if let indexpath = strongSelf.chatMessages.indexPath(where: {"\($0.id)" == messageID}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                                        strongSelf.tableView?.scrollToRow(at: indexpath, at: .top, animated: false)
                                    }
                            }
                        }
                    }
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .group)
        @unknown default:
            break
        }
    }
    
    //Scroll to specific message on click of notification
//    private func scrollToMessageRedirection(messages: [CometChatPro.BaseMessage]) -> IndexPath {
//        
//        if messages.count != 0 {
//            for message in messages {
//                if message.messageCategory == .custom {
//                    var customMessage = message as? CustomMessage
//                    if customMessage?.type == "extension_poll" {
//                        if "\(customMessage?.customData?["id"])" == messageID {
//                            if let indexpath = self.chatMessages.indexPath(where: {$0.id == customMessage?.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
//                                return indexpath
//                            }
//                        }
//                    }
//                } else {
//                        if let indexpath = self.chatMessages.indexPath(where: {"\($0.id)" == messageID}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
//                            return indexpath
//                        }
//                }
//            }
//        }
//        return IndexPath(row: 0, section: 0)
//    }
    
    /**
     This method fetches the  user information for particular user.
     - Parameter user: This specifies a  `User` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchUserInfo(user: CometChatPro.User){
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { [weak self] (user) in
            guard let strongSelf = self else { return }
            if  user?.blockedByMe == true {
                if let name = strongSelf.currentUser?.name {
                    DispatchQueue.main.async {
                        strongSelf.hide(view: .blockedView, false)
                        strongSelf.blockedMessage.text = "YOU'VE_BLOCKED".localized() + "  \(String(describing: name.capitalized))"
                    }
                }
            }
        }) { (error) in
            
        }
    }
    
    
    /**
     This method fetches list of  group members  for particular group.
     - Parameter group: This specifies a  `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchGroup(group: String){
        CometChat.getGroup(GUID: group, onSuccess: { [weak self] (group) in
            guard let strongSelf = self else { return }
            if  group.membersCount == 1 {
                strongSelf.setupNavigationBar(withTitle: group.name ?? "")
                strongSelf.setupNavigationBar(withSubtitle: "tap here for group info")
                strongSelf.setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
                strongSelf.membersCount = "1 " + "MEMBER".localized()
            }else {
                strongSelf.setupNavigationBar(withTitle: group.name ?? "")
                strongSelf.setupNavigationBar(withSubtitle: "tap here for group info")
                strongSelf.membersCount = "\(group.membersCount) " + " " + "MEMBERS".localized()
                strongSelf.setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
            }
        }) { (error) in
        }
    }
    
    /**
     This method detects the extension is enabled or not for smart replies and link preview.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func didExtensionDetected(message: BaseMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
        
        if let stickerMessage = message as? CustomMessage , let type = stickerMessage.type, type == "extension_sticker" {
            
            detectedExtension = .sticker
            
        }
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["profanity-filter"] as? [String : Any] {

            detectedExtension = .profanityFilter
            
        }
    
         if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            
            detectedExtension = .sentimentAnalysis
        }
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["smart-reply"] as? [String : Any] {
            
            detectedExtension = .smartReply
            
        }
      
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], let _ = linkArray[safe: 0] {
            
            detectedExtension = .linkPreview
            
        }
        
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["message-translation"] as? [String : Any] {
            
            detectedExtension = .messageTranslation
            
        }
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            
            detectedExtension = .thumbnailGeneration
            
        }
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["image-moderation"] as? [String : Any] {
            
            detectedExtension = .imageModeration
            
        }
        
        if let metaData = message.metaData,  metaData["reply-message"] as? [String : Any] != nil {
            detectedExtension = .reply
        }
        
        return detectedExtension ?? .none
    }
    
    
    /**
     This method parse the smart replies data from `TextMessage` Object.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func parseSmartRepliesMessages(message: TextMessage) -> [String]? {
        var replyMessages: [String] = [String]()
        if  let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let smartReply = cometChatExtension["smart-reply"] as? [String : Any] {
            
            if let positive = smartReply["reply_positive"] {
                replyMessages.append(positive as! String)
            }
            if let neutral = smartReply["reply_neutral"] {
                replyMessages.append(neutral as! String)
            }
            if let negative = smartReply["reply_negative"] {
                replyMessages.append(negative as! String)
            }
        }
        return replyMessages
    }
    
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method setup the view to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupSuperview() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatMessageList", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
        self.blockViewButton.setTitle("UNBLOCK".localized(), for: .normal)
        self.blockedDetailedMessage.text = "YOU_CANT_MESSAGE_THEM".localized()
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
        documentPicker.delegate = self
        MessageActions.actionsDelegate = self
        smartRepliesView.smartRepliesDelegate = self
        CometChatThreadedMessageList.threadDelegate = self
        CometChatStickerKeyboard.stickerDelegate = self
        CometChatMessageReactions.cometChatMessageReactionsDelegate = self
        quickLook.dataSource = self
    }
    
    
    func setupRecorder(){
        self.viewModel.askAudioRecordingPermission()
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let strongSelf = self, strongSelf.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            strongSelf.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        self.viewModel.audioDidFinish = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.currentState = .recorded
            strongSelf.audioVisualizationView.stop()
        }
    }
    
    /**
     This method observers for the notifications of certain events.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addObsevers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserUnblocked(_:)), name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didThreadDeleted(_:)), name: NSNotification.Name(rawValue: "didThreadDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
       
    }
    
    @objc func appMovedToForeground() {
        if !CometChat.backgroundTaskEnabled() {
             if let user = currentUser?.uid {
                self.refreshMessageList(forID: user, type: .user, scrollToBottom: true)
            }else if let group = currentGroup?.guid {
                self.refreshMessageList(forID: group, type: .group, scrollToBottom: true)
            }
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didThreadDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /**
     This method triggers when group is deleted.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     This method triggers when user has been unblocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserUnblocked(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hide(view: .blockedView, true)
        }
    }
    
    /**
     This method triggers when user has been blocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserBlocked(_ notification: NSNotification) {
        if let name = notification.userInfo?["name"] as? String {
            self.hide(view: .blockedView, false)
            blockedMessage.text =
                "YOU'VE_BLOCKED".localized() + " \(String(describing: name.capitalized))"
        }
    }
    
    /**
     This method refreshes group details.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let guid = notification.userInfo?["guid"] as? String {
            self.refreshMessageList(forID: guid, type: .group, scrollToBottom: false)
            self.fetchGroup(group: guid)
        }
    }
    
    @objc func didThreadDeleted(_ notification: NSNotification) {
        if let user = currentUser?.uid {
            self.refreshMessageList(forID: user, type: .user, scrollToBottom: false)
        }else if let group = currentGroup?.guid {
            self.refreshMessageList(forID: group, type: .group, scrollToBottom: false)
        }
    }
    
    /**
     This method hides system defaults back button.
     - Parameter bool: specified `Bool` value.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hideSystemBackButton(bool: Bool) {
        if self.navigationController != nil {
            if bool == true {
                self.navigationItem.hidesBackButton = true
            }
        }
    }
    
    /**
     This method setup navigationBar title for messageList viewController.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withTitle title: String){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.navigationController != nil {
                strongSelf.addBackButton(bool: true)
                strongSelf.navigationItem.largeTitleDisplayMode = .never
                let buddyName = UILabel()
                buddyName.numberOfLines = 2
                if UIDevice.current.userInterfaceIdiom == .pad {
                    strongSelf.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (strongSelf.navigationController?.navigationBar.bounds.size.width)!, height: 50))
                    buddyName.frame = CGRect(x:0,y: 3,width: 220 ,height: 21)
                    strongSelf.buddyStatus = UILabel(frame: CGRect(x:0,y: (strongSelf.titleView?.frame.origin.y ?? 0.0) + 22,width: 160, height: 21))
                }else{
                    strongSelf.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (strongSelf.navigationController?.navigationBar.bounds.size.width)! - 160, height: 50))
                    buddyName.frame = CGRect(x:0,
                                             y: (strongSelf.titleView?.frame.origin.y ?? 3),
                                             width: (strongSelf.navigationController?.navigationBar.bounds.size.width)! - 160, height: 45)
                    strongSelf.buddyStatus = UILabel(frame: CGRect(x:0,y: (strongSelf.titleView?.frame.origin.y ?? 0.0) + 22,width: 160, height: 21))
                }
                strongSelf.buddyStatus?.textColor = .getAppColor(colorName: .grey_EFEFEF)
                strongSelf.buddyStatus?.textAlignment = NSTextAlignment.left
                strongSelf.navigationItem.titleView = strongSelf.titleView
                if #available(iOS 13.0, *) {
                    buddyName.textColor = .getAppColor(colorName: .white_FFFFFF)
                } else {
                    buddyName.textColor = .getAppColor(colorName: .white_FFFFFF)
                }
                buddyName.text = title
                switch ThemeManager.getCurrentTheme(){
                case .KKR:
                    buddyName.font = .customFont(customFont: .rubikBold, size: 12)
                    strongSelf.buddyStatus?.font = .customFont(customFont: .rubikLight, size: 10)
                case .TKR, .ADKR, .LAKR:
                    buddyName.font = .customFont(customFont: .urbanistBold, size: 16)
                    strongSelf.buddyStatus?.font = .customFont(customFont: .robotoMedium, size: 12)
                }
                buddyName.font = .customFont(customFont: .urbanistBold, size: 16)
                buddyName.textAlignment = NSTextAlignment.left
                strongSelf.titleView?.addSubview(buddyName)
                FeatureRestriction.isUserPresenceEnabled { (success) in
                    switch success {
                    case .enabled:
                        strongSelf.titleView?.addSubview(strongSelf.buddyStatus!)
                    case .disabled:
                        
                        if strongSelf.currentUser != nil  {
                            buddyName.frame = CGRect(x:0,y: 10,width: 200 ,height: 21)
                        }else if strongSelf.currentGroup != nil {
                            strongSelf.titleView?.addSubview(strongSelf.buddyStatus!)
                        }
                    }
                }
                strongSelf.titleView?.center = CGPoint(x: 0, y: 0)
                let tapOnTitleView = UITapGestureRecognizer(target: strongSelf, action: #selector(strongSelf.didPresentDetailView(tapGestureRecognizer:)))
                strongSelf.titleView?.isUserInteractionEnabled = true
                strongSelf.titleView?.addGestureRecognizer(tapOnTitleView)
            }
        }
    }
    
    
    /**
     This method adds back button in navigation bar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addBackButton(bool: Bool) {
        if showCloseBtn {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.hidesBackButton = true
            let frame = CGRect(x: -15, y: 0, width: 45, height: 45)
            let customView = UIView()
            customView.frame = frame
            
            let backButton = UIButton(type: .custom)
            backButton.frame = frame
            backButton.setImage(.getAppImage(imageName: .back_icon)
                .withRenderingMode(.alwaysOriginal), for: .normal)
            backButton.addTarget(self, action: #selector(self.didBackButtonPressed(_:)), for: .touchUpInside)
            customView.addSubview(backButton)
            
            let backBarButtonItem = UIBarButtonItem(customView: customView)
            navigationItem.leftBarButtonItem = backBarButtonItem
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    
    private func addCloseButton(bool: Bool) {
        if bool {
            navigationItem.hidesBackButton = true
            let frame = CGRect(x: 15, y: 0, width: 45, height: 45)
            let customView = UIView()
            customView.frame = frame
            
            let closeButton = UIButton(type: .custom)
            closeButton.frame = frame
            closeButton.setImage(.getAppImage(imageName: .icon_close)
                .withRenderingMode(.alwaysOriginal), for: .normal)
            closeButton.addTarget(self, action: #selector(self.didBackButtonPressed(_:)), for: .touchUpInside)
            customView.addSubview(closeButton)
            
            let backBarButtonItem = UIBarButtonItem(customView: customView)
            navigationItem.rightBarButtonItem = backBarButtonItem
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    
    /**
     This method triggeres when user pressed back button.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didBackButtonPressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        //        tableView = nil
        //        tableView?.removeFromSuperview()
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        case false:
            
            if isMessageInPrivateEnabled == true {
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        }
        
    }
    
    @IBAction func didCancelButtonPressed(_ sender: UIButton) {
        self.didPreformCancel()
        hide(view: .editMessageView, true)
    }
    
    @IBAction func didAudioNoteDeletePressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            self.audioNoteView.isHidden = true
            self.audioNoteActionView.isHidden = true
            if #available(iOS 13.0, *) {
                self.audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        })
    }
    
    @IBAction func didAudioNoteSendPressed(_ sender: Any) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        if let url = self.viewModel.currentAudioRecord?.audioFilePathLocal?.absoluteURL {
            let newURL = "file://" + url.absoluteString
            self.sendMedia(withURL: newURL, type: .audio)
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                AudioServicesPlayAlertSound(SystemSoundID(1519))
                self.audioNoteView.isHidden = true
                self.audioNoteActionView.isHidden = true
            })
            if #available(iOS 13.0, *) {
                audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        }
    }
    
    
    @IBAction func didAudioNotePausePressed(_ sender: UIButton) {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil
            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try self.viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
    }
    
    
    private func didPreformCancel(){
        self.selectedMessages.removeAll()
        self.selectedMessage = nil
        self.selectedIndexPath = nil
        self.tableView?.isEditing = false
        self.tableView?.reloadData()
        addBackButton(bool: true)
        
        if let user =  currentUser {
            self.setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
        }
        
        if let group = currentGroup {
            self.setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter subtitle: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withSubtitle subtitle: String){
        DispatchQueue.main.async {
            self.buddyStatus?.text = subtitle
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter URL: This spefies a string value which takes URL and loads the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withImage URL: String, name: String, bool: Bool){
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItems?.removeAll()
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.addBackButton(bool: true)
            self.addCloseButton(bool: self.showCloseBtn)
            
            let avatarView = UIView(frame: CGRect(x: 0 , y: 0, width: 34, height: 34))
            avatarView.backgroundColor = UIColor.clear
            avatarView.layer.masksToBounds = true
            let avatar = CometChatAvatar(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
            avatarView.layer.borderWidth = 1
            avatar.borderWidth = 0
            avatarView.layer.cornerRadius = 17
            if URL.isEmpty {
                if let defaultFCGroupAvatar = FirebaseModelConfig.sharedFirebaseConfig.appStaticImages?.defaultFCGroupAvatar {
                    avatar.set(image: defaultFCGroupAvatar)
                }
                // avatar.image = .getAppImage(imageName: .fanChatDefaultGroupIcon)
                avatarView.layer.borderColor = UIColor.clear.cgColor
                avatarView.backgroundColor = UIColor.clear
            } else {
                avatar.set(image: URL)
                avatarView.layer.borderColor = UIColor.getAppColor(colorName: .purple_340D53).cgColor
            }
            avatarView.addSubview(avatar)
            let avatarViewButton = UIBarButtonItem(customView: avatarView)
            let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
            avatarView.isUserInteractionEnabled = true
            avatarView.addGestureRecognizer(tapOnAvatar)
            if bool == true {
                if self.navigationItem.leftBarButtonItems == nil {
                    self.navigationItem.leftBarButtonItem = avatarViewButton
                } else {
                    self.navigationItem.leftBarButtonItems?.append(avatarViewButton)
                }
            }
        }
    }
    
    private func addCallingButtons(bool: Bool){
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            let videoCall = UIButton(type: .custom)
            videoCall.frame = CGRect(x: 0, y: 0, width: 32, height: 30)
            var videoCallIcon = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)
            if #available(iOS 13.0, *) {
                videoCallIcon = videoCallIcon?.withRenderingMode(.alwaysTemplate)
            } else {
            }
            videoCall.tintColor = UIKitSettings.primaryColor
            videoCall.setImage(videoCallIcon, for: .normal)
            videoCall.addTarget(self, action: #selector(self.didPressedOnVideoCall), for: .touchUpInside)
            
            let audioCall = UIButton(type: .custom)
            audioCall.frame = CGRect(x: 8, y: 0, width: 32, height: 30)
            var audioCallIcon = UIImage(named: "messages-audio-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            if #available(iOS 13.0, *) {
                audioCallIcon = audioCallIcon?.withRenderingMode(.alwaysTemplate)
            } else {}
            audioCall.setImage(audioCallIcon, for: .normal)
            audioCall.tintColor = UIKitSettings.primaryColor
            audioCall.addTarget(self, action: #selector(self.didPressedOnAudioCall), for: .touchUpInside)
            
            
            let infoButton = UIButton(type: .custom)
            infoButton.frame = CGRect(x: 8, y: 0, width: 32, height: 30)
            var infoIcon = UIImage(named: "messages-info.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            if #available(iOS 13.0, *) {
                infoIcon = infoIcon?.withRenderingMode(.alwaysTemplate)
            } else {}
            infoButton.setImage(infoIcon, for: .normal)
            infoButton.tintColor = UIKitSettings.primaryColor
            infoButton.addTarget(self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)), for: .touchUpInside)
            
            let addMemberButton = UIButton(type: .custom)
            addMemberButton.frame = CGRect(x: 8, y: 0, width: 32, height: 30)
            var addMemberIcon = UIImage.getAppImage(imageName: .add_member_icon)
            addMemberButton.setImage(addMemberIcon, for: .normal)
            addMemberButton.addTarget(self, action: #selector(self.didPresentAddMemberView(tapGestureRecognizer:)), for: .touchUpInside)
            
            let deleteMessageButton = UIButton(type: .custom)
            deleteMessageButton.frame = CGRect(x: 8, y: 0, width: 32, height: 30)
            var deleteIcon = UIImage.getAppImage(imageName: .message_delete_icon)
            deleteMessageButton.setImage(deleteIcon, for: .normal)
            deleteMessageButton.addTarget(self, action: #selector(self.didPressDeleteButton(tapGestureRecognizer:)), for: .touchUpInside)
            
            
            let videoCallButton = UIBarButtonItem(customView: videoCall)
            let audioCallButton = UIBarButtonItem(customView: audioCall)
            let detailInfoButton = UIBarButtonItem(customView: infoButton)
            
            let addMemberBarButton = UIBarButtonItem(customView: addMemberButton)
            let deleteBarButton = UIBarButtonItem(customView: deleteMessageButton)

            if bool == true {
                var callingButtons: [UIBarButtonItem] = []
                
                if self.isAdminOrMod && !self.isPinnedMessageList {
                    callingButtons = [addMemberBarButton]
                }
                
                FeatureRestriction.isOneOnOneAudioCallEnabled { (success) in
                    if self.currentUser != nil && success == .enabled {
                        callingButtons.append(audioCallButton)
                    }
                }
                FeatureRestriction.isOneOnOneVideoCallEnabled { (success) in
                    if self.currentUser != nil && success == .enabled {
                        callingButtons.append(videoCallButton)
                    }
                }
                
                /*
                FeatureRestriction.isGroupVideoCallEnabled { (success) in
                    if self.currentGroup != nil && success == .enabled {
                        print("FeatureRestriction 4")
                        callingButtons.append(videoCallButton)
                    }
                }
                */
                self.navigationItem.setRightBarButtonItems(callingButtons, animated: true)
            }
        }
    }
    
    @objc func didPressedOnAudioCall() {
        if let user = self.currentUser {
            CometChatCallManager().makeCall(call: .audio, to: user)
            self.refreshMessageList(forID: user.uid ?? "", type: .user, scrollToBottom: false)
        }
    }
    
    @objc func didPressedOnVideoCall() {
        
        if let user = self.currentUser {
            CometChatCallManager().makeCall(call: .video, to: user)
            self.refreshMessageList(forID: user.uid ?? "", type: .user, scrollToBottom: false)
        }
        
        if let group = currentGroup {
            let lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            let sessionID = group.guid
            let videoMeeting = CustomMessage(receiverUid: group.guid, receiverType: .group, customData: ["sessionID":sessionID, "callType":"video"], type: "meeting")
            videoMeeting.metaData = ["pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "HAS_INITIATED_GROUP_VIDEO_CALL"]
            
            CometChat.sendCustomMessage(message: videoMeeting, onSuccess: { (message) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.lastMessage = message
                    if strongSelf.chatMessages.count == 0 {
                        strongSelf.addNewGroupedMessage(messages: [message])
                        strongSelf.filteredMessages.append(message)
                    }else{
                        strongSelf.chatMessages[lastSection].append(message)
                        strongSelf.filteredMessages.append(message)
                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                        strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.scrollToBottomRow()
                        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                    }
                    let meetingView = CometChatMeetingView()
                    meetingView.modalPresentationStyle = .fullScreen
                    meetingView.performCall(with: sessionID, type: .video)
                    strongSelf.present(meetingView, animated: true, completion: nil)
                    strongSelf.refreshMessageList(forID: group.guid ?? "", type: .group, scrollToBottom: false)
                }
            }) { (error) in
                
            }
        }
    }
    
    
    /**
     This method triggers when user taps on AvatarView in Navigation var
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didPresentDetailView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            guard let user = currentUser else { return }
            if self.messageComposer.frame.origin.y != 0 { dismissKeyboard() }
            let userDetailView = CometChatUserDetails()
            let navigationController = UINavigationController(rootViewController: userDetailView)
            userDetailView.set(user: user)
            userDetailView.isPresentedFromMessageList = true
            self.present(navigationController, animated: true, completion: nil)
        case .group:
//             //Custom Fan Club Detail created by Siddhesh
//            guard let group = currentGroup else { return }
//            let clubDetailsVC: ClubDetailsVC = .instantiateController(storyboard: .storyboard_fanclub)
//            clubDetailsVC.set(group: group)
//            self.navigationController?.pushViewController(clubDetailsVC, animated: true)
            
            guard let group = currentGroup else { return }
            let groupDetailView = CometChatGroupDetail()
            let navigationController = UINavigationController(rootViewController: groupDetailView)
            groupDetailView.set(group: group)
            self.present(navigationController, animated: true, completion: nil)
            
        @unknown default:break
        }
    }
    
    
    @objc func didPresentAddMemberView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            break
        case .group:
            guard let group = currentGroup else { return }
            let addClubMemberVC: AddClubMemberVC = .instantiateController(storyboard: .storyboard_fanclub)
            addClubMemberVC.set(group: group)
            self.navigationController?.pushViewController(addClubMemberVC, animated: true)
        @unknown default:break
        }
    }

    @objc func didPressDeleteButton(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            break
        case .group:
//            self.deleteSelectedMessage(messageId: self.selectedMessage?.id ?? 0)
            self.didDeletePressed()
           break
        @unknown default:break
        }
    }
    
    func deleteSelectedMessage(messageId: Int) {
        guard let message = selectedMessage else { return }
        guard let indexPath = selectedIndexPath else { return }
      
        CometChat.delete(messageId: messageId, onSuccess: { (deletedMessage) in
            self.selectedMessage = nil
            self.selectedIndexPath = nil
            
            let textMessage:BaseMessage = (deletedMessage as? ActionMessage)?.actionOn as! BaseMessage
            
            if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == textMessage.id}) {
                self.chatMessages[indexPath.section][row] = textMessage
            }
            
            DispatchQueue.main.async {
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                self.didPreformCancel()
            }
            print("message deleted successfully. \(deletedMessage)")
        }) { (error) in
            
            print("delete message failed with error: \(error.errorDescription)")
        }
    }
    
    /**
     This method triggers when user long press on Particular message bubble.
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer) {
        //        if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
        //            if sender.state == .began {
        //                let touchPoint = sender.location(in: self.tableView)
        //                if let indexPath = self.tableView?.indexPathForRow(at: touchPoint) {
        //                    self.selectedIndexPath = indexPath
        //
        //                    if  let selectedCell = self.tableView?.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
        //                        self.selectedMessage = message
        //                    }
        //
        //                    if  let selectedCell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message = selectedCell.textMessage {
        //                        self.selectedMessage = message
        //                    }
        //                }
        //            }
        
        //            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //            alert.addAction(UIAlertAction(title: "Delete Messsage", style: .destructive , handler:{ (UIAlertAction) in
        //                self.didDeletePressed()
        //            }))
        //
        //            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction) in
        //                self.didPreformCancel()
        //            }))
        //
        //            self.present(alert, animated: true, completion: {
        //                print("completion block")
        //            })
        //        }
        
        if self.chatBlockView.isHidden {
            
            if sender.state == .began {
                
                var actions: [MessageAction] = []
                let group: RowPresentable = MessageActionsGroup()
                
                FeatureRestriction.isReactionsEnabled{ (success) in
                    if success == .enabled {
                        actions.append(.reaction)
                    }
                }
                
                FeatureRestriction.isThreadedMessagesEnabled { (success) in
                    if success == .enabled {
                        actions.append(.thread)
                    }
                }
                
                FeatureRestriction.isMessageRepliesEnabled { (success) in
                    if success == .enabled {
                        actions.append(.reply)
                    }
                }
                
                FeatureRestriction.isShareCopyForwardMessageEnabled { (success) in
                    if success == .enabled {
                        actions.append(.copy)
                        actions.append(.forward)
                        actions.append(.share)
                    }
                }
                
                let touchPoint = sender.location(in: self.tableView)
                if let indexPath = tableView?.indexPathForRow(at: touchPoint) {
                    self.selectedIndexPath = indexPath
                    self.addBackButton(bool: false)
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble {
                        selectedCell.isEditing = true
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.textMessage
                        
                        FeatureRestriction.isEditMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.edit)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                        FeatureRestriction.isMessageTranslationEnabled { (success) in
                            if success == .enabled {
                                actions.append(.messageTranslate)
                            }
                        }
                    }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.textMessage
                        
                        FeatureRestriction.isEditMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.edit)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                        FeatureRestriction.isMessageTranslationEnabled { (success) in
                            if success == .enabled {
                                actions.append(.messageTranslate)
                            }
                        }
                        
                    }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderLocationMessageBubble {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = selectedCell.locationMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //
                    //                }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderMeetingMessageBubble {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = selectedCell.meetingMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //
                    //
                    //                }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderPollMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.pollMessage
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                    }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = selectedCell.fileMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //
                    //
                    //                }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderCollaborativeMessageBubble, let whiteboardMessage = selectedCell.whiteboardMessage {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = whiteboardMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //                }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderCollaborativeMessageBubble , let writeboardMessage = selectedCell.writeboardMessage {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = writeboardMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //                }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.mediaMessage
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                    }
                    
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //                    self.selectedMessage = selectedCell.audioMessage
                    //
                    //                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                        if success == .enabled {
                    //                            actions.append(.delete)
                    //                        }
                    //                    }
                    //                }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.linkPreviewMessage
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                        FeatureRestriction.isMessageTranslationEnabled { (success) in
                            if success == .enabled {
                                actions.append(.messageTranslate)
                            }
                        }
                        
                    }
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.mediaMessage
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                    }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        self.selectedMessage = selectedCell.stickerMessage
                        
                        FeatureRestriction.isDeleteMessageEnabled { (success) in
                            if success == .enabled {
                                actions.append(.delete)
                            }
                        }
                        
                    }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                    
                                    FeatureRestriction.isMessageTranslationEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.messageTranslate)
                                        }
                                    }
                                }
                            case .disabled:
                                FeatureRestriction.isMessageTranslationEnabled { (success) in
                                    if success == .enabled {
                                        actions.append(.messageTranslate)
                                    }
                                }
                            }
                        }
                        self.selectedMessage = selectedCell.textMessage
                    }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                                
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                    
                                    FeatureRestriction.isMessageTranslationEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.messageTranslate)
                                        }
                                    }
                                    
                                }
                            case .disabled:
                                
                                FeatureRestriction.isMessageTranslationEnabled { (success) in
                                    if success == .enabled {
                                        actions.append(.messageTranslate)
                                    }
                                }
                                
                                
                            }
                        }
                        self.selectedMessage = selectedCell.textMessage
                        
                    }
                    
                    if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                                
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                }
                            case .disabled: break
                                
                            }
                        }
                        self.selectedMessage = selectedCell.mediaMessage
                        
                    }
                    
                    
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                                
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                }
                            case .disabled: break
                                
                            }
                        }
                        self.selectedMessage = selectedCell.stickerMessage
                        
                    }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                                
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                }
                            case .disabled: break
                                
                            }
                        }
                        self.selectedMessage = selectedCell.mediaMessage
                        
                    }
                    
                    /*  if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                     
                     FeatureRestriction.isMessageInPrivateEnabled { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.messageInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.replyInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                     switch success {
                     
                     case .enabled:
                     if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                     
                     FeatureRestriction.isDeleteMessageEnabled { (success) in
                     if success == .enabled {
                     actions.append(.delete)
                     }
                     }
                     
                     FeatureRestriction.isMessageTranslationEnabled { (success) in
                     if success == .enabled {
                     actions.append(.messageTranslate)
                     }
                     }
                     }
                     case .disabled:
                     
                     FeatureRestriction.isMessageTranslationEnabled { (success) in
                     if success == .enabled {
                     actions.append(.messageTranslate)
                     }
                     }
                     }
                     }
                     
                     self.selectedMessage = selectedCell.linkPreviewMessage
                     
                     }
                     
                     if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                     
                     FeatureRestriction.isMessageInPrivateEnabled { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.messageInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.replyInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                     switch success {
                     
                     case .enabled:
                     if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                     
                     FeatureRestriction.isDeleteMessageEnabled { (success) in
                     if success == .enabled {
                     actions.append(.delete)
                     }
                     }
                     
                     }
                     case .disabled: break
                     
                     }
                     }
                     self.selectedMessage = selectedCell.fileMessage
                     
                     }
                     
                     
                     if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                     
                     FeatureRestriction.isMessageInPrivateEnabled { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.messageInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.replyInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                     switch success {
                     case .enabled:
                     if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                     
                     FeatureRestriction.isDeleteMessageEnabled { (success) in
                     if success == .enabled {
                     actions.append(.delete)
                     }
                     }
                     }
                     case .disabled: break
                     
                     }
                     }
                     
                     self.selectedMessage = selectedCell.audioMessage
                     }
                     
                     if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                     AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                     
                     FeatureRestriction.isMessageInPrivateEnabled { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.messageInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                     if success == .enabled && self.currentGroup != nil {
                     actions.append(.replyInPrivate)
                     }
                     }
                     
                     FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                     switch success {
                     case .enabled:
                     if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                     
                     FeatureRestriction.isDeleteMessageEnabled { (success) in
                     if success == .enabled {
                     actions.append(.delete)
                     }
                     }
                     }
                     case .disabled: break
                     
                     }
                     }
                     self.selectedMessage = selectedCell.locationMessage
                     }
                     */
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverMeetingMessageBubble {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //
                    //                    FeatureRestriction.isMessageInPrivateEnabled { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.messageInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.replyInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                    //                        switch success {
                    //                        case .enabled:
                    //                            if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                    //
                    //                                FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                                    if success == .enabled {
                    //                                        actions.append(.delete)
                    //                                    }
                    //                                }
                    //
                    //                            }
                    //                        case .disabled: break
                    //
                    //                        }
                    //                    }
                    //                    self.selectedMessage = selectedCell.meetingMessage
                    //                }
                    
                    if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        FeatureRestriction.isMessageInPrivateEnabled { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.messageInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                            if success == .enabled && self.currentGroup != nil {
                                actions.append(.replyInPrivate)
                            }
                        }
                        
                        FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                            switch success {
                            case .enabled:
                                if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                    
                                    FeatureRestriction.isDeleteMessageEnabled { (success) in
                                        if success == .enabled {
                                            actions.append(.delete)
                                        }
                                    }
                                    
                                }
                            case .disabled: break
                                
                            }
                        }
                        self.selectedMessage = selectedCell.pollMessage
                    }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverCollaborativeMessageBubble, let whiteboardMessage = selectedCell.whiteboardMessage {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //
                    //                    FeatureRestriction.isMessageInPrivateEnabled { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.messageInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.replyInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                    //                        switch success {
                    //                        case .enabled:
                    //                            if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                    //
                    //                                FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                                    if success == .enabled {
                    //                                        actions.append(.delete)
                    //                                    }
                    //                                }
                    //
                    //                            }
                    //                        case .disabled: break
                    //
                    //                        }
                    //                    }
                    //                    self.selectedMessage = whiteboardMessage
                    //                }
                    
                    //                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverCollaborativeMessageBubble, let writeboardMessage = selectedCell.writeboardMessage {
                    //                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    //
                    //                    FeatureRestriction.isMessageInPrivateEnabled { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.messageInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isReplyInPrivateEnabled(completion: ) { (success) in
                    //                        if success == .enabled && self.currentGroup != nil {
                    //                            actions.append(.replyInPrivate)
                    //                        }
                    //                    }
                    //
                    //                    FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                    //                        switch success {
                    //                        case .enabled:
                    //                            if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                    //
                    //                                FeatureRestriction.isDeleteMessageEnabled { (success) in
                    //                                    if success == .enabled {
                    //                                        actions.append(.delete)
                    //                                    }
                    //                                }
                    //
                    //                            }
                    //                        case .disabled: break
                    //
                    //                        }
                    //                    }
                    //                    self.selectedMessage = writeboardMessage
                    //                }
                    
                    FeatureRestriction.isPinMessagesEnabled { (success) in
                        if success == .enabled && self.isAdminOrMod {
                            if self.selectedMessage?.isPinned ?? false {
                                actions.append(.unpinMessage)
                            } else {
                                actions.append(.pinMessage)
                            }
                        }
                    }
                    
                    FeatureRestriction.isMessageInformationEnabled { (success) in
                        if self.currentGroup != nil && success == .enabled {
                            actions.append(.messageInfo)
                        }
                    }
                    
                    (group.rowVC as? MessageActions)?.set(actions: actions)
                    self.presentPanModal(group.rowVC)
                }
            }
            
        }
    }
    
    /**
     This method triggers when user pressed microphone  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMicrophone(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            self.audioNoteView.isHidden = false
            self.audioNoteActionView.isHidden = false
            if self.currentState == .ready {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.viewModel.startRecording { [weak self] soundRecord, error in
                    if let error = error {
                        self?.showAlert(with: error)
                        return
                    }
                    self?.audioNoteDeleteButton.tintColor = .systemGray
                    self?.currentState = .recording
                    self?.chronometer = Chronometer()
                    self?.chronometer?.start()
                    self?.startTimer()
                }
            }
        }else if sender.state == .ended {
            switch self.currentState {
            case .recording:
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.chronometer?.stop()
                self.chronometer = nil
                self.audioNoteDeleteButton.tintColor = .systemRed
                self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
                self.audioVisualizationView.audioVisualizationMode = .read
                do {
                    try self.viewModel.stopRecording()
                    self.currentState = .recorded
                } catch {
                    self.currentState = .ready
                    self.showAlert(with: error)
                }
            case .recorded, .paused:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    let duration = try self.viewModel.startPlaying()
                    self.currentState = .playing
                    self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                    self.audioVisualizationView.play(for: duration)
                } catch {
                    self.showAlert(with: error)
                }
            case .playing:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    try self.viewModel.pausePlaying()
                    self.currentState = .paused
                    self.audioVisualizationView.pause()
                } catch {
                    self.showAlert(with: error)
                }
            default:
                break
            }
        }
    }
    
    func startTimer(){
        self.audioNoteTimer.text = ""
        timer?.invalidate()
        self.totalSecond = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int
        hours = totalSecond / 3600
        minutes = totalSecond / 60
        seconds = totalSecond % 60
        totalSecond = totalSecond + 1
        if currentState == .recording{
            audioNoteTimer.text = "\(hours):\(minutes):\(seconds)"
        }
    }
    /**
     This method setup the tableview to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = .clear
        self.tableView?.setEmptyMessage("LOADING".localized())
//        self.addRefreshControl(inTableView: true)
        self.addRefreshControl(inTableView: !self.isPinnedMessageList)
        self.tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        //         Added Long Press
        let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
        tableView?.addGestureRecognizer(longPressOnMessage)


//        let longPressOnMicrophone = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMicrophone))
//        microphone.addGestureRecognizer(longPressOnMicrophone)
//        microphone.isUserInteractionEnabled = true
    }
    
    
    /**
     This method register All Types of MessageBubble  cells in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func registerCells(){
        
        let CometChatReceiverTextMessageBubble  = UINib.init(nibName: "CometChatReceiverTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverTextMessageBubble, forCellReuseIdentifier: "CometChatReceiverTextMessageBubble")
        
        let CometChatSenderTextMessageBubble  = UINib.init(nibName: "CometChatSenderTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderTextMessageBubble, forCellReuseIdentifier: "CometChatSenderTextMessageBubble")
        
        let CometChatReceiverImageMessageBubble  = UINib.init(nibName: "CometChatReceiverImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverImageMessageBubble, forCellReuseIdentifier: "CometChatReceiverImageMessageBubble")
        
        let CometChatSenderImageMessageBubble  = UINib.init(nibName: "CometChatSenderImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderImageMessageBubble, forCellReuseIdentifier: "CometChatSenderImageMessageBubble")
        
        let CometChatReceiverVideoMessageBubble  = UINib.init(nibName: "CometChatReceiverVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverVideoMessageBubble, forCellReuseIdentifier: "CometChatReceiverVideoMessageBubble")
        
        let CometChatSenderVideoMessageBubble  = UINib.init(nibName: "CometChatSenderVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderVideoMessageBubble, forCellReuseIdentifier: "CometChatSenderVideoMessageBubble")
        
        let CometChatReceiverFileMessageBubble  = UINib.init(nibName: "CometChatReceiverFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverFileMessageBubble, forCellReuseIdentifier: "CometChatReceiverFileMessageBubble")
        
        let CometChatSenderFileMessageBubble  = UINib.init(nibName: "CometChatSenderFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderFileMessageBubble, forCellReuseIdentifier: "CometChatSenderFileMessageBubble")
        
        let CometChatReceiverAudioMessageBubble  = UINib.init(nibName: "CometChatReceiverAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverAudioMessageBubble, forCellReuseIdentifier: "CometChatReceiverAudioMessageBubble")
        
        let CometChatSenderAudioMessageBubble  = UINib.init(nibName: "CometChatSenderAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderAudioMessageBubble, forCellReuseIdentifier: "CometChatSenderAudioMessageBubble")
        
        let CometChatActionMessageBubble  = UINib.init(nibName: "CometChatActionMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatActionMessageBubble, forCellReuseIdentifier: "CometChatActionMessageBubble")
        
        let CometChatReceiverLinkPreviewBubble = UINib.init(nibName: "CometChatReceiverLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLinkPreviewBubble, forCellReuseIdentifier: "CometChatReceiverLinkPreviewBubble")
        
        let CometChatSenderLinkPreviewBubble = UINib.init(nibName: "CometChatSenderLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLinkPreviewBubble, forCellReuseIdentifier: "CometChatSenderLinkPreviewBubble")
        
        let CometChatReceiverReplyMessageBubble = UINib.init(nibName: "CometChatReceiverReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverReplyMessageBubble, forCellReuseIdentifier: "CometChatReceiverReplyMessageBubble")
        
        
        let CometChatSenderReplyMessageBubble = UINib.init(nibName: "CometChatSenderReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderReplyMessageBubble, forCellReuseIdentifier: "CometChatSenderReplyMessageBubble")
        
        let CometChatReceiverLocationMessageBubble = UINib.init(nibName: "CometChatReceiverLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLocationMessageBubble, forCellReuseIdentifier: "CometChatReceiverLocationMessageBubble")
        
        let CometChatSenderLocationMessageBubble = UINib.init(nibName: "CometChatSenderLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLocationMessageBubble, forCellReuseIdentifier: "CometChatSenderLocationMessageBubble")
        
        let CometChatReceiverPollMessageBubble = UINib.init(nibName: "CometChatReceiverPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverPollMessageBubble, forCellReuseIdentifier: "CometChatReceiverPollMessageBubble")
        
        let CometChatSenderPollMessageBubble = UINib.init(nibName: "CometChatSenderPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderPollMessageBubble, forCellReuseIdentifier: "CometChatSenderPollMessageBubble")
        
        let CometChatReceiverStickerMessageBubble  = UINib.init(nibName: "CometChatReceiverStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverStickerMessageBubble, forCellReuseIdentifier: "CometChatReceiverStickerMessageBubble")
        
        let CometChatSenderStickerMessageBubble  = UINib.init(nibName: "CometChatSenderStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderStickerMessageBubble, forCellReuseIdentifier: "CometChatSenderStickerMessageBubble")
        
        let CometChatReceiverCollaborativeMessageBubble  = UINib.init(nibName: "CometChatReceiverCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatReceiverCollaborativeMessageBubble")
        
        let CometChatSenderCollaborativeMessageBubble  = UINib.init(nibName: "CometChatSenderCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatSenderCollaborativeMessageBubble")
        
        let CometChatReceiverMeetingMessageBubble  = UINib.init(nibName: "CometChatReceiverMeetingMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverMeetingMessageBubble, forCellReuseIdentifier: "CometChatReceiverMeetingMessageBubble")
        
        let CometChatSenderMeetingMessageBubble  = UINib.init(nibName: "CometChatSenderMeetingMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderMeetingMessageBubble, forCellReuseIdentifier: "CometChatSenderMeetingMessageBubble")
        
    }
    
    /**
     This method setup the Chat View where user can type the message or send the media.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupMessageComposer(){
        messageComposer.internalDelegate = self
        textView.delegate = self
        messageComposer.backgroundColor = .getAppColor(colorName: .grey_EFEFEF)
        if #available(iOS 13.0, *) {
//            let edit = UIImage(named: "send-message-filled.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            send.setImage(.getAppImage(imageName: .send_icon), for: .normal)
            send.tintColor = UIKitSettings.primaryColor
        } else {}
        blockViewButton.backgroundColor  = UIKitSettings.primaryColor
        
        FeatureRestriction.isVoiceNotesEnabled { (success) in
            switch success {
            case .enabled: self.microphone.isHidden = true
            case .disabled: self.microphone.isHidden = true
            }
        }
        FeatureRestriction.isLiveReactionsEnabled { (success) in
            switch success {
            case .enabled:
                self.reaction.isHidden = true
                self.reactionButtonWidth.constant = 0
                self.reactionButtonSpace.constant = 0
            case .disabled:
                self.reactionButtonWidth.constant = 0
                self.reactionButtonSpace.constant = 0
                if UIKitSettings.sendTextMessage == .enabled {
                    self.send.isHidden = false
                }else{
                    self.send.isHidden = true
                }
                self.reaction.isHidden = true
            }
        }
        
        if currentUser != nil {
            FeatureRestriction.isOneOnOneChatEnabled { (success) in
                switch success {
                case .enabled: self.messageComposer.isHidden = false
                case .disabled: self.messageComposer.isHidden = true
                }
            }
        }else if currentGroup != nil {
            FeatureRestriction.isGroupChatEnabled { (success) in
                switch success {
                case .enabled: self.messageComposer.isHidden = false
                case .disabled: self.messageComposer.isHidden = true
                }
            }
        }else{
            messageComposer.isHidden = false
        }
        
        FeatureRestriction.isEmojisEnabled { (success) in
            if success == .disabled {
                self.textView.keyboardType = .asciiCapable
            }
        }
        
        setAttachmentButtonAccordingToRole()
        
        if isPinnedMessageList {
            self.inputBarHeight.constant = 0
            self.messageComposer.isHidden = true
        }

    }
    
    func setAttachmentButtonAccordingToRole() {
        if self.isAdminOrMod {
            self.attachmentButtonSpace.constant = 8
            self.attachmentButtonWidth.constant = 25
        } else {
            self.attachmentButtonSpace.constant = 0
            self.attachmentButtonWidth.constant = 0
        }
    }
    
    /**
     This method will hide or unhide views such as blockedView, smartRepliesView and editMessageView as per user actions
     - Parameters:
     - view: This specified enum of  `HideView` which provides option such as `.blockedView`, `.smartRepliesView`,`.editMessageView`.
     - bool: specifies boolean value to hide or unhide view
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hide(view: HideView, _ bool: Bool){
        if bool == true {
            switch view {
            case .blockedView:
                self.blockedView.isHidden = true
            case .smartRepliesView:
                self.smartRepliesView.isHidden = true
            case .editMessageView:
                self.editView.isHidden = true
            }
        }else{
            switch view {
            case .blockedView:
                self.blockedView.isHidden = false
            case .smartRepliesView:
                FeatureRestriction.isSmartRepliesEnabled { (success) in
                    switch success {
                    case .enabled:
                        if !self.smartRepliesView.buttontitles.isEmpty {
                            self.smartRepliesView.isHidden = false
                            self.tableView?.scrollToBottomRow()
                        }
                    case .disabled:
                        self.smartRepliesView.isHidden = true
                    }
                }
            case .editMessageView:
                self.editView.isHidden = false
            }
        }
    }
    
    /**
     This method add refresh control in tableview by using user will be able to load previous messages.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addRefreshControl(inTableView: Bool){
        if inTableView == true{
            // Added Refresh Control
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
            tableView?.refreshControl = refreshControl
        }
    }
    
    /**
     This method add pull the list of privous messages when refresh control is triggered.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func loadPreviousMessages(_ sender: Any) {
        guard let request = messageRequest else {
            return
        }
        FeatureRestriction.isMessageHistoryEnabled { (success) in
            if success == .enabled {
                self.fetchPreviousMessages(messageReq: request)
            }
        }
    }
    
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupKeyboard(){
        configureGrowingTextView()
        textView.layer.cornerRadius = 4.0
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func configureGrowingTextView() {
        textViewBG.backgroundColor = .getAppColor(colorName: .black_000000).withAlphaComponent(0.06)
        textView.layer.cornerRadius = 20
        textView.textColor = .getAppColor(colorName: .black_090909).withAlphaComponent(0.5)
        textView.placeholder = NSAttributedString(string:  "Write a comment…", attributes: [.foregroundColor: UIColor.getAppColor(colorName: .black_090909).withAlphaComponent(0.5), .font:  UIFont.customFont(customFont: .robotoRegular, size: 14)])
        textView.maxNumberOfLines = 5
        textView.delegate = self
        send.isHidden = false
        messageComposer.internalDelegate = self
        
        switch ThemeManager.getCurrentTheme() {
        case .KKR:
            textView.font = .customFont(customFont: .rubikRegular, size: 12)
        case .TKR, .ADKR, .LAKR:
            textView.font = .customFont(customFont: .robotoRegular, size: 14)
        }
        
        if #available(iOS 13.0, *) {
//            let sendImage = UIImage(named: "send-message-filled.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            send.setImage(.getAppImage(imageName: .send_icon), for: .normal)
            send.tintColor = UIKitSettings.primaryColor
        } else {}
    }
    
    
    
    /**
     This method triggers when keyboard will change its frame.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if chatMessages.isEmpty && keyboardHeight > 0 {
                self.inputBarBottomSpace.constant = keyboardHeight - self.view.safeAreaInsets.bottom
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            } else if let tableView = tableView, let lastCell = tableView.visibleCells.last, (lastCell.frame.origin.y + lastCell.frame.size.height) <= (view.frame.size.height - keyboardHeight ), keyboardHeight > 0 {
                self.inputBarBottomSpace.constant = keyboardHeight - view.safeAreaInsets.bottom + messageComposer.frame.size.height
                self.view.frame.origin.y = messageComposer.frame.size.height
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            } else if keyboardHeight > 0 {
                self.view.frame.origin.y = -keyboardHeight
            } else {
                self.inputBarBottomSpace.constant = 0.0
                self.view.frame.origin.y = 0.0
            }
        }
    }
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func dismissKeyboard() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
        }
    }
    
    /**
     This method triggeres when user pressed the unblock button when the user is blocked.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didUnblockedUserPressed(_ sender: Any) {
        dismissKeyboard()
        if let uid =  currentUser?.uid {
            CometChat.unblockUsers([uid], onSuccess: { (success) in
                DispatchQueue.main.async {
                    self.hide(view: .blockedView, true)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    /**
     This method triggeres when user pressed close  button on present on edit view.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditCloseButtonPressed(_ sender: Any) {
        self.hide(view: .editMessageView, true)
        self.didPreformCancel()
        textView.text = nil
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - UIDocumentPickerDelegate 

extension CometChatMessageList: UIDocumentPickerDelegate {
    
    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            var mediaMessage: MediaMessage?
            var lastSection = 0
            if chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            switch self.isGroupIs {
            case true:
                mediaMessage = MediaMessage(receiverUid: currentGroup?.guid ?? "", fileurl: urls[0].absoluteString,messageType: .file, receiverType: .group)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                            strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                            strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                            strongSelf.tableView?.scrollToBottomRow()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        self.lastMessage = message
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            case false:
                mediaMessage = MediaMessage(receiverUid: currentUser?.uid ?? "", fileurl: urls[0].absoluteString, messageType: .file, receiverType: .user)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                            strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                            strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                            strongSelf.tableView?.scrollToBottomRow()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        self.lastMessage = message
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatMessageList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of messages.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        if chatMessages.isEmpty {
            return 0
        }else {
            return chatMessages.count
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[safe:section]?.first {
            let dateString = String().setMessageDateHeader(time: Int(firstMessageInSection.sentAt))
            let label = CometChatMessageDateHeader()
                label.text = dateString
            let containerView = UIView()
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
        }
        return nil
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /// This method specifiesnumber of rows in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[safe: section]?.count ?? 0
    }
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for message  in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        
        if let message = chatMessages[safe: section]?[safe: indexPath.row] {
            
            
            if message.deletedAt > 0.0 && message.senderUid != LoggedInUser.uid {
                let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
                deletedCell.deletedMessage = message
                deletedCell.indexPath = indexPath
                return deletedCell
                
            }else if message.deletedAt > 0.0 && message.senderUid == LoggedInUser.uid {
                
                let deletedCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderTextMessageBubble", for: indexPath) as! CometChatSenderTextMessageBubble
                deletedCell.deletedMessage = message
                deletedCell.indexPath = indexPath
//                if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
//                    deletedCell.receiptStack.isHidden = false
//                }else{
                    deletedCell.receiptStack.isHidden = false
//                }
                return deletedCell
            }else{
                
                if message.messageCategory == .message {
                    
                    switch message.messageType {
                    case .text where message.senderUid != LoggedInUser.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLinkPreviewBubble", for: indexPath) as! CometChatReceiverLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                receiverCell.hyperLinkOperationDelegate = self
                                receiverCell.linkPreviewMessage = linkPreviewMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.hyperlinkdelegate = self
                                receiverCell.linkPreviewDelegate = self
                                return receiverCell
                            case .reply:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverReplyMessageBubble", for: indexPath) as! CometChatReceiverReplyMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.hyperlinkdelegate = self
                                receiverCell.hyperLinkOperationDelegate = self
                                receiverCell.textMessage = textMessage
                                return receiverCell
                            case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.hyperlinkdelegate = self
                                receiverCell.hyperLinkOperationDelegate = self
                                receiverCell.textMessage = textMessage
                                return receiverCell
                                
                            case .thumbnailGeneration, .imageModeration, .sticker: break
                                
                            }
                        }
                    case .text where message.senderUid == LoggedInUser.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            
                            switch isContainsExtension {
                            case .linkPreview:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderLinkPreviewBubble", for: indexPath) as! CometChatSenderLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                senderCell.hyperLinkOperationDelegate = self
                                senderCell.linkPreviewMessage = linkPreviewMessage
                                senderCell.linkPreviewDelegate = self
                                senderCell.hyperlinkdelegate = self
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                /*
                                if  chatMessages[safe: indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                */
                                return senderCell
                            case .reply:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderReplyMessageBubble", for: indexPath) as! CometChatSenderReplyMessageBubble
                                senderCell.hyperLinkOperationDelegate = self
                                senderCell.textMessage = textMessage
                                senderCell.indexPath = indexPath
                                senderCell.hyperlinkdelegate = self
                                /*
                                if chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                */
                                return senderCell
                                
                            case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderTextMessageBubble", for: indexPath) as! CometChatSenderTextMessageBubble
                                senderCell.hyperLinkOperationDelegate = self
                                senderCell.textMessage = textMessage
                                senderCell.indexPath = indexPath
                                senderCell.hyperlinkdelegate = self
                                senderCell.receiptStack.isHidden = false
                                /*
                                if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                */
                                return senderCell
                            case .thumbnailGeneration, .imageModeration, .sticker : break
                                
                            }
                        }
                    case .image where message.senderUid != LoggedInUser.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: imageMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply, .sticker: break
                                
                            case .thumbnailGeneration, .imageModeration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverImageMessageBubble", for: indexPath) as! CometChatReceiverImageMessageBubble
                                receiverCell.mediaMessage = imageMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.mediaDelegate = self
                                return receiverCell
                            }
                        }
                        
                    case .image where message.senderUid == LoggedInUser.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: imageMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply, .sticker: break
                                
                            case .thumbnailGeneration, .imageModeration,.none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderImageMessageBubble", for: indexPath) as! CometChatSenderImageMessageBubble
                                senderCell.mediaMessage = imageMessage
                                senderCell.mediaDelegate = self
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                /*
                                if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                */
                                return senderCell
                            }
                        }
                    case .video where message.senderUid != LoggedInUser.uid:
                        if let videoMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: videoMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply, .sticker: break
                            case .thumbnailGeneration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverVideoMessageBubble", for: indexPath) as! CometChatReceiverVideoMessageBubble
                                receiverCell.mediaDelegate = self
                                receiverCell.mediaMessage = videoMessage
                                receiverCell.indexPath = indexPath
                                return receiverCell
                            }
                        }
                    case .video where message.senderUid == LoggedInUser.uid:
                        if let videoMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: videoMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply, .sticker: break
                            case .thumbnailGeneration,.none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderVideoMessageBubble", for: indexPath) as! CometChatSenderVideoMessageBubble
                                senderCell.mediaMessage = videoMessage
                                senderCell.mediaDelegate = self
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                /*
                                if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                */
                                return senderCell
                            }
                        }
                    case .audio where message.senderUid != LoggedInUser.uid:
                        
                        if let audioMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverAudioMessageBubble", for: indexPath) as! CometChatReceiverAudioMessageBubble
                            receiverCell.audioMessage = audioMessage
                            receiverCell.indexPath = indexPath
                            return receiverCell
                        }
                    case .audio where message.senderUid == LoggedInUser.uid:
                        if let audioMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderAudioMessageBubble", for: indexPath) as! CometChatSenderAudioMessageBubble
                            senderCell.audioMessage = audioMessage
                            senderCell.indexPath = indexPath
                            if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                    case .file where message.senderUid != LoggedInUser.uid:
                        if let fileMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverFileMessageBubble", for: indexPath) as! CometChatReceiverFileMessageBubble
                            receiverCell.fileMessage = fileMessage
                            receiverCell.indexPath = indexPath
                            return receiverCell
                        }
                    case .file where message.senderUid == LoggedInUser.uid:
                        if let fileMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderFileMessageBubble", for: indexPath) as! CometChatSenderFileMessageBubble
                            senderCell.fileMessage = fileMessage
                            senderCell.indexPath = indexPath
                            if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                    case .custom: break
                    case .groupMember:  break
                    case .image: break
                    case .text: break
                    case .file: break
                    case .video: break
                    case .audio: break
                    @unknown default: fatalError()
                    }
                }else if message.messageCategory == .action {
                    //  ActionMessage Cell
                    let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                    actionMessageCell.actionMessage = message as? ActionMessage
                    return actionMessageCell
                }else if message.messageCategory == .call {
                    //  CallMessage Cell
                    if let call = message as? CometChatPro.Call {
                        let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                        actionMessageCell.call = call
                        return actionMessageCell
                    }
                }else if message.messageCategory == .custom {
                    if let type = (message as? CustomMessage)?.type {
                        if type == "location" {
                            if message.senderUid != LoggedInUser.uid {
                                if let locationMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLocationMessageBubble", for: indexPath) as! CometChatReceiverLocationMessageBubble
                                    receiverCell.locationMessage = locationMessage
                                    receiverCell.locationDelegate = self
                                    return receiverCell
                                }
                            }else{
                                if let locationMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderLocationMessageBubble", for: indexPath) as! CometChatSenderLocationMessageBubble
                                    senderCell.locationMessage = locationMessage
                                    senderCell.locationDelegate = self
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else if type == "extension_poll" {
                            if message.senderUid != LoggedInUser.uid {
                                if let pollMesage = message as? CustomMessage {
                                    let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverPollMessageBubble", for: indexPath) as! CometChatReceiverPollMessageBubble
                                    receiverCell.pollMessage = pollMesage
                                    receiverCell.pollDelegate = self
                                    return receiverCell
                                }
                            }else{
                                if let pollMesage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderPollMessageBubble", for: indexPath) as! CometChatSenderPollMessageBubble
                                    senderCell.pollMessage = pollMesage
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else if type == "extension_sticker" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let stickerMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverStickerMessageBubble", for: indexPath) as! CometChatReceiverStickerMessageBubble
                                    receiverCell.stickerMessage = stickerMessage
                                    receiverCell.indexPath = indexPath
                                    return receiverCell
                                }
                            }else{
                                if let stickerMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderStickerMessageBubble", for: indexPath) as! CometChatSenderStickerMessageBubble
                                    senderCell.stickerMessage = stickerMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else if type == "extension_whiteboard" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let whiteboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                                    receiverCell.whiteboardMessage = whiteboardMessage
                                    receiverCell.collaborativeDelegate = self
                                    receiverCell.indexPath = indexPath
                                    return receiverCell
                                }
                            }else{
                                if let whiteboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderCollaborativeMessageBubble", for: indexPath) as! CometChatSenderCollaborativeMessageBubble
                                    senderCell.indexPath = indexPath
                                    senderCell.collaborativeDelegate = self
                                    senderCell.whiteboardMessage = whiteboardMessage
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else if type == "extension_document" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let writeboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                                    receiverCell.indexPath = indexPath
                                    receiverCell.writeboardMessage = writeboardMessage
                                    receiverCell.collaborativeDelegate = self
                                    return receiverCell
                                }
                            }else{
                                if let writeboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderCollaborativeMessageBubble", for: indexPath) as! CometChatSenderCollaborativeMessageBubble
                                    senderCell.indexPath = indexPath
                                    senderCell.writeboardMessage = writeboardMessage
                                    senderCell.collaborativeDelegate = self
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else if type == "meeting" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let meetingMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverMeetingMessageBubble", for: indexPath) as! CometChatReceiverMeetingMessageBubble
                                    receiverCell.indexPath = indexPath
                                    receiverCell.meetingMessage = meetingMessage
                                    receiverCell.meetingDelegate = self
                                    return receiverCell
                                }
                            }else{
                                if let meetingMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderMeetingMessageBubble", for: indexPath) as! CometChatSenderMeetingMessageBubble
                                    senderCell.indexPath = indexPath
                                    senderCell.meetingMessage = meetingMessage
                                    senderCell.meetingDelegate = self
                                    senderCell.receiptStack.isHidden = false
                                    /*
                                    if  chatMessages[safe:indexPath.section]?[safe: indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                        senderCell.receiptStack.isHidden = false
                                    }else{
                                        senderCell.receiptStack.isHidden = true
                                    }
                                     */
                                    return senderCell
                                }
                            }
                        }else{
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                            let customMessage = message as? CustomMessage
//                            receiverCell.message.text = "CUSTOM_MESSAGE".localized() +  "\(String(describing: customMessage?.customData))"
                            return receiverCell
                        }
                    }else{
                        //  CustomMessage Cell
                        let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                        let customMessage = message as? CustomMessage
//                        receiverCell.message.text = "CUSTOM_MESSAGE".localized() +  "\(String(describing: customMessage?.customData))"
                        return receiverCell
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
            self.selectedMessage = message
        }

        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message = selectedCell.textMessage {
            self.selectedMessage = message
        }
        
        return
        
//        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLocationMessageBubble, let message =  selectedCell.locationMessage {
                selectedCell.receiptStack.isHidden = false
                
                if tableView.isEditing == true && selectedCell.locationMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderMeetingMessageBubble, let message =  selectedCell.meetingMessage {
                selectedCell.receiptStack.isHidden = false
                
                if tableView.isEditing == true && selectedCell.meetingMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderPollMessageBubble, let message =  selectedCell.pollMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.pollMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message = selectedCell.textMessage {
                
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble, let message = selectedCell.textMessage {
                
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble, let message = selectedCell.textMessage {
                
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble, let message = selectedCell.stickerMessage {
                
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.stickerMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble, let message = selectedCell.stickerMessage {
                
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.stickerMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.locationMessage) {
                        self.selectedMessages.append(selectedCell.locationMessage)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverMeetingMessageBubble, let meetingMessage = selectedCell.meetingMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(meetingMessage) {
                        self.selectedMessages.append(meetingMessage)
                    }
                }
            }
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.pollMessage) {
                        self.selectedMessages.append(selectedCell.pollMessage)
                    }
                }
            }
        },completion: nil)
//        tableView.endUpdates()
        
    }
    
    /// This method triggers when particular cell is deselected by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        return
        
//        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1,delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1, options: [], animations: {
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLocationMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.locationMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.locationMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.locationMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.locationMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderPollMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.pollMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.pollMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.pollMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.pollMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = false
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = false
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                            selectedCell.receiptStack.isHidden = false
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = false
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                            selectedCell.receiptStack.isHidden = false
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = false
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.stickerMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.stickerMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.stickerMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.stickerMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                       },completion: nil)
//        tableView.endUpdates()
    }
    
    public  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    public  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == chatMessages.count - 1) ? 16 : 0
    }
}


extension CometChatMessageList: GrowingTextViewDelegate {
    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        DispatchQueue.main.async {
            self.inputBarHeight.constant = height
            self.tableView?.contentInset.bottom = height
        }
    }
    
    public func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat) {
        
    }
    
    func growingTextView(_ growingTextView: GrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return autocompleteManager.textView(growingTextView.internalTextView, shouldChangeTextIn: range, replacementText: text)
    }
    
    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
        guard let indicator = typingIndicator else {
            return
        }
        
        autocompleteManager.reloadData()
        
        if growingTextView.text?.count == 0 {
            FeatureRestriction.isTypingIndicatorsEnabled { (success) in
                if success == .enabled {
                    CometChat.startTyping(indicator: indicator)
                }
            }
            
            FeatureRestriction.isLiveReactionsEnabled { (success) in
                switch success {
                case .enabled:
                    self.reaction.isHidden = true
                    self.reactionButtonWidth.constant = 0
                    self.reactionButtonSpace.constant = 0
                case .disabled:
                    self.reaction.isHidden = true
                    self.reactionButtonWidth.constant = 0
                    self.reactionButtonSpace.constant = 0
                }
            }
            
            FeatureRestriction.isVoiceNotesEnabled { (success) in
                switch success {
                case .enabled: self.microphone.isHidden = true
                case .disabled: self.microphone.isHidden = true
                }
            }
            send.isHidden = false
            
        }else{
            microphone.isHidden = true
            if UIKitSettings.sendTextMessage == .enabled {
                send.isHidden = false
            }else{
                send.isHidden = true
            }
            
            reactionButtonSpace.constant = 0
            reactionButtonWidth.constant = 0
        }
        FeatureRestriction.isTypingIndicatorsEnabled { (success) in
            if success == .enabled {
                CometChat.startTyping(indicator: indicator)
            }
        }
    }
    
    private func fetchGroupMembers() {
//        if growingTextView.text == "@"{
            FeatureRestriction.isMentionsEnabled { (success) in
                switch success{
                case .enabled:
                    if let guid =  self.currentGroup?.guid{
                        self.memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).build()
                        self.memberRequest?.fetchNext(onSuccess: { (groupMember) in
                            if self.currentGroup?.scope == .admin {
                                let allMember = CometChatPro.GroupMember(UID: "all", groupMemberScope: .participant)
                                allMember.name = "All"
                                self.listOfUsersInGroup.append(allMember)
                            }
                            self.listOfUsersInGroup.append(contentsOf: groupMember)
                            }, onError: { (error) in
                                DispatchQueue.main.async {
                                    if let error = error {
//                                        KKRToastView.showToast(withMessage: "")
                                    }
                                }
                            })
                        }
                case.disabled:
                    print("Error")
                }
            }
//        }
    }
    
    private func shouldHighlightForMentions(userName: String) -> Bool {
        return self.listOfUsersInGroup.contains(where: { user in
            user.name == userName
        })
    }
    
    public func growingTextViewDidBeginEditing(_ growingTextView: GrowingTextView) {
    }
    
    public func growingTextViewDidEndEditing(_ growingTextView: GrowingTextView) {
        guard let indicator = typingIndicator else {
            return
        }
        
        setAutocompleteManager(active: false)
        
        FeatureRestriction.isTypingIndicatorsEnabled { (success) in
            if success == .enabled {
                CometChat.endTyping(indicator: indicator)
            }
        }
        if growingTextView.text?.count == 0 {
            FeatureRestriction.isVoiceNotesEnabled { (success) in
                switch success {
                case .enabled: self.microphone.isHidden = true
                case .disabled: self.microphone.isHidden = true
                }
            }
            send.isHidden = false
            FeatureRestriction.isLiveReactionsEnabled { (success) in
                switch success {
                case .enabled:
                    self.reaction.isHidden = true
                    self.reactionButtonWidth.constant = 0
                    self.reactionButtonSpace.constant = 0
                case .disabled:
                    self.reaction.isHidden = true
                    self.reactionButtonWidth.constant = 0
                    self.reactionButtonSpace.constant = 0
                }
            }
        }
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatMessageList:QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
    /**
     This method will open  quick look preview controller.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func presentQuickLook(){
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
//            if self?.navigationController != nil {
//                self?.navigationController?.pushViewController(previewController, animated: true)
//            }else{
//                self?.present(previewController, animated: true, completion: nil)
//            }
            self?.present(previewController, animated: true, completion: nil)
        }
    }
    
    /**
     This method will preview media message under  quick look preview controller.
     - Parameters:
     - url:  this specifies the `url` of Media Message.
     - completion: This handles the completion of method.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileName = itemUrl?.lastPathComponent ?? .blank
        if itemUrl?.lastPathComponent.contains("giphy") ?? false {
            fileName = (itemUrl?.relativePath ?? .blank).replacingOccurrences(of: "/", with: "")
        }
        
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            CometChatSnackBoard.show(message: "Downloading...")
            
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    CometChatSnackBoard.hide()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    
    /// Invoked when the Quick Look preview controller needs to know the number of preview items to include in the preview navigation list.
    /// - Parameter controller: A specialized view for previewing an item.
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    /// Invoked when the Quick Look preview controller needs the preview item for a specified index position.
    /// - Parameters:
    ///   - controller: A specialized view for previewing an item.
    ///   - index: The index position, within the preview navigation list, of the item to preview.
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageComposer Internal Delegate

extension CometChatMessageList : CometChatMessageComposerInternalDelegate {
    
    public func didReactionButtonPressed() {
        if isAnimating == false {
            self.reactionView.isHidden = false
            if let user = currentUser {
                var liveReaction : TransientMessage?
                if currentReaction == .heart {
                    liveReaction = TransientMessage(receiverID: user.uid ?? "", receiverType: .user, data: ["type":"live_reaction", "reaction": "heart"])
                }else{
                    liveReaction = TransientMessage(receiverID: user.uid ?? "", receiverType: .user, data: ["type":"live_reaction", "reaction": "thumbsup"])
                }
                if let liveReaction = liveReaction {
                    isAnimating = true
                    CometChat.sendTransientMessage(message: liveReaction)
                }
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                    self.reactionView.sendReaction()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        timer.invalidate()
                        self.reactionView.stopReaction()
                    })
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.isAnimating = false
                })
            }else if let group = currentGroup {
                var liveReaction : TransientMessage?
                if currentReaction == .heart {
                    liveReaction = TransientMessage(receiverID: group.guid, receiverType: .group, data: ["type":"live_reaction", "reaction": "heart"])
                }else{
                    liveReaction = TransientMessage(receiverID: group.guid, receiverType: .group, data: ["type":"live_reaction", "reaction": "thumbsup"])
                }
                if let liveReaction = liveReaction {
                    isAnimating = true
                    CometChat.sendTransientMessage(message: liveReaction)
                }
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                    self.reactionView.sendReaction()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        timer.invalidate()
                        self.reactionView.stopReaction()
                    })
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.isAnimating = false
                })
            }
        }
    }
    
    public func didMicrophoneButtonPressed(with: UILongPressGestureRecognizer) {
        
    }
    
    /**
     This method triggers when user pressed attachment  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didAttachmentButtonPressed() {
        let group: RowPresentable = MessageActionsGroup()
        var actions = [MessageAction]()
        
        FeatureRestriction.isPhotosVideosEnabled { (success) in
            if success == .enabled && self.isAdminOrMod {
                actions.append(.takeAPhoto)
                actions.append(.photoAndVideoLibrary)
            }
        }
        
        FeatureRestriction.isFilesEnabled { (success) in
            if success == .enabled {
                actions.append(.document)
            }
        }
        
        FeatureRestriction.isLocationSharingEnabled { (success) in
            if success == .enabled {
                actions.append(.shareLocation)
            }
        }
        
        FeatureRestriction.isStickersEnabled { (success) in
            if success == .enabled {
                actions.append(.sticker)
            }
        }
        
        FeatureRestriction.isPollsEnabled { (success) in
            if success == .enabled && self.isAdminOrMod {
                actions.append(.createAPoll)
            }
        }
        
        FeatureRestriction.isCollaborativeWhiteBoardEnabled { (success) in
            if success == .enabled {
                actions.append(.whiteboard)
            }
        }
        
        FeatureRestriction.isCollaborativeDocumentEnabled { (success) in
            if success == .enabled {
                actions.append(.writeboard)
            }
        }
//        FeatureRestriction.isGifsEnabled { (success) in
//            if success == .enabled {
//                actions.append(.sendGifs)
//            }
//        }
        
        (group.rowVC as? MessageActions)?.set(actions: actions)
        presentPanModal(group.rowVC, sourceView: messageComposer.attachment.inputView)
    }
    
    public func didGifyButtonPressed() {
        FeatureRestriction.isGifsEnabled { (success) in
            if success == .enabled {
                self.didSendGifsPressed()
            }
        }
    }
    
    private func sendMedia(withURL: String, type: CometChat.MessageType) {
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        var mediaMessage: MediaMessage?
        mediaMessage = MediaMessage(receiverUid: self.isGroupIs ? self.currentGroup?.guid ?? "" : self.currentUser?.uid ?? "", fileurl: withURL, messageType: type, receiverType: isGroupIs ? .group : .user)
        mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
        mediaMessage?.sender?.uid = LoggedInUser.uid
        mediaMessage?.senderUid = LoggedInUser.uid
        mediaMessage?.metaData = ["fileURL":withURL]
        if self.chatMessages.count == 0 {
            self.addNewGroupedMessage(messages: [mediaMessage!])
            self.filteredMessages.append(mediaMessage!)
        } else {
            if let lastMessage = self.chatMessages[lastSection].last , let mediaMessage = mediaMessage {
                let currentDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM, yyyy"
                let dateString = String().checkNewMessageDate(time: mediaMessage.sentAt)
                
                if (String().compareDates(newTimeInterval: mediaMessage.sentAt, currentTimeInterval: lastMessage.sentAt) ) || (self.calendar.isDateInToday(currentDate)) && (dateString == "1 Jan, 1970") {
                    self.chatMessages[lastSection].append(mediaMessage)
                    self.filteredMessages.append(mediaMessage)
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                        strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                } else {
                    self.chatMessages.append([mediaMessage])
                    lastSection = self.chatMessages.count - 1
                    self.filteredMessages.append(mediaMessage)
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.beginUpdates()
                        strongSelf.tableView?.insertSections([lastSection], with: .top)
                        lastSection = strongSelf.tableView?.numberOfSections ?? 0
                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                        strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.scrollToBottomRow()
                        strongSelf.tableView?.endUpdates()
                    }
                }
            }
        }
        CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
            if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                self.chatMessages[lastSection][row] = message
            }
            self.lastMessage = message
            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else { return }
                if message.messageType == .audio || message.messageType == .file {
                    do {
                        try strongSelf.viewModel.resetRecording()
                        strongSelf.audioVisualizationView.reset()
                        strongSelf.currentState = .ready
                    } catch {
                        strongSelf.showAlert(with: error)
                    }
                }
                strongSelf.tableView?.reloadData()}
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    
    private func sendSticker(withURL: String){
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        var stickerMessage: CustomMessage?
        stickerMessage = CustomMessage(receiverUid: self.isGroupIs ? self.currentGroup?.guid ?? "" : self.currentUser?.uid ?? "", receiverType: self.isGroupIs ? .group : .user, customData: ["sticker_url": withURL], type: "extension_sticker")
        stickerMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
        stickerMessage?.sender?.uid = LoggedInUser.uid
        stickerMessage?.senderUid = LoggedInUser.uid
        stickerMessage?.metaData = ["incrementUnreadCount":true]
        if self.chatMessages.count == 0 {
            self.addNewGroupedMessage(messages: [stickerMessage!])
            self.filteredMessages.append(stickerMessage!)
        } else {
            
            if let lastMessage = self.chatMessages[lastSection].last , let stickerMessage = stickerMessage {
                let currentDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM, yyyy"
                let dateString = String().checkNewMessageDate(time: stickerMessage.sentAt)
                
                if (String().compareDates(newTimeInterval: stickerMessage.sentAt, currentTimeInterval: lastMessage.sentAt) ) || (self.calendar.isDateInToday(currentDate)) && (dateString == "1 Jan, 1970") {
                    self.chatMessages[lastSection].append(stickerMessage)
                    self.filteredMessages.append(stickerMessage)
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableViewBottomConstraint.constant = 300
                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                        strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                } else {
                    self.chatMessages.append([stickerMessage])
                    lastSection = self.chatMessages.count - 1
                    self.filteredMessages.append(stickerMessage)
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableViewBottomConstraint.constant = 300
                        strongSelf.tableView?.beginUpdates()
                        strongSelf.tableView?.insertSections([lastSection], with: .top)
                        lastSection = strongSelf.tableView?.numberOfSections ?? 0
                        strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                        strongSelf.tableView?.scrollToBottomRow()
                        strongSelf.tableView?.endUpdates()
                    }
                }
            }
        }
        if let stickerMessage = stickerMessage {
            CometChat.sendCustomMessage(message: stickerMessage, onSuccess: { (message) in
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                self.lastMessage = message
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData()}
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when user pressed sticker  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didStickerButtonPressed() {
        
        
    }
    
    fileprivate func hideReceiptForCell(at indexPath: IndexPath, bool: Bool, message: BaseMessage) {
        if let cell = tableView?.cellForRow(at: indexPath), let textMessageCell = cell as? CometChatSenderTextMessageBubble {
            if indexPath == textMessageCell.indexPath {
                UIView.transition(with: textMessageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
                    if bool == true {
                        textMessageCell.receiptStack.isHidden = false
                    }else{
                        textMessageCell.textMessage = message as? TextMessage
                        textMessageCell.receiptStack.isHidden = false
                    }
                })
            }
        }
    }
    
    
    /**
     This method triggers when user pressed send  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didSendButtonPressed() {
        setAutocompleteManager(active: false)
        
        if autocompleteManager.mentionedMemberArray?.count != 0 {
            self.mentionedMembersId = getMentionedUsers()
        }
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        if messageMode == .edit {
            guard let textMessage = selectedMessage as? TextMessage else { return }
            guard let indexPath = selectedIndexPath else { return }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            if let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                textMessage.text = message
                CometChat.edit(message: textMessage, onSuccess: { (editedMessage) in
                    if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == editedMessage.id}) {
                        self.chatMessages[indexPath.section][row] = editedMessage
                    }
                    DispatchQueue.main.async{  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                    }
                }) { (error) in
                    DispatchQueue.main.async{ [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                        if let error = error as? CometChatException{
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        } else if messageMode == .reply {
            var textMessage: TextMessage?
            let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            } else {
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                textMessage = TextMessage(receiverUid: isGroupIs ? currentGroup?.guid ?? "" : currentUser?.uid ?? "", text: message, receiverType: isGroupIs ? .group : .user)
                textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                textMessage?.sender?.uid = LoggedInUser.uid
                textMessage?.senderUid = LoggedInUser.uid
                textMessage?.metaData = ["reply-message": selectedMessage?.rawMessage ]
                
                if chatMessages.count == 0 {
                    self.addNewGroupedMessage(messages: [textMessage!])
                    self.filteredMessages.append(textMessage!)
                    guard let indicator = typingIndicator else {
                        return
                    }
                    CometChat.endTyping(indicator: indicator)
                } else {
                    
                    if let firstMessage = self.chatMessages[lastSection].last , let textMessage = textMessage {
                        let currentDate = Date(timeIntervalSince1970: TimeInterval(firstMessage.sentAt))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "d MMM, yyyy"
                        let dateString = String().checkNewMessageDate(time: textMessage.sentAt)
                        if String().compareDates(newTimeInterval: textMessage.sentAt, currentTimeInterval: firstMessage.sentAt) || (calendar.isDateInToday(currentDate) && dateString == "1 Jan, 1970") {
                            self.chatMessages[lastSection].append(textMessage)
                            self.filteredMessages.append(textMessage)
                            guard let indicator = typingIndicator else {
                                return
                            }
                            CometChat.endTyping(indicator: indicator)
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.hide(view: .editMessageView, true)
                                strongSelf.hide(view: .smartRepliesView, true)
                                let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                                strongSelf.tableView?.insertRows(at: [indexpath], with: .automatic)
                                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                                strongSelf.tableView?.scrollToBottomRow()
                                strongSelf.textView.text = ""
                            }
                        } else {
                            self.filteredMessages.append(textMessage)
                            guard let indicator = self.typingIndicator else {
                                return
                            }
                            CometChat.endTyping(indicator: indicator)
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.beginUpdates()
                                strongSelf.hide(view: .editMessageView, true)
                                strongSelf.hide(view: .smartRepliesView, true)
                                strongSelf.chatMessages.append([textMessage])
                                lastSection = strongSelf.chatMessages.count - 1
                                strongSelf.tableView?.insertSections([lastSection], with: .top)
                                lastSection = strongSelf.tableView?.numberOfSections ?? 0
                                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                                strongSelf.tableView?.scrollToBottomRow()
                                strongSelf.tableView?.endUpdates()
                                strongSelf.textView.text = ""
                            }
                        }
                    }
                }
                CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                    if self.mentionedMembersId?.count != 0 {
                        self.sendNotificationToMentionedMembers(for: .mentioneUser, userID: self.mentionedMembersId, guid: self.currentGroup?.guid, payloadData: "\(message.text)", messageId: "\(message.id)")
                    }
                    DispatchQueue.main.async{ [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.lastMessage = message
                        if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.muid == message.muid}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                            DispatchQueue.main.async {  [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.chatMessages[section][row] = message
                                strongSelf.tableView?.reloadRows(at:[IndexPath(row: row , section: section)], with: .none)
                                strongSelf.messageMode = .send
                                strongSelf.didPreformCancel()
                                strongSelf.send.isEnabled = true
                                textMessage = nil
                            }
                        }
                        strongSelf.mentionedMembersId?.removeAll()
                        strongSelf.autocompleteManager.mentionedMemberArray?.removeAll()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        } else {
            var textMessage: TextMessage?
            let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                textMessage = TextMessage(receiverUid: isGroupIs ? currentGroup?.guid ?? "" : currentUser?.uid ?? "", text: message, receiverType: isGroupIs ? .group : .user)
                textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                textMessage?.sender?.uid = LoggedInUser.uid
                textMessage?.senderUid = LoggedInUser.uid
                if chatMessages.count == 0 {
                    self.addNewGroupedMessage(messages: [textMessage!])
                    guard let indicator = typingIndicator else {
                        return
                    }
                    CometChat.endTyping(indicator: indicator)
                } else {
                    
                    if let firstMessage = self.chatMessages[lastSection].last , let textMessage = textMessage {
                        let currentDate = Date(timeIntervalSince1970: TimeInterval(firstMessage.sentAt))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "d MMM, yyyy"
                        let dateString = String().checkNewMessageDate(time: textMessage.sentAt)
                        if String().compareDates(newTimeInterval: textMessage.sentAt, currentTimeInterval: firstMessage.sentAt) || (calendar.isDateInToday(currentDate) && dateString == "1 Jan, 1970") {
                            self.chatMessages[lastSection].append(textMessage)
                            self.filteredMessages.append(textMessage)
                            guard let indicator = typingIndicator else {
                                return
                            }
                            CometChat.endTyping(indicator: indicator)
                            DispatchQueue.main.async {  [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.hide(view: .smartRepliesView, true)
                                let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                                strongSelf.tableView?.insertRows(at: [indexpath], with: .right)
                                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                                strongSelf.tableView?.scrollToBottomRow()
                                strongSelf.textView.text = ""
                                strongSelf.send.isEnabled = false
                            }
                        } else {
                            self.chatMessages.append([textMessage])
                            lastSection = self.chatMessages.count - 1
                            self.tableView?.beginUpdates()
                            self.hide(view: .smartRepliesView, true)
                            self.tableView?.insertSections([lastSection], with: .top)
                            lastSection = self.tableView?.numberOfSections ?? 0
                            self.tableView?.insertRows(at: [IndexPath.init(row: self.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                            self.tableView?.endUpdates()
                            self.filteredMessages.append(textMessage)
                            guard let indicator = typingIndicator else {
                                return
                            }
                            CometChat.endTyping(indicator: indicator)
                            DispatchQueue.main.async {  [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.scrollToBottomRow()
                                strongSelf.textView.text = ""
                                strongSelf.send.isEnabled = false
                            }
                            
                        }
                    }
                }
            }
            guard let message = textMessage else { return }
            CometChat.sendTextMessage(message: message, onSuccess: { (message) in
                if self.mentionedMembersId?.count != 0 {
                    self.sendNotificationToMentionedMembers(for: .mentioneUser, userID: self.mentionedMembersId, guid: self.currentGroup?.guid, payloadData: "\(message.text)", messageId: "\(message.id)")
                }
                if let indexpath = self.chatMessages.indexPath(where: {$0.muid == message.muid}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                    DispatchQueue.main.async {  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.lastMessage = message
                        strongSelf.chatMessages[section][row] = message
                        strongSelf.hideReceiptForCell(at: IndexPath(row: row - 1, section: section), bool: true, message: message)
                        strongSelf.hideReceiptForCell(at: IndexPath(row: row, section: section), bool: false, message: message)
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .none)
                        strongSelf.send.isEnabled = true
                        textMessage = nil
                    }
                }
                self.mentionedMembersId?.removeAll()
                self.autocompleteManager.mentionedMemberArray?.removeAll()
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    func ismention(){
        FeatureRestriction.isMentionsEnabled { bool in
            
        }
    }
    
    private func getMentionedUsers() -> String {
        var mentionedId: String?
        self.mentionedMemberArray = autocompleteManager.mentionedMemberArray?.filter { $0 != "+\(LoggedInUser.uid)"}
        if let mentionArr = self.mentionedMemberArray {
            if mentionArr.contains("+all") {
                self.mentionedMemberArray?.removeAll()
                 self.listOfUsersInGroup.map { user in
                     guard let uID = user.uid else { return }
                     if !(uID == "\(LoggedInUser.uid)" || uID == "all") {
                         self.mentionedMemberArray?.append("+\(uID)")
                     }
                }
                mentionedId = self.mentionedMemberArray?.joined(separator: ",")
            }
            mentionedId = self.mentionedMemberArray?.joined(separator: ",")
        }
        return mentionedId ?? .blank
    }
    
    private func sendNotificationToMentionedMembers(for assetType: FanClubNotificationAssetType, userID: String?, guid: String?,payloadData: String?,messageId: String?) {
        self.validateCaptcha { success, token in
            if success {
                print("sendNotificationToMentionedMembers: \(payloadData)")
                CommonUtilities.shared.sendNotificationToMentionedMembers(captchaToken: token, for: assetType, userID: userID, guid: self.currentGroup?.guid,payloadData: payloadData, messageId: messageId)
                }
            }
    }
    
    func validateCaptcha(_ completion: @escaping ((_ success: Bool, _ token: String?) -> Void)) {
        let viewModelCaptcha = ReCaptchaVM(
            siteKey: FirebaseModelConfig.sharedFirebaseConfig.recaptchaSiteKey ?? .blank,
            url: URL(string: FirebaseModelConfig.sharedFirebaseConfig.baseUrl ?? .blank)!
        )
        viewModelCaptcha.captchaToken = { token in
            if token != "" {
                completion(true, token)
            } else {
                completion(false, nil)
            }
        }
        DispatchQueue.main.async {
            let captchaVC = ReCaptchaVC(viewModel: viewModelCaptcha)
            self.view.addSubview(captchaVC.view)
        }
    }
}
    

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate

extension CometChatMessageList : CometChatMessageDelegate {
    
    /**
     This method append new message on UI when new message is received.
     /// - Parameter message: This specified the `BaseMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func appendNewMessage(message: BaseMessage) {
        var lastSection = 0
        self.lastMessage = message
        DispatchQueue.main.async{
            if self.chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
            CometChatSoundManager().play(sound: .incomingMessage, bool: true)
        }
        switch message.receiverType {
        case .user:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            } else {
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self {
                        if let lastMessage = strongSelf.chatMessages[lastSection].last   {
                            let currentDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "d MMM, yyyy"
                            let dateString = String().checkNewMessageDate(time: message.sentAt)
                            
                            if (String().compareDates(newTimeInterval: message.sentAt, currentTimeInterval: lastMessage.sentAt) ) || (strongSelf.calendar.isDateInToday(currentDate)) && (dateString == "1 Jan, 1970") {
                                strongSelf.tableView?.beginUpdates()
                                strongSelf.chatMessages[lastSection].append(message)
                                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                                strongSelf.tableView?.endUpdates()
                                strongSelf.tableView?.scrollToBottomRow()
                            } else {
                                strongSelf.tableView?.beginUpdates()
                                strongSelf.chatMessages.append([message])
                                lastSection = strongSelf.chatMessages.count - 1
                                strongSelf.tableView?.insertSections([lastSection], with: .top)
                                lastSection = strongSelf.tableView?.numberOfSections ?? 0
                                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                                strongSelf.tableView?.endUpdates()
                                strongSelf.tableView?.scrollToBottomRow()
                            }
                        }
                    }
                }
            }
            
            
        case .group:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            } else {
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self {
                        if let lastMessage = strongSelf.chatMessages[lastSection].last   {
                            let currentDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "d MMM, yyyy"
                            let dateString = String().checkNewMessageDate(time: message.sentAt)
                            
                            if (String().compareDates(newTimeInterval: message.sentAt, currentTimeInterval: lastMessage.sentAt) ) || (strongSelf.calendar.isDateInToday(currentDate)) && (dateString == "1 Jan, 1970") {
                                strongSelf.tableView?.beginUpdates()
                                strongSelf.chatMessages[lastSection].append(message)
                                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                                strongSelf.tableView?.endUpdates()
                                strongSelf.tableView?.scrollToBottomRow()
                            } else {
                                strongSelf.tableView?.beginUpdates()
                                strongSelf.chatMessages.append([message])
                                lastSection = strongSelf.chatMessages.count - 1
                                strongSelf.tableView?.insertSections([lastSection], with: .top)
                                lastSection = strongSelf.tableView?.numberOfSections ?? 0
                                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                                strongSelf.tableView?.endUpdates()
                                strongSelf.tableView?.scrollToBottomRow()
                            }
                        }
                    }
                }
            }
        @unknown default: break
        }
    }
    
    public func onTransisentMessageReceived(_ message: TransientMessage) {
        print("onTransisentMessage: \(message.stringValue())")
        
        if message.sender?.uid == self.currentUser?.uid && message.receiverType == .user {
            
            if let liveReaction = message.data as? [String:Any], let type = liveReaction["type"] as? String ,let reaction = liveReaction["reaction"] as? String {
                if type == "live_reaction" {
                    if reaction == "heart" || reaction == "thumbsup" {
                        self.reactionView.isHidden = false
                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                            self.reactionView.sendReaction()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                timer.invalidate()
                                self.reactionView.stopReaction()
                            })
                        }
                    }
                }
            }
        }else if message.receiverType == .group  && message.receiverID == self.currentGroup?.guid {
            
            if let liveReaction = message.data as? [String:Any], let type = liveReaction["type"] as? String ,let reaction = liveReaction["reaction"] as? String {
                if type == "live_reaction" {
                    if reaction == "heart" || reaction == "thumbsup" {
                        self.reactionView.isHidden = false
                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                            self.reactionView.sendReaction()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                timer.invalidate()
                                self.reactionView.stopReaction()
                            })
                        }
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            CometChat.markAsDelivered(baseMessage: textMessage)
            if textMessage.parentMessageId != 0 {
                CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                if let user = strongSelf.currentUser?.uid {
                    strongSelf.refreshMessageList(forID: user, type: .user, scrollToBottom: false)
                }else if let group = strongSelf.currentGroup?.guid{
                    strongSelf.refreshMessageList(forID: group, type: .group, scrollToBottom: false)
                }
            }else{
                //Appending Real time text messages for User.
                if let sender = textMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && textMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: textMessage)
                        if let titles = strongSelf.parseSmartRepliesMessages(message: textMessage) {
                            if !titles.isEmpty {
                                strongSelf.smartRepliesView.set(titles: titles)
                                strongSelf.hide(view: .smartRepliesView, false)
                            }else{
                                strongSelf.hide(view: .smartRepliesView, true)
                            }
                        }
                        
                    }else if sender == LoggedInUser.uid && textMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: textMessage)
                        if let titles = strongSelf.parseSmartRepliesMessages(message: textMessage) {
                            strongSelf.smartRepliesView.set(titles: titles)
                            strongSelf.hide(view: .smartRepliesView, true)
                        }
                    }
                }else{
                    CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = textMessage.senderUid
                    let group = textMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if group == currentGroup && textMessage.receiverType == .group && sender != LoggedInUser.uid {
                        strongSelf.appendNewMessage(message: textMessage)
                        if let titles = strongSelf.parseSmartRepliesMessages(message: textMessage) {
                            if !titles.isEmpty {
                                strongSelf.smartRepliesView.set(titles: titles)
                                strongSelf.hide(view: .smartRepliesView, false)
                            }else{
                                strongSelf.hide(view: .smartRepliesView, true)
                            }
                        }
                    }else if sender == LoggedInUser.uid && textMessage.receiverType == .group && group == currentGroup {
                        strongSelf.appendNewMessage(message: textMessage)
                        if let titles = strongSelf.parseSmartRepliesMessages(message: textMessage) {
                          strongSelf.smartRepliesView.set(titles: titles)
                          strongSelf.hide(view: .smartRepliesView, true)
                        }
                    }
                }else{
                    CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                }
            }
            
            
        }
    }
    
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            CometChat.markAsDelivered(baseMessage: mediaMessage)
            if mediaMessage.parentMessageId != 0 {
                CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                if let user = strongSelf.currentUser?.uid {
                    strongSelf.refreshMessageList(forID: user, type: .user, scrollToBottom: false)
                }else if let group = strongSelf.currentGroup?.guid{
                    strongSelf.refreshMessageList(forID: group, type: .group, scrollToBottom: false)
                }
            }else{
                if let sender = mediaMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && mediaMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                        
                    }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = mediaMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if sender == currentGroup && mediaMessage.receiverType == .group {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .group {
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
            }
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            CometChat.markAsDelivered(baseMessage: customMessage)
            if customMessage.parentMessageId != 0 {
                CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                if let user = strongSelf.currentUser?.uid {
                    strongSelf.refreshMessageList(forID: user, type: .user, scrollToBottom: false)
                }else if let group = strongSelf.currentGroup?.guid{
                    strongSelf.refreshMessageList(forID: group, type: .group, scrollToBottom: false)
                }
            }else{
                if let sender = customMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && customMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                        
                    }else if sender == LoggedInUser.uid && customMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = customMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if sender == currentGroup && customMessage.receiverType == .group {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }else if sender == LoggedInUser.uid && customMessage.receiverType == .group {
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
            }
        }
    }
    
    
    fileprivate func updateReceiptForCell(at indexPath: IndexPath, receipt: MessageReceipt) {
        if let cell = tableView?.cellForRow(at: indexPath), let textMessageCell = cell as? CometChatSenderTextMessageBubble {
            if textMessageCell.textMessage?.id == Int(receipt.messageId)   {
                UIView.transition(with: textMessageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
                    textMessageCell.textMessage?.receipts = [receipt]

                    switch receipt.receiptType {
                    case .delivered:
                        textMessageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        textMessageCell.receipt.tintColor = UIKitSettings.secondaryColor
                    case .read:
                        textMessageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        textMessageCell.receipt.tintColor = UIKitSettings.primaryColor
                    @unknown default:
                        textMessageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        textMessageCell.receipt.tintColor = UIKitSettings.secondaryColor
                    }
                })
            }
        }
    }
    
//    fileprivate func updateReceiptForCell(at indexPath: IndexPath, receipt: MessageReceipt) {
//        if let cell = tableView?.cellForRow(at: indexPath) {
//           
//            if let messageCell = cell as? CometChatSenderTextMessageBubble {
//                
//                if messageCell.textMessage?.id == Int(receipt.messageId)   {
//                    UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                        messageCell.textMessage?.receipts = [receipt]
//                        
//                        switch receipt.receiptType {
//                        case .delivered:
//                            messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                            messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                        case .read:
//                            messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                            messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                        @unknown default:
//                            messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                            messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                        }
//                    })
//                }
//                
//                    
//                } else if let messageCell = cell as? CometChatSenderImageMessageBubble {
//                    
//                    if messageCell.mediaMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.mediaMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                   
//                    
//                } else if let messageCell = cell as? CometChatSenderFileMessageBubble {
//                    
//                    if messageCell.fileMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.fileMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                  
//                    
//                } else if let messageCell = cell as? CometChatSenderStickerMessageBubble {
//                    
//                    if messageCell.stickerMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.stickerMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                  
//                    
//                } else if let messageCell = cell as? CometChatSenderPollMessageBubble {
//                    
//                    if messageCell.pollMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.pollMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                    
//                    
//                } else if let messageCell = cell as? CometChatSenderLinkPreviewBubble {
//                    
//                    if messageCell.linkPreviewMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.linkPreviewMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                    
//                    
//                } else if let messageCell = cell as? CometChatSenderVideoMessageBubble {
//                    
//                    if messageCell.mediaMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.mediaMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                   
//                    
//                } else if let messageCell = cell as? CometChatSenderAudioMessageBubble {
//                    
//                    if messageCell.audioMessage?.id == Int(receipt.messageId) {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.audioMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                   
//                    
//                } else if let messageCell = cell as? CometChatSenderReplyMessageBubble {
//                    
//                    if messageCell.textMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.textMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                   
//                    
//                } else if let messageCell = cell as? CometChatSenderLocationMessageBubble {
//                    
//                    if messageCell.locationMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.locationMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                    
//                    
//                } else if let messageCell = cell as? CometChatSenderCollaborativeMessageBubble {
//                    if messageCell.whiteboardMessage?.id == Int(receipt.messageId)   {
//                        UIView.transition(with: messageCell.receiptStack, duration: 0.4, options: .transitionCrossDissolve,animations: {
//                            messageCell.whiteboardMessage?.receipts = [receipt]
//                            
//                            switch receipt.receiptType {
//                            case .delivered:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            case .read:
//                                messageCell.receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.primaryColor
//                            @unknown default:
//                                messageCell.receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
//                                messageCell.receipt.tintColor = UIKitSettings.secondaryColor
//                            }
//                        })
//                    }
//                    
//                }
//        }
//    }
    
    /**
     This method triggers when receiver reads the message sent by you.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesRead(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                
                if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.id == Int(receipt.messageId)}){
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.beginUpdates()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            
                            strongSelf.updateReceiptForCell(at: indexpath, receipt: receipt)
                        }
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .none)
                        strongSelf.tableView?.endUpdates()
                    }
                }
                
            }
        }
    }
    
    /**
     This method triggers when  message sent by you reaches to the receiver.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesDelivered(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.id == Int(receipt.messageId)}){
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.beginUpdates()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            strongSelf.updateReceiptForCell(at: indexpath, receipt: receipt)
                        }
                        
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .none)
                        strongSelf.tableView?.endUpdates()
                    }
                }
            }else if receipt.receiverId == strongSelf.currentGroup?.guid && receipt.receiverType == .group{
                if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.deliveredAt == 0}), let section = indexpath.section as? Int, let row = indexpath.row as? Int, let message = strongSelf.chatMessages[section][row] as? BaseMessage {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        message.deliveredAt = Double(receipt.timeStamp)
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when real time event for  start typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if typingDetails.sender?.uid == strongSelf.currentUser?.uid && typingDetails.receiverType == .user {
                
                FeatureRestriction.isTypingIndicatorsEnabled { (success) in
                    if success == .enabled {
                        strongSelf.setupNavigationBar(withSubtitle: "TYPING".localized())
                    }
                }
                
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == strongSelf.currentGroup?.guid {
                if let user = typingDetails.sender?.name {
                    FeatureRestriction.isTypingIndicatorsEnabled { (success) in
                        if success == .enabled {
                            strongSelf.setupNavigationBar(withSubtitle: "\(String(describing: user)) " + "IS_TYPING".localized())
                        }
                    }
                    
                }
            }
        }
    }
    
    /**
     This method triggers when real time event for  stop typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            
            if typingDetails.sender?.uid == strongSelf.currentUser?.uid && typingDetails.receiverType == .user{
                
                strongSelf.setupNavigationBar(withSubtitle: "ONLINE".localized())
                
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == strongSelf.currentGroup?.guid {
                strongSelf.setupNavigationBar(withSubtitle: strongSelf.membersCount ?? "")
            }
        }
    }
    
    
    public func onMessageEdited(message: BaseMessage) {
        
        if let indexpath = chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.chatMessages[section][row] = message
//                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                strongSelf.reloadVisibleCells()
                strongSelf.displayPinMessages()
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        
        FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
            switch success {
            
            case .enabled:
                
                if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                    DispatchQueue.main.async {  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.chatMessages[indexpath.section].remove(at: indexpath.row)
                        strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.reloadData()
                    }
                }
                
            case .disabled:
                if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                    DispatchQueue.main.async {  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.chatMessages[section][row] = message
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                    }
                }
            }
        }
    }
}

extension Array where Element : Collection, Element.Index == Int {
    func indexPath(where predicate: (Element.Iterator.Element) -> Bool) -> IndexPath? {
        for (i, row) in self.enumerated() {
            if let j = row.index(where: predicate) {
                return IndexPath(indexes: [i, j])
            }
        }
        return nil
    }
}

/*  ----------------------------------------------------------------------------------------- */


extension CometChatMessageList : CometChatUserDelegate {
    
    
    public func onUserOnline(user: CometChatPro.User) {
        if user.uid == currentUser?.uid {
            DispatchQueue.main.async {
                self.setupNavigationBar(withSubtitle: "ONLINE".localized())
            }
            
        }
    }
    
    public func onUserOffline(user: CometChatPro.User) {
        if user.uid == currentUser?.uid {
            DispatchQueue.main.async {
                self.setupNavigationBar(withSubtitle: "OFFLINE".localized())
            }
        }
    }
    
}






/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatGroupDelegate Delegate


extension CometChatMessageList : CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: joinedGroup.guid)
            CometChat.markAsRead(baseMessage: action)
            self.refreshMessageList(forID: joinedGroup.guid, type: .group, scrollToBottom: true)
        }
    }
    
    /**
     This method triggers when someone lefts group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - leftUser: Specifies `User` Object
     - leftGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: leftGroup.guid)
//            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone kicked from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - kickedUser: Specifies `User` Object
     - kickedBy: Specifies `User` Object
     - kickedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: kickedFrom.guid)
//            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone banned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - bannedUser: Specifies `User` Object
     - bannedBy: Specifies `User` Object
     - bannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            
//            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone unbanned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - unbannedUser: Specifies `User` Object
     - unbannedBy: Specifies `User` Object
     - unbannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
           
//            self.appendNewMessage(message: action)
        }
    }
    
    /**
     This method triggers when someone's scope changed  in the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - scopeChangeduser: Specifies `User` Object
     - scopeChangedBy: Specifies `User` Object
     - scopeChangedTo: Specifies `User` Object
     - scopeChangedFrom:  Specifies  description for scope changed
     - group: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
          
//            self.appendNewMessage(message: action)
            group.addToScope(userID: scopeChangeduser.uid, scopeTo: scopeChangedTo) { [weak self] in
                self?.updateGroupMetaData(group: group)
            }
        }
    }
    
    /**
     This method triggers when someone added in  the  group.
     - Parameters:
     - action:  Spcifies `ActionMessage` Object
     - addedBy: Specifies `User` Object
     - addedUser: Specifies `User` Object
     - addedTo: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroup(group: addedTo.guid)
//            self.appendNewMessage(message: action)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Smart Replies Delegate

extension CometChatMessageList : CometChatSmartRepliesPreviewDelegate {
    
    /**
     This method triggers when user pressed particular button in smart replies view.
     - Parameter title: `title` specifies the title of the button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didSendButtonPressed(title: String) {
        var textMessage: TextMessage?
        let lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        switch self.isGroupIs {
        case true:
            textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: title, receiverType: .group)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                strongSelf.tableView?.insertRows(at: [indexpath], with: .right)
                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
            }
            
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                self.lastMessage = message
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        case false:
            textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: title, receiverType: .user)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                strongSelf.tableView?.insertRows(at: [indexpath], with: .right)
                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
            }
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                self.lastMessage = message
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData() }
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Link Preview Delegate

extension CometChatMessageList: LinkPreviewDelegate {
    
    /**
     This method triggers when user pressed visit button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didVisitButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    /**
     This method triggers when user pressed play button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didPlayButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

/*  ----------------------------------------------------------------------------------------- */


extension CometChatMessageList: CometChatReceiverTextMessageBubbleDelegate {
    
    func didTapOnSentimentAnalysisViewForLeftBubble(indexPath: IndexPath) {
        if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
            let alert = UIAlertController(title: "WARNING".localized(), message: "USER_READ_MESSAGE_WARNING".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (action: UIAlertAction!) in
                self.tableView?.beginUpdates()
                cell.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                cell.sentimentAnalysisView.isHidden = true
                cell.spaceConstraint.constant = 0
                cell.widthconstraint.constant = 0
                if let message = cell.textMessage {
                    cell.parseProfanityFilter(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
                if let message = cell.textMessage {
                    cell.parseMaskedData(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
                self.tableView?.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            present(alert, animated: true, completion: nil)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */



extension CometChatMessageList: CometChatReceiverReplyMessageBubbleDelegate {
    
    
    func didTapOnSentimentAnalysisViewForLeftReplyBubble(indexPath: IndexPath) {
        if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
            let alert = UIAlertController(title:"", message: "Are you sure want to view this message?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "VIEW".localized(), style: .default, handler: { (action: UIAlertAction!) in
                self.tableView?.beginUpdates()
                cell.message.font = UIFont.systemFont(ofSize: 17, weight: .medium)
                cell.sentimentAnalysisView.isHidden = true
                cell.spaceConstraint.constant = 0
                cell.widthconstraint.constant = 0
                if let message = cell.textMessage {
                    cell.parseProfanityFilter(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
                self.tableView?.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension CometChatMessageList: ThreadDelegate {
    
    
    public func didReplyAdded(forMessage: BaseMessage, text: String, indexPath: IndexPath) {
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
            
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
            tableView?.beginUpdates()
            selectedCell.replyButton.isHidden = false
            selectedCell.replyButton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
        
        if let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
            tableView?.beginUpdates()
            selectedCell.replybutton.isHidden = false
            selectedCell.replybutton.setTitle(text, for: .normal)
            tableView?.endUpdates()
        }
    }
    
    public func startThread(forMessage: BaseMessage, indexPath: IndexPath) {
        if let group = currentGroup {
            let threadedList = CometChatThreadedMessageList()
            let navigationController = UINavigationController(rootViewController: threadedList)
            threadedList.set(threadFor: forMessage, conversationWith: group, type: .group)
            threadedList.indexPath = indexPath
            self.present(navigationController, animated: true) {
                self.didPreformCancel()
            }
        } else if let user = currentUser {
            let threadedList = CometChatThreadedMessageList()
            let navigationController = UINavigationController(rootViewController: threadedList)
            threadedList.indexPath = indexPath
            threadedList.set(threadFor: forMessage, conversationWith: user, type: .user)
            self.present(navigationController, animated: true) {
                self.didPreformCancel()
            }
        }
    }
}


extension CometChatMessageList : MessageActionsDelegate {
    
    func didSendGifsPressed() {
        let gifs = GifsVC()
        gifs.delegate = self
//        let navigationController = UINavigationController(rootViewController:gifs )
        self.present(gifs, animated: true, completion: nil)
    }
    
    func didReplyInPrivatePressed() {
        if let message = selectedMessage, let user = message.sender {
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: user, type: .user)
            messageList.isMessageInPrivateEnabled = true
            messageList.selectedMessage = message
            messageList.messageMode = .reply
            messageList.isMessageInPrivateEnabled = true
            self.navigationController?.pushViewController(messageList, animated: true)
        }
    }
    
    func didMessageInPrivatePressed() {
        if let message = selectedMessage, let user = message.sender {
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: user, type: .user)
            messageList.isMessageInPrivateEnabled = true
            self.navigationController?.pushViewController(messageList, animated: true)
        }
    }
    
    func didAudioCallPressed() {
        
    }
    
    func didVideoCallPressed() {
        
    }
    
    func didMessageTranslatePressed() {
        
        if let message = selectedMessage as? TextMessage, let indexPath = selectedIndexPath {
            let systemLanguage = Locale.preferredLanguages.first?.replacingOccurrences(of: "-US", with: "")
            CometChat.callExtension(slug: "message-translation", type: .post, endPoint: "v2/translate", body: ["msgId": message.id ,"languages": [systemLanguage], "text": message.text] as [String : Any], onSuccess: { (response) in
                DispatchQueue.main.async {
                    if let response = response, let originalLanguage = response["language_original"] as? String {
                        if originalLanguage == systemLanguage{
                            CometChatSnackBoard.display(message:  "NO_TRANSLATION_AVAILABLE".localized(), mode: .info, duration: .short)
                        }else{
                            if let translatedLanguages = response["translations"] as? [[String:Any]] {
                                for tranlates in translatedLanguages {
                                    if let languageTranslated = tranlates["language_translated"] as? String, let messageTranslated = tranlates["message_translated"] as? String {
                                        if languageTranslated == systemLanguage {
                                            self.tableView?.beginUpdates()
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble {
                                                cell.textMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
                                                cell.textMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
                                                cell.textMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble {
                                                cell.textMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                                                cell.linkPreviewMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                                                cell.linkPreviewMessage?.text = message.text + "\n(\(messageTranslated))"
                                            }
                                            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                                            self.tableView?.endUpdates()
                                        }else{
                                            CometChatSnackBoard.display(message:  "NO_TRANSLATION_AVAILABLE".localized(), mode: .info, duration: .short)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    
    func didCollaborativeWriteboardPressed() {
        if let group = currentGroup {
            
            CometChat.callExtension(slug:  "document", type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
                
            }
            
        } else if let user = currentUser {
            
            CometChat.callExtension(slug: "document", type: .post, endPoint: "v1/create", body: ["receiver":user.uid,"receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }                    }
                
            }
        }
    }
    
    func didCollaborativeWhiteboardPressed() {
        if let group = currentGroup {
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint: "v1/create", body: ["receiver":group.guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
                
            }
            
        } else if let user = currentUser {
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint:  "v1/create", body: ["receiver":user.uid,"receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                    
                }
            }
        }
    }
    
    
    func didReactionPressed() {
        
    }
    
    
    func didStickerPressed() {
        
        
        DispatchQueue.main.async {
            let stickerView = CometChatStickerKeyboard()
            stickerView.modalPresentationStyle = .custom
            self.present(stickerView, animated: true, completion: nil)
        }
    }
    
    func takeAPhotoPressed() {
        CameraHandler.shared.presentCamera(for: self)
        CameraHandler.shared.imagePickedBlock = {(photoURL) in
            self.sendMedia(withURL: photoURL, type: .image)
        }
    }
    
    func copyPressed() {
        if let message = selectedMessage {
            var messageText = ""
            switch message.messageType {
            case .text: messageText = (message as? TextMessage)?.text ?? ""
            case .image: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .video: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .file: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .custom:
//                messageText = "CUSTOM_MESSAGE".localized()
                break
            case .audio: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .groupMember: break
            @unknown default:break
            }
            UIPasteboard.general.string = messageText
            DispatchQueue.main.async {
                CometChatSnackBoard.display(message: "TEXT_COPIED".localized(), mode: .success, duration: .short)
                self.didPreformCancel()
            }
        }
    }
    
    func photoAndVideoLibraryPressed() {
        CameraHandler.shared.presentPhotoLibrary(for: self)
        CameraHandler.shared.imagePickedBlock = {(photoURL) in
            self.sendMedia(withURL: photoURL, type: .image)
        }
        CameraHandler.shared.videoPickedBlock = {(videoURL) in
            self.sendMedia(withURL: videoURL, type: .video)
        }
    }
    
    func documentPressed() {
        self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(self.documentPicker, animated: true, completion: nil)
    }
    
    func shareLocationPressed() {
        var lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        
        let alert = UIAlertController(title: "" , message: "SHARE_LOCATION_CONFIRMATION_MESSAGE".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "SHARE".localized(), style: .default, handler: { action in
            
            if let location = self.curentLocation {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    let pushtitle = (CometChat.getLoggedInUser()?.name ?? "") + " has shared his location"
                    let locationData = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude] as [String : Any]
                    let locationMessage = CustomMessage(receiverUid: strongSelf.isGroupIs ? strongSelf.currentGroup?.guid ?? "" : strongSelf.currentUser?.uid ?? "" , receiverType: strongSelf.isGroupIs ? .group : .user, customData: locationData, type: "location")
                    locationMessage.metaData = ["pushNotification": pushtitle, "incrementUnreadCount":true]
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: nil, message: "SENDING_LOCATION".localized(), preferredStyle: .alert)
                        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                        loadingIndicator.hidesWhenStopped = true
                        loadingIndicator.style = UIActivityIndicatorView.Style.gray
                        loadingIndicator.startAnimating()
                        alert.view.addSubview(loadingIndicator)
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                    CometChat.sendCustomMessage(message: locationMessage, onSuccess: { (message) in
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.lastMessage = message
                            strongSelf.dismiss(animated: true, completion: nil)
                            CometChatSnackBoard.display(message: "LOCATION_SENT_SUCCESSFULLY".localized(), mode: .success, duration: .short)
                            
                            if strongSelf.chatMessages.count == 0 {
                                strongSelf.addNewGroupedMessage(messages: [message])
                                strongSelf.filteredMessages.append(message)
                            } else {
                                
                                if let lastMessage = strongSelf.chatMessages[lastSection].last   {
                                    let currentDate = Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "d MMM, yyyy"
                                    let dateString = String().checkNewMessageDate(time: message.sentAt)
                                    
                                    if (String().compareDates(newTimeInterval: message.sentAt, currentTimeInterval: lastMessage.sentAt) ) || (strongSelf.calendar.isDateInToday(currentDate)) && (dateString == "1 Jan, 1970") {
                                        strongSelf.chatMessages[lastSection].append(message)
                                        strongSelf.filteredMessages.append(message)
                                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                                        strongSelf.tableView?.insertRows(at: [indexpath], with: .right)
                                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                                        strongSelf.tableView?.scrollToBottomRow()
                                        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                                    } else {
                                        strongSelf.chatMessages.append([message])
                                        lastSection = strongSelf.chatMessages.count - 1
                                        strongSelf.tableView?.beginUpdates()
                                        strongSelf.tableView?.insertSections([lastSection], with: .top)
                                        lastSection = strongSelf.tableView?.numberOfSections ?? 0
                                        let indexpath = IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)
                                        strongSelf.tableView?.insertRows(at: [indexpath], with: .right)
                                        strongSelf.tableView?.endUpdates()
                                        strongSelf.tableView?.scrollToBottomRow()
                                        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                                    }
                                }
                                
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            CometChatSnackBoard.display(message: "UNABLE_TO_SEND_LOCATON_MESSAGE".localized(), mode: .error, duration: .short)
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { action in
            
        }))
        alert.view.tintColor = UIKitSettings.primaryColor
        self.present(alert, animated: true)
    }
    
    func createAPollPressed() {
        DispatchQueue.main.async {
            let createAPoll = CometChatCreatePoll()
            createAPoll.set(title: "CREATE_A_POLL".localized(), mode: .automatic)
            if let user = self.currentUser {
                createAPoll.user = user
            }
            if let group = self.currentGroup {
                createAPoll.group = group
            }
            let navigationController = UINavigationController(rootViewController: createAPoll)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func didMessageInfoPressed() {
        if let message = selectedMessage {
            let cometChatMessageInformation = CometChatMessageInformation()
            cometChatMessageInformation.set(message: message)
            cometChatMessageInformation.title = "MESSAGE_INFORMATION".localized()
            self.navigationController?.pushViewController(cometChatMessageInformation, animated: true)
        }
    }
    
    
    func didStartThreadPressed() {
        if let group = currentGroup, let message = selectedMessage {
            let threadedList = CometChatThreadedMessageList()
            let navigationController = UINavigationController(rootViewController: threadedList)
            threadedList.indexPath = selectedIndexPath
            threadedList.set(threadFor: message, conversationWith: group, type: .group)
            self.present(navigationController, animated: true) {
                self.didPreformCancel()
            }
        } else if let user = currentUser, let message = selectedMessage {
            let threadedList = CometChatThreadedMessageList()
            let navigationController = UINavigationController(rootViewController: threadedList)
            threadedList.indexPath = selectedIndexPath
            threadedList.set(threadFor: message, conversationWith: user, type: .user)
            self.present(navigationController, animated: true) {
                self.didPreformCancel()
            }
        }
    }
    
    /**
     This method triggeres when user pressed edit message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didEditPressed() {
        self.messageMode = .edit
        self.hide(view: .editMessageView, false)
        guard let message = selectedMessage else { return }
        editViewName.text = "EDIT_MESSAGE".localized()
        
        if let message = (message as? TextMessage)?.text {
            editViewMessage.text = message
            textView.text = message
        }
    }
    
    /**
     This method triggeres when user pressed delete message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didDeletePressed() {
        guard let message = selectedMessage else { return }
        guard let indexPath = selectedIndexPath else { return }
        CometChat.delete(messageId: message.id, onSuccess: { (deletedMessage) in
            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                switch success {
                case .enabled:
                    if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                        DispatchQueue.main.async {  [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.chatMessages[indexpath.section].remove(at: indexpath.row)
                            strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                            strongSelf.tableView?.reloadData()
                            strongSelf.didPreformCancel()
                        }
                    }
                case .disabled:
                    let textMessage:BaseMessage = (deletedMessage as? ActionMessage)?.actionOn as! BaseMessage
                    if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == textMessage.id}) {
                        self.chatMessages[indexPath.section][row] = textMessage
                    }
                    DispatchQueue.main.async {
                        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                        self.didPreformCancel()
                    }
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                CometChatSnackBoard.showErrorMessage(for: error)
                self.didPreformCancel()
            }
        }
    }
    
    func didReplyPressed() {
        self.messageMode = .reply
        self.hide(view: .editMessageView, false)
        guard let message = selectedMessage else { return }
        if let name = message.sender?.name {
            editViewName.text = name.capitalized
        }
        switch message.messageType {
        case .text:
            
            if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
                if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
                    
                    if sensitiveData == "yes" {
                        if let maskedMessage = data["message_masked"] as? String {
                            editViewMessage.text = maskedMessage
                        }else{
                            editViewMessage.text = (message as? TextMessage)?.text
                        }
                    }else{
                        editViewMessage.text = (message as? TextMessage)?.text
                    }
                }else{
                    editViewMessage.text = (message as? TextMessage)?.text
                }
            }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
                
                if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                    
                    if profanity == "yes" {
                        editViewMessage.text = filteredMessage
                    }else{
                        editViewMessage.text = (message as? TextMessage)?.text
                    }
                }else{
                    editViewMessage.text = (message as? TextMessage)?.text
                }
            }else{
                editViewMessage.text = (message as? TextMessage)?.text
            }
            
        case .image: editViewMessage.text = "MESSAGE_IMAGE".localized()
        case .video: editViewMessage.text = "MESSAGE_VIDEO".localized()
        case .audio: editViewMessage.text = "MESSAGE_AUDIO".localized()
        case .file: editViewMessage.text = "MESSAGE_FILE".localized()
        case .custom:
            if let type = (message as? CustomMessage)?.type {
                if type == "location" {
                    editViewMessage.text = "CUSTOM_MESSAGE_LOCATION".localized()
                }else if type == "extension_poll" {
                    editViewMessage.text = "CUSTOM_MESSAGE_POLL".localized()
                }else if type == "extension_sticker" {
                    editViewMessage.text = "CUSTOM_MESSAGE_STICKER".localized()
                }else if type == "extension_whiteboard" {
                    editViewMessage.text = "CUSTOM_MESSAGE_WHITEBOARD".localized()
                }else if type == "extension_document" {
                    editViewMessage.text = "CUSTOM_MESSAGE_DOCUMENT".localized()
                }else if type == "meeting" {
                    editViewMessage.text = "CUSTOM_MESSAGE_GROUP_CALL".localized()
                }
            }
        case .groupMember: break
        @unknown default: break }
    }
    
    func didSharePressed() {
        
        if let message = selectedMessage {
            var textToShare = ""
            if message.messageType == .text {
                if message.receiverType == .user{
                    textToShare = (message as? TextMessage)?.text ?? ""
                }else{
                    if let name = (message as? TextMessage)?.sender?.name , let text = (message as? TextMessage)?.text {
                        textToShare = name + " : " + text
                    }
                }
            }else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                if message.receiverType == .user{
                    textToShare = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                }else{
                    if let name = (message as? MediaMessage)?.sender?.name, let url =  (message as? MediaMessage)?.attachment?.fileUrl {
                        textToShare = name + " : " +  url
                    }
                }
            }
            
            
            let sendItems = [ textToShare]
            let activityViewController = UIActivityViewController(activityItems: sendItems, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
            self.didPreformCancel()
        }
    }
    
    /**
     This method triggeres when user pressed forward message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didForwardPressed() {
        if let message = selectedMessage {
            let forwardMessageList = CometChatForwardMessageList()
            forwardMessageList.set(message: message)
            navigationController?.pushViewController(forwardMessageList, animated: true)
            self.didPreformCancel()
        }
    }
    
    func didPinMessagePressed() {
        if let message = self.selectedMessage {
            message.addPinMessage()
            self.updatePinMessage(message: message) { [weak self] in
                CometChat.callExtension(slug: "pin-message", type: .post, endPoint: "v1/pin", body: ["msgId": message.id] as [String : Any], onSuccess: { (response) in
                        self?.displayPinMessages()
                        KKRToastView.showToast(withMessage: "Successfully pinned message")
                      }) { (error) in
                          if let error = error {
//                              CometChatSnackBoard.showErrorMessage(for: error)
                                KKRToastView.showToast(withMessage: error.errorDescription)
                          }
                          
                      }
            }
        }
    }
    
    func didUnpinMessagePressed() {
        guard let group = self.currentGroup else { return }
        if let message = self.selectedMessage {
            CometChat.callExtension(slug: "pin-message", type: .delete, endPoint: "v1/unpin", body: ["msgId": message.id, "receiverType": "group", "receiver": group.guid] as [String : Any], onSuccess: { (response) in
                message.removePinMessage()
                self.updatePinMessage(message: message) { [weak self] in
                    guard let self = self else { return }
                    self.displayPinMessages()
                    if let selectedMessage = self.selectedMessage {
                        self.onUnpinCallback?(selectedMessage)
                    }
                    KKRToastView.showToast(withMessage: "Successfully unpinned message")
                }
                  }) { (error) in
                      if let error = error {
//                          CometChatSnackBoard.showErrorMessage(for: error)
                          KKRToastView.showToast(withMessage: error.errorDescription)
                      }
                  }
            
        }
    }
    
    private func updatePinMessage(message: BaseMessage, onSuccess: @escaping () -> Void) {
        CometChat.edit(message: message) { baseMessage in
            DispatchQueue.main.async {
                if let selectedMessage = self.selectedMessage, !self.isPinnedMessageList {
                    self.onMessageEdited(message: selectedMessage)
                }
            }
            onSuccess()
        } onError: { error in
            KKRToastView.showToast(withMessage: error.errorDescription)
        }

    }
}


func didSendGifsPressed(){
    CometChat.callExtension(slug: "gifs-giphy", type: .get, endPoint: "v1/trending?offset=10&limit=15", body: nil, onSuccess: { (response) in
            // GIFs data from Giphy
          }) { (error) in
            // Some error occured
          }
        }

      
extension CometChatMessageList: LocationCellDelegate, CLLocationManagerDelegate {
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            curentLocation = locationManager.location
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        self.curentLocation = location
    }
    
    func didPressedOnLocation(latitude: Double, longitude: Double, title: String) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "OPEN_IN_APPLE_MAPS".localized(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openMapsForPlace(latitude: latitude, longitude: longitude, title: title)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "OPEN_IN_GOOGLE_MAPS".localized(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openGoogleMapsForPlace(latitude: String(latitude), longitude: String(longitude))
        }))
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        actionSheet.view.tintColor = UIKitSettings.primaryColor
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    func openMapsForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openGoogleMapsForPlace(latitude: String, longitude: String) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                                                "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
        } else {
        }
    }
}


extension CometChatMessageList: PollExtensionDelegate {
    
    
    func voteForPoll(pollID: String, with option: String, cell: UITableViewCell) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "VOTING".localized(), preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
        
        CometChat.callExtension(slug:  "polls", type: .post, endPoint: "v2/vote", body: ["vote":option,"id":pollID], onSuccess: { (response) in
            DispatchQueue.main.async {
                self.tableView?.beginUpdates()
                if let cell = cell as? CometChatReceiverPollMessageBubble {
                    cell.option1Tick.isHidden = true
                    cell.option2Tick.isHidden = true
                    cell.option3Tick.isHidden = true
                    cell.option4Tick.isHidden = true
                    cell.option5Tick.isHidden = true
                    switch option {
                    case "1": cell.option1Tick.isHidden = false
                    case "2": cell.option2Tick.isHidden = false
                    case "3": cell.option3Tick.isHidden = false
                    case "4": cell.option4Tick.isHidden = false
                    case "5": cell.option5Tick.isHidden = false
                    default:break
                    }
                }
                self.tableView?.endUpdates()
                self.dismiss(animated: true, completion: nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
                
            }
        }
    }
}


extension CometChatMessageList : HyperLinkDelegate, MFMailComposeViewControllerDelegate {
    
    func didTapOnURL(url: String) {
        guard let currentURL = NSURL(string: url) else {
            return
        }
        if ["http", "https"].contains(currentURL.scheme?.lowercased()) {
            // Can open with SFSafariViewController
            let safariViewController = SFSafariViewController(url: currentURL as URL)
            present(safariViewController, animated: true, completion: nil)
        } else {
            // Scheme is not supported or no scheme is given, use openURL
            CometChatSnackBoard.display(message: "INVALID_URL".localized(), mode: .error, duration: .short)
        }
    }
    
    func didTapOnPhoneNumber(number: String) {
        if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined() as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let url = URL(string: "tel://\(number)")!
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    func didTapOnEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            self.present(mail, animated: true, completion: nil)
        } else {
            showAlert(title: "WARNING".localized(), msg: "MAIL_APP_NOT_FOUND_MESSAGE".localized())
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


extension CometChatMessageList: StickerViewDelegate {
    
    func didClosePressed() {
        DispatchQueue.main.async {
            self.tableViewBottomConstraint.constant = 0
        }
    }
    
    
    func didStickerSelected(sticker: CometChatSticker) {
        
        if let url = sticker.url {
            DispatchQueue.main.async {
                self.sendSticker(withURL: url)
            }
        }
    }
    
    func didStickerSetSelected(stickerSet: CometChatStickerSet) {
        
    }
    
    
}


extension CometChatMessageList: CometChatMessageReactionsDelegate {
    
    func didReactionPressed(reaction: CometChatMessageReaction) {
        
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: alert.view.bounds)
        loadingIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        // height constraint
        let constraintHeight = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        alert.view.addConstraint(constraintHeight)

        // width constraint
        let constraintWidth = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        alert.view.addConstraint(constraintWidth)
        
        if reaction.messageId == 0 {
            self.dismiss(animated: true) {
                if let message = self.selectedMessage {

                    self.present(alert, animated: true, completion: nil)
                    
                    CometChat.callExtension(slug: "reactions", type: .post, endPoint: "v1/react", body: ["msgId":message.id , "emoji":reaction.title ?? ""], onSuccess: { (success) in
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.dismiss(animated: true, completion: nil)
                            if message.id == strongSelf.lastMessage?.id {
                                strongSelf.tableView?.scrollToBottomRow()
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            if let error = error {
                                strongSelf.dismiss(animated: true, completion: nil)
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            }
        }else{

            self.present(alert, animated: true, completion: nil)
            
            CometChat.callExtension(slug: "reactions", type: .post, endPoint: "v1/react", body: ["msgId":reaction.messageId ?? "", "emoji": reaction.title ?? ""], onSuccess: { (success) in
                DispatchQueue.main.async {  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dismiss(animated: true, completion: nil)
                    if reaction.messageId == strongSelf.lastMessage?.id {
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }) { (error) in
                if let error = error {
                    self.dismiss(animated: true, completion: nil)
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
                
            }
        }
    }
    
    func didNewReactionPressed() {
        
    }
    
    func didlongPressOnCometChatMessageReactions(reactions: [CometChatMessageReaction]) {
        let cometChatMessageReactors = CometChatMessageReactors()
        let navigationController = UINavigationController(rootViewController: cometChatMessageReactors)
        navigationController.title = "REACTIONS".localized()
        cometChatMessageReactors.reactors = reactions
        self.present(navigationController, animated: true, completion: nil)
    }
}


extension CometChatMessageList: CollaborativeDelegate {
    
    func didJoinPressed(forMessage: CustomMessage) {
        
        
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let collaborativeDictionary = cometChatExtension["whiteboard"] as? [String : Any], let collaborativeURL =  collaborativeDictionary["board_url"] as? String {
            
            let collaborativeView = CometChatWebView()
            collaborativeView.webViewType = .whiteboard
            collaborativeView.url = collaborativeURL
            self.navigationController?.pushViewController(collaborativeView, animated: true)
            
        }else if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let collaborativeDictionary = cometChatExtension["document"] as? [String : Any], let collaborativeURL =  collaborativeDictionary["document_url"] as? String {
            
            let collaborativeView = CometChatWebView()
            collaborativeView.webViewType = .writeboard
            collaborativeView.url = collaborativeURL
            self.navigationController?.pushViewController(collaborativeView, animated: true)
            
        }
    }
}

extension CometChatMessageList: MeetingDelegate {
    
    
    func didJoinPressed(forSessionID: String, type: CometChat.CallType) {
        DispatchQueue.main.async {
            let meetingView = CometChatMeetingView()
            meetingView.modalPresentationStyle = .fullScreen
            if type == .audio {
                meetingView.performCall(with: forSessionID, type: .audio)
            }else if  type == .video {
                meetingView.performCall(with: forSessionID, type: .video)
            }
            self.present(meetingView, animated: true, completion: nil)
        }
    }
    
}


extension CometChatMessageList: MediaDelegate {
    
    func didOpenMedia(forMessage: MediaMessage, cell: UITableViewCell) {
        switch forMessage.messageType {
        case .text: break
        case .image:
            print("selected media message", forMessage.stringValue())
            if  let selectedCell = cell as? CometChatReceiverImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView?.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = cell as? CometChatSenderImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView?.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
        case .video:
            
            if  let selectedCell = cell as? CometChatSenderVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                
                if tableView?.isEditing == true {
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                } else {
                    if let attachment = selectedCell.mediaMessage.metaData?["fileURL"] as? String , let fileUrl = URL(string: attachment), fileUrl.checkFileExist() {
                        var player = AVPlayer()
                        player = AVPlayer(url: fileUrl)
                        DispatchQueue.main.async{[weak self] in
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            self?.present(playerViewController, animated: true) {
                                playerViewController.player!.play()
                            }
                        }
                    } else {
                        self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                            if success {
                                var player = AVPlayer()
                                if let videoURL = fileURL,
                                   let url = URL(string: videoURL.absoluteString) {
                                    player = AVPlayer(url: url)
                                }
                                DispatchQueue.main.async{[weak self] in
                                    let playerViewController = AVPlayerViewController()
                                    playerViewController.player = player
                                    self?.present(playerViewController, animated: true) {
                                        playerViewController.player!.play()
                                    }
                                }
                            }
                        })
                    }
                }
            }
            
            if let selectedCell = cell as? CometChatReceiverVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView?.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            var player = AVPlayer()
                            if let videoURL = fileURL,
                               let url = URL(string: videoURL.absoluteString) {
                                player = AVPlayer(url: url)
                            }
                            DispatchQueue.main.async{ [weak self] in
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    })
                }
            }
            
        case .audio:break
        case .file:break
        case .custom:break
        case .groupMember:break
        @unknown default:break
        }
    }
}

extension CometChatMessageList: PinnedMessageStickyViewDelegate {
    func didTapPinnedMessageView() {
        guard !self.isPinnedMessageList else { return }
        guard let group = self.currentGroup else { return }
        DispatchQueue.main.async {
            let messageList: CometChatMessageList = CometChatMessageList()
            messageList.isPinnedMessageList = true
            messageList.set(conversationWith: group, type: .group)
            messageList.hidesBottomBarWhenPushed = true
            messageList.onUnpinCallback = { [weak self] baseMessage in
                DispatchQueue.main.async {
                    self?.onMessageEdited(message: baseMessage)
                }
            }
            self.navigationController?.pushViewController(messageList, animated: true)
        }
    }
}

extension CometChatMessageList: GIFsSelectionDelegate {
    func didSelectGIF(with data: GifyData) {
        guard let group = self.currentGroup else { return }
        let mediaMessage = MediaMessage(receiverUid: group.guid, fileurl: data.images?.previewGIF?.url, messageType: .image, receiverType: .group)
        let attachment = Attachment(fileName: data.slug ?? .blank, fileExtension: ".gif", fileMimeType: "image/gif", fileUrl: data.images?.previewGIF?.url ?? .blank)
        mediaMessage.attachment = attachment
        
        CometChat.sendMediaMessage(message: mediaMessage) { message in
            var lastSection = 0
            if self.chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
//            if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
//                self.chatMessages[lastSection][row] = message
//            }
            self.chatMessages[lastSection].append(message)
            self.lastMessage = message
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        } onError: { error in
            KKRToastView.showToast(withMessage: error?.errorDescription)
        }
        
    }
    
}

// MARK: AutocompleteManagerDelegate, AutocompleteManagerDataSource

extension CometChatMessageList: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
  // MARK: - AutocompleteManagerDataSource

    public func autocompleteManager(_: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
    if prefix == "@" {
      return listOfUsersInGroup
        .map { user in
          AutocompleteCompletion(
            text: user.name ?? .blank,
            context: ["id": user.uid])
        }
    }
    return []
  }

    public func autocompleteManager(
    _ manager: AutocompleteManager,
    tableView: UITableView,
    cellForRowAt indexPath: IndexPath,
    for session: AutocompleteSession)
    -> UITableViewCell
  {
    guard
      let cell = tableView
        .dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else
    {
      fatalError("Oops, some unknown error occurred")
    }
    let users = listOfUsersInGroup
    let id = session.completion?.context?["id"] as? String
    let user = users.filter { $0.uid == id }.first
//    if let sender = user {
//      cell.imageView?.image = SampleData.shared.getAvatarFor(sender: sender).image
//    }
//    cell.imageViewEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//    cell.imageView?.layer.cornerRadius = 14
//    cell.imageView?.layer.borderColor = UIColor.systemBlue.cgColor
//    cell.imageView?.layer.borderWidth = 1
//    cell.imageView?.clipsToBounds = true
    cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 15)
    return cell
  }

  // MARK: - AutocompleteManagerDelegate

    public func autocompleteManager(_: AutocompleteManager, shouldBecomeVisible: Bool) {
    setAutocompleteManager(active: shouldBecomeVisible)
  }

  // Optional
    public func autocompleteManager(_: AutocompleteManager, shouldRegister _: String, at _: NSRange) -> Bool {
    true
  }

  // Optional
    public func autocompleteManager(_: AutocompleteManager, shouldUnregister _: String) -> Bool {
    true
  }

  // Optional
    public func autocompleteManager(_: AutocompleteManager, shouldComplete _: String, with _: String) -> Bool {
    true
  }

  // MARK: - AutocompleteManagerDelegate Helper

  func setAutocompleteManager(active: Bool) {
    guard let topStackView = messageComposerStackView else { return }
      
    if active, !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: 0)
            topStackView.layoutIfNeeded()
    } else if !active, topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
        topStackView.removeArrangedSubview(autocompleteManager.tableView)
        topStackView.layoutIfNeeded()
    }
//      self.textView.updateScrollPosition(animated: true)
      self.textView.updateHeight()
      
  }
}

extension CometChatMessageList: HyperLinkOperationDelegate {
    
    public func doesContainUser(userName: String, senderID: String) -> Bool {
        
        if userName.split(separator: " ").first?.lowercased() == "All".lowercased() {
            if self.listOfUsersInGroup.first(where: { user in
                user.uid == senderID
            })?.scope == .admin {
                return true
            } else {
                return false
            }
        }
        
        let contains = listOfUsersInGroup.contains { user in
            return user.name == userName
        }
        return contains 
    }
    
}
