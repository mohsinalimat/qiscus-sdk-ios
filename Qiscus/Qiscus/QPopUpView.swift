//
//  QPopUpView.swift
//  Example
//
//  Created by Ahmad Athaullah on 10/31/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class QPopUpView: UIViewController {

    var sharedInstance = QPopUpView()
    
    var text:String = ""
    var image:UIImage?
    var isVideo:Bool = false
    var attributedText:NSMutableAttributedString?
    
    var firstAction:(()->Void) = {}
    var secondAction:(()->Void) = {}
    var singleAction:(()->Void) = {}
    var oneButton:Bool = false
    
    let fixedWidth:CGFloat = 240
    
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView:UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        if self.image != nil {
            self.imageView.image = self.image
            self.imageViewHeight.constant = 120
        }else{
            self.imageViewHeight.constant = 0
        }
        self.containerView.layer.cornerRadius = 10
        
        
        self.imageView.clipsToBounds = true
        if self.attributedText == nil{
            self.textView.text = self.text
        }else{
            self.textView.attributedText = self.attributedText
        }
        
        let newSize = self.textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        //var height = 55
        if newSize.height > 55 {
            self.textViewHeight.constant = newSize.height + 5
            self.containerHeight.constant = newSize.height + 50
        }
        
        if oneButton {
            self.firstButton.isHidden = true
            self.secondButton.isHidden = true
            self.singleButton.isHidden = false
        }else{
            self.firstButton.isHidden = false
            self.secondButton.isHidden = false
            self.singleButton.isHidden = true
        }
        self.containerView.layoutIfNeeded()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func firstButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.firstAction()
    }

    @IBAction func secondButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.secondAction()
    }
    @IBAction func singleButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.singleAction()
    }

}
