//
//  VSLMakeCallViewController.swift
//  Copyright © 2016 Devhouse Spindle. All rights reserved.
//

import UIKit

class VSLMakeCallViewController: UIViewController {

    // MARK: - Configuration

    fileprivate struct Configuration {
        struct Segues {
            static let UnwindToMainViewController = "UnwindToMainViewControllerSegue"
            static let ShowCallViewController = "ShowCallViewControllerSegue"
        }
    }

    // MARK: - Properties

    var account: VSLAccount!

    var call: VSLCall?
    var callManager: VSLCallManager!

    fileprivate var number: String {
        set {
            numberToDialLabel?.text = newValue
            callButton?.isEnabled = newValue != ""
            deleteButton?.isEnabled = newValue != ""
        }
        get {
            return numberToDialLabel.text!
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callManager = VialerSIPLib.sharedInstance().callManager
        
        NotificationCenter.default.addObserver(self, selector: #selector(showVideo(user:)), name: NSNotification.Name(rawValue: VSLNotificationUserInfoVideoSizeRenderKey), object: nil)
    }

    func showVideo(user: Notification){

        var i:pjsua_vid_win_id = 0
        var last:pjsua_vid_win_id = 0
        
        
        let userDic = NSDictionary(dictionary: user.userInfo!)
        
        let wid:pjsua_vid_win_id = Int32(userDic.object(forKey: VSLNotificationUserInfoWindowIdKey) as! Int)
        
        if wid == PJSUA_INVALID_ID.rawValue {
            i = 0
        }
        else {
            i = wid
        }
        
        if wid == PJSUA_INVALID_ID.rawValue {
            last = PJSUA_MAX_VID_WINS
        }
        else {
            last = wid+1
        }
        
        if wid == PJSUA_INVALID_ID.rawValue {
            print("MyLogger: displayWindow failed\n");
        }else{
            print("MyLogger: displayWindow success\n");
        }

        for i in 0..<last {
            var wi:UnsafeMutablePointer<pjsua_vid_win_info> = UnsafeMutablePointer.allocate(capacity: MemoryLayout<pjsua_vid_win_info>.size)
            var myStatus:pj_status_t
            myStatus = pjsua_vid_win_get_info(i, wi);
            //myStatus = Int32(userDic.object(forKey: VSLNotificationUserInfoWindowStatusKey) as! Int)
            //wi = Int32(userDic.object(forKey: VSLNotificationUserInfoWindowKey) as! Int)

            let _wi:pjsua_vid_win_info = wi.pointee
            
            if myStatus == Int32(PJ_SUCCESS.rawValue) {
                let parent = self.view;
                let view = _wi.hwnd.info.ios.window as? UIView
                
                if(view != nil){
                    DispatchQueue.main.async {
                        view?.isHidden = false
                        
                        if ( !(view?.isDescendant(of: parent!))!){
                            parent?.addSubview(view!)
                        }
//                        if ( _wi.is_native){
                           view?.frame = (parent?.frame)!
//                        }
//                        else{
                        //view?.center = CGPoint(x: (parent?.bounds.size.width)!/2, y: (parent?.bounds.size.height)! - (view?.bounds.size.height)!/2)
//                       }
                    }
                }

                




            }

        }
        
        
/*        NSDictionary *userInfo = @{VSLNotificationUserInfoCallIdKey:@(call_id),
            VSLNotificationUserInfoWindowIdKey:@(wid),
            VSLNotificationUserInfoWindowSizeKey:[NSValue valueWithCGSize:(CGSize){size.w, size.h}]};
*/

        
//        #if PJSUA_HAS_VIDEO
//            NSLog(@"windows id : %d",wid);
//            int i, last;
//
//            i = (wid == PJSUA_INVALID_ID) ? 0 : wid;
//            last = (wid == PJSUA_INVALID_ID) ? PJSUA_MAX_VID_WINS : wid+1;
//            if(wid == PJSUA_INVALID_ID){
//                printf("MyLogger: displayWindow failed\n");
//            }else{
//                printf("MyLogger: displayWindow success\n");}
//            for (;i < last; ++i) {
//                pjsua_vid_win_info wi;
//                pj_status_t myStatus;
//                myStatus = pjsua_vid_win_get_info(i, &wi);
//                if(myStatus != PJ_SUCCESS){
//                    DLog(@"%i", myStatus);
//                    //pjsua_perror(THIS_FILE, THIS_FILE, myStatus);
//                }
//
//                if (myStatus == PJ_SUCCESS) {
//                    UIView *parent = selfView;
//                    UIView *view = (__bridge UIView *)wi.hwnd.info.ios.window;
//
//                    if (view) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            /* Add the video window as subview */
//                            [view setHidden:false];
//
//                            if (![view isDescendantOfView:parent]){
//                                [parent addSubview:view];
//                            }
//                            if (!wi.is_native) {
//                                /* Resize it to fit width */
//                                view.frame = parent.frame; // = CGRectMake(0, 0, parent.bounds.size.width,
//                                //(parent.bounds.size.height *
//                                // 1.0*parent.bounds.size.width/
//                                //view.bounds.size.width));
//                                /* Center it horizontally */
//                                //                        view.center = CGPointMake(parent.bounds.size.width/2.0,
//                                //                                                  view.bounds.size.height/2.0);
//                            } else {
//                                /* Preview window, move it to the bottom */
//                                view.center = CGPointMake(parent.bounds.size.width/2.0,
//                                                          parent.bounds.size.height-
//                                    view.bounds.size.height/2.0);
//                            }
//                            });
//                    }
//                }
//            }
//
//
//        #endif
//
        
    }
    
    func displayWindow(wid:pjsua_vid_win_id){
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false
        updateUI()
    }

    // MARK: - Outlets

    @IBOutlet weak var numberToDialLabel: UILabel! {
        didSet {
            numberToDialLabel.text = "\(Keys.NumberToCall)"
        }
    }

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Actions

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Configuration.Segues.UnwindToMainViewController, sender: nil)
    }

    @IBAction func keypadButtonPressed(_ sender: UIButton) {
        number = number + sender.currentTitle!
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        number = number.substring(to: number.characters.index(number.endIndex, offsetBy: -1))
    }

    @IBAction func callButtonPressed(_ sender: UIButton) {
        self.callButton.isEnabled = false
        if account.isRegistered {
            setupCall()
        } else {
            account.register { (success, error) in
                self.setupCall()

            }
        }
    }

    fileprivate func setupCall() {
        self.callManager.startCall(toNumber: number, for: account ) { (call, error) in
            if error != nil {
                DDLogWrapper.logError("Could not start call")
            } else {
                self.call = call
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Configuration.Segues.ShowCallViewController, sender: nil)
                }
            }
        }
    }

    func updateUI() {
        callButton?.isEnabled = number != ""
        deleteButton?.isEnabled = number != ""
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let callViewController = segue.destination as? VSLCallViewController {
            callViewController.activeCall = call
        }
    }

}
