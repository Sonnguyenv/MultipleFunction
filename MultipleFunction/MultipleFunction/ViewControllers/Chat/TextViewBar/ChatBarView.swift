//
//  ChatBarView.swift
//  MultipleFunction
//
//  Created by Sonnv on 24/07/2021.
//

import UIKit
import RxSwift
import RxCocoa

enum ChatBarViewEvent {
    case send(String)
    case camera
    case handleScroll
}

class ChatBarView: UIView {

    @IBOutlet weak var viewBound: UIView!
    @IBOutlet weak var labelPlaceHolder: UILabel!
    @IBOutlet weak var textInputView: UITextView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var csHeightTextView: NSLayoutConstraint!
    @IBOutlet weak var buttonCamera: UIButton!
    
    let disposeBag = DisposeBag()
    
    let NUMBER_OF_ROWS: CGFloat = 6.5
    let MAX_CHARACTERS: Int = 3000
    
    private var content: String = ""
    private let eventPublishSubject = PublishSubject<ChatBarViewEvent>()
//    private let sendActionCamera = PublishSubject<Void?>()
//    private let sendScroll = PublishSubject<Void?>()
    
//    var handleScroll: Observable<Void?> {
//        return sendScroll.asObservable()
//    }
    
    var actionEvent: Observable<ChatBarViewEvent> {
        return eventPublishSubject.asObserver()
    }
      
    deinit {
        self.eventPublishSubject.onCompleted()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        guard let view = UINib(nibName: "ChatBarView", bundle: nil)
                .instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        self.backgroundColor = .clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTextField()
    }
    
    private func setupTextField() {
        self.viewBound.layer.cornerRadius = 15
        self.viewBound.layer.borderWidth = 1
        self.viewBound.layer.borderColor = UIColor.lightGray.cgColor
        
        self.textInputView.delegate = self
        
        self.textInputView.rx.text.orEmpty
            .do(onNext: { text in
                self.labelPlaceHolder.isHidden = !text.isEmpty
            })
            .subscribe(onNext: { text in
                self.content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }).disposed(by: disposeBag)

        self.textInputView.rx.text.orEmpty
            .map({$0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0})
            .bind(to: self.buttonSend.rx.isEnabled)
            .disposed(by: disposeBag)

        self.buttonSend.rx.tap
            .subscribe(onNext: {
                self.eventPublishSubject.onNext(.send(self.content))
                self.reset()
            }).disposed(by: disposeBag)
        
        self.buttonCamera.rx.tap
            .subscribe(onNext: {
                self.eventPublishSubject.onNext(.camera)
            }).disposed(by: disposeBag)
    }
    
    func reset() {
        self.labelPlaceHolder.isHidden = false
        self.textInputView.text = nil
        self.textViewDidChange(self.textInputView)
    }
}

extension ChatBarView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= MAX_CHARACTERS
    }

    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        let estimateHeight = newFrame.size.height
        let maxHeight = NUMBER_OF_ROWS * textView.font!.lineHeight
        let calculatedHeight = newFrame.size.height > maxHeight ? maxHeight : estimateHeight
        if calculatedHeight > self.csHeightTextView.constant {
            self.eventPublishSubject.onNext(.handleScroll)
        }
        self.csHeightTextView.constant = calculatedHeight
    }
}
