//
//  ViewController.swift
//  iOS Net Demo
//
//  Created by Christopher Casey on 12/13/15.
//  Copyright © 2015 Vinli, Inc. All rights reserved.
//

import UIKit
import SnapKit
import VinliNet

class ViewController: UIViewController, VLLoginViewControllerDelegate {
    
    static let CLIENT_ID = "1dbac1be-0092-4d9f-b80e-b69469dc622a"
    static let REDIRECT_URI = "https://android.netdemo.vin.li"
    static let ACCESS_TOKEN_KEY = "ACCESSTOKEN"
    static let DEVICE_NAME_TAG = 45
    
    var service: VLService? = nil;
    
    var refreshButton: UIButton? = nil;
    var loginButton: UIButton? = nil;
    
    var loaded = false
    var appeared = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        self.refreshButton = UIButton(type: UIButtonType.System)
        let refreshButton = self.refreshButton!
        view.addSubview(refreshButton)
        refreshButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(view).offset(40)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        refreshButton.backgroundColor = .grayColor()
        refreshButton.setTitle("Refresh", forState: UIControlState.Normal)
        refreshButton.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        refreshButton.addTarget(self, action: "refreshButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.loginButton = UIButton(type: UIButtonType.System)
        let loginButton = self.loginButton!
        view.addSubview(loginButton)
        loginButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(refreshButton).offset(100)
            make.top.equalTo(view).offset(40)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        loginButton.backgroundColor = .grayColor()
        loginButton.setTitle("Login", forState: UIControlState.Normal)
        loginButton.setTitleColor(.whiteColor(), forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "loginButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        appeared = true
        
        if let accessToken = NSUserDefaults
            .standardUserDefaults()
            .valueForKey(ViewController.ACCESS_TOKEN_KEY) as? String {
            service = VLService(session: VLSession(accessToken: accessToken))
            load()
        }
    }
    
    func refreshButtonAction(sender: UIButton!) {
        if (service != nil) {
            loaded = false
            load()
        }
    }
    
    func loginButtonAction(sender: UIButton!) {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        let loginVC = VLLoginViewController(
            clientId: ViewController.CLIENT_ID,
            redirectUri: ViewController.REDIRECT_URI)
        loginVC.delegate = self;
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func vlLoginViewController(loginController: VLLoginViewController!, didFailToLoginWithError error: NSError!) {
        
    }
    
    func vlLoginViewController(loginController: VLLoginViewController!, didLoginWithSession session: VLSession!) {
        NSUserDefaults.standardUserDefaults().setValue(session.accessToken, forKey: ViewController.ACCESS_TOKEN_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
        service = VLService(session: session)
        loaded = false
        load()
    }
    
    func deviceSuccess() -> (VLDevicePager!, NSHTTPURLResponse!) -> Void {
        return { (pager, response) -> Void in
            for (index, device) in (pager.devices as! [VLDevice]).enumerate() {
                let deviceNameLabel = UILabel()
                deviceNameLabel.tag = ViewController.DEVICE_NAME_TAG
                self.view.addSubview(deviceNameLabel)
                deviceNameLabel.snp_makeConstraints(closure: { (make) -> Void in
                    make.top.equalTo(self.view).offset(100 + index * 40)
                    make.left.equalTo(self.view).offset(20)
                    make.width.equalTo(self.view)
                    make.height.equalTo(40)
                })
                deviceNameLabel.textAlignment = NSTextAlignment.Left
                deviceNameLabel.text = String(format: "Device Name : %@", device.name)
                deviceNameLabel.textColor = .blackColor()
            }
        }
    }
    
    func deviceFailure() -> (NSError!, NSHTTPURLResponse!, String!) -> Void {
        return { (err, response, str) -> Void in
            self.alert("Error Getting Devices")
        }
    }
    
    func load() {
        if loaded || !appeared { return }
        loaded = true
        for v in view.subviews {
            if v.tag == ViewController.DEVICE_NAME_TAG {
                v.removeFromSuperview()
            }
        }
        service!.getDevicesWithLimit(100, offset: 0,
            onSuccess: deviceSuccess(),
            onFailure: deviceFailure())
    }
    
    func alert(info: String!) {
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

