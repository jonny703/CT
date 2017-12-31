//
//  ChatInputContainerView.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit


protocol InputTextFieldDelegate {
    func inputTextFieldDidChanged(textField: UITextField)
}

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var inputTextFieldDelegate: InputTextFieldDelegate?
    
    var createPostController: CreatePostController? {
        
        didSet {
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: createPostController, action: #selector(createPostController?.handleSelectPostImageView)))
            
            backgroundColor = .clear
        }
    }
    
    var oneToOneChatController: OneToOneChatController? {
        
        didSet {
            sendButton.addTarget(oneToOneChatController, action: #selector(oneToOneChatController?.handleSend), for: .touchUpInside)
            
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: oneToOneChatController, action: #selector(oneToOneChatController?.handleUploadTap)))
            
            backgroundColor = StyleGuideManager.crytpTweetsDefaultColor
        }
    }

    var postCommentController: PostCommentsController? {
        didSet {
            sendButton.addTarget(postCommentController, action: #selector(postCommentController?.handleSend), for: .touchUpInside)
            
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: postCommentController, action: #selector(postCommentController?.handleUploadTap)))
            backgroundColor = .clear
        }
    }
    
    let uploadImageView: UIImageView = {
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: AssetName.addPhoto.rawValue)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
        
    }()
    
    lazy var inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Text Goes Here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(inputTextFieldDidChange(textField:)), for: .editingChanged)
        return textField
        
    }()
    
    let sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.sendButton.rawValue)
        button.setBackgroundImage(image, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button

        
    }()
    
    let containerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    let seperatorLineView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 7).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 3).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -3).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        seperatorLineView.backgroundColor = UIColor.lightGray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputTextField.resignFirstResponder()
        return true
    }
    
    func inputTextFieldDidChange(textField: UITextField) {
        
        if textField == inputTextField {
            self.inputTextFieldDelegate?.inputTextFieldDidChanged(textField: textField)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
