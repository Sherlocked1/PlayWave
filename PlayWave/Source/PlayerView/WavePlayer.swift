//
//  WavePlayer.swift
//  PlayWave
//
//  Created by Syber Expertise on 19/02/2023.
//

import UIKit
import AVFoundation
import AVKit

public protocol WavePlayerDelegate {
    func didFinishPlaying()
    func failedWithError(_ error:Error)
    func finishedLoading()
}

@IBDesignable open class WavePlayer: UIView {
    
    @IBOutlet var playBtn           : UIButton!
    @IBOutlet var resizeBtn         : UIButton!
    @IBOutlet var playerView        : UIView!
    @IBOutlet var contentView       : UIView!
    @IBOutlet var controlsView      : UIView!
    @IBOutlet var loadingIndicator  : UIActivityIndicatorView!
    
    var avPlayer                    : AVPlayer = .init()
    var avPlayerLayer               : AVPlayerLayer = .init()
    
    public var delegate : WavePlayerDelegate?
    
    
    @IBInspectable public var controlsColor : UIColor = .white {
        didSet{
            self.playBtn.tintColor = controlsColor
            self.resizeBtn.tintColor = controlsColor
            self.loadingIndicator.tintColor = controlsColor
        }
    }
    
    public var volume : Float = 1 {
        didSet{
            self.avPlayer.volume = volume
        }
    }
    
    public var willStartPlayingWhenReady : Bool  = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func configureVideoWith(url:URL) {
        let avAsset = AVAsset.init(url: url)
        self.avPlayerLayer = .init(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        
        let item = AVPlayerItem.init(asset: avAsset)
        self.avPlayer.replaceCurrentItem(with: item)
        
        avPlayerLayer.frame = playerView.bounds
        self.playerView.layer.addSublayer(avPlayerLayer)
        
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.status), let statusNumber = change?[.newKey] as? NSNumber {
            let status = AVPlayer.Status(rawValue: statusNumber.intValue)
            if status == .readyToPlay {
                self.loadingIndicator.stopAnimating()
                self.delegate?.finishedLoading()
                self.avPlayerLayer.frame = self.bounds
                
                if willStartPlayingWhenReady {
                    self.avPlayer.play()
                    self.playBtn.isSelected = true
                }
                
            }else if status == .failed {
                let playerItem = object as! AVPlayerItem
                if let error = playerItem.error as NSError? {
                    self.delegate?.failedWithError(error)
                }
            }
        }
    }
    
    @objc func playBtnClicked(){
        playBtn.isSelected = !playBtn.isSelected
        if playBtn.isSelected {
            self.play()
        }else{
            self.pause()
        }
    }
    
    public func pause(){
        self.avPlayer.pause()
    }
    
    public func play(){
        self.avPlayer.play()
    }
    
    @objc func resizeBtnClicked(){
        self.avPlayerLayer.frame = playerView.bounds
    }
    
    func commonInit(){
        contentView = loadNib()
        contentView.fixInView(self)
        
        handleTap()
        
        self.playBtn.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        self.resizeBtn.addTarget(self, action: #selector(resizeBtnClicked), for: .touchUpInside)
        
        //images for both play and pause state for the button
        self.playBtn.setImage(.init(systemName: "play.fill"), for: .normal)
        self.playBtn.setImage(.init(systemName: "pause.fill"), for: .selected)
    }
    
    func handleTap(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func toggleControls(){
        self.controlsView.isHidden = !self.controlsView.isHidden
    }
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}

extension WavePlayer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: self) == true, view != playerView,
           view != controlsView || touch.location(in: controlsView).y > controlsView.bounds.size.height {
            return false
        } else {
            return true
        }
    }
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
