//
//  TrackDetailView.swift
//  AppleMusicClone
//
//  Created by 123 on 12.11.2022.
//

import UIKit
import SDWebImage
import AVKit
import MediaPlayer

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack()
    func moveForwardForPreviousTrack()
}

class TrackDetailView: UIView {

    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var miniTrackNameLabel: UILabel!
    @IBOutlet weak var miniAuthorNameLabel: UILabel!
    @IBOutlet weak var miniPlayButton: UIButton!
    @IBOutlet weak var miniNextSongButton: UIButton!
    @IBOutlet weak var miniAddSongButton: UIButton!
    @IBOutlet weak var miniTrackImage: UIImageView!
    
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var reduceValueImageView: UIImageView!
    @IBOutlet weak var reduceButton: UIButton!
    @IBOutlet weak var increaseValueImageView: UIImageView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var leftInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetConstraint: NSLayoutConstraint!
    
    private let player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        return player
    }()
    
    var delegate: TrackMovingDelegate?
    weak var transitionDelegate: TransitionDelegate?
    
    var viewModel: Track?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        trackImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        volumeSlider.setThumbImage(UIImage(named: "customThumb"), for: .normal)
        observeCurrentTime()
        setupShadows()
        setupCorners()
        setupGestures()
        addActionsToControlCenter()
    }
    
    private func setupShadows() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.9
        
        trackImage.layer.shadowColor = UIColor.black.cgColor
        trackImage.layer.shadowOffset = CGSize.zero
        trackImage.layer.shadowRadius = 20
        trackImage.layer.shadowOpacity = 0.9
    }
    
    private func setupCorners() {
        layer.cornerRadius = 32
        miniTrackView.layer.cornerRadius = 32
        miniTrackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        miniTrackImage.layer.cornerRadius = 10
    }
    
    func setup(viewModel: Track) {
        self.viewModel = viewModel
        trackNameLabel.text = viewModel.trackName
        authorNameLabel.text = viewModel.artistName + " | " + (viewModel.collectionName ?? "")
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "--:--"
        
        guard let stringURL = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600"),
              let url = URL(string: stringURL) else { return }
        trackImage.sd_setImage(with: url) { [self]_,_,_,_ in
            backgroundImage.image = trackImage.image
        }
        pauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        playTrack(audioURL: viewModel.audioUrl)
        timeSlider.value = 0
        setupMiniTrackView(viewModel: viewModel, url: url)
        monitorStartTime()
    }
    
    private func setupMiniTrackView(viewModel: Track, url: URL) {
        miniTrackNameLabel.text = viewModel.trackName
        miniAuthorNameLabel.text = viewModel.artistName + " | " + (viewModel.collectionName ?? "")
        miniPlayButton.setImage(UIImage(named: "miniPauseButton"), for: .normal)
        miniTrackImage.sd_setImage(with: url)
    }
    
    private func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized))
        miniTrackView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniTrackView.addGestureRecognizer(panRecognizer)
        
        let dismissPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan))
        addGestureRecognizer(dismissPanRecognizer)
        
        let skipPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSkipPan))
        trackImage.addGestureRecognizer(skipPanRecognizer)
    }
    
    @objc private func handleSkipPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            dismissPanRecognizerChanged(gesture: gesture)
        case .ended:
            dismissPanRecognizerEnded(gesture: gesture)
            if gesture.velocity(in: superview).x > 150 && gesture.translation(in: superview).x > -gesture.translation(in: superview).y && gesture.translation(in: superview).x > 100 {
                previousTrackButton.sendActions(for: .allTouchEvents)
            } else if gesture.velocity(in: superview).x < -150 && gesture.translation(in: superview).x < -gesture.translation(in: superview).y && gesture.translation(in: superview).x < -100{
                nextTrackButton.sendActions(for: .allTouchEvents)
            }
        default:
            break
        }
    }
    
    @objc private func handleDismissPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            dismissPanRecognizerChanged(gesture: gesture)
        case .ended:
            dismissPanRecognizerEnded(gesture: gesture)
        default:
            break
        }
    }
    
    private func addAnimationRotate() {
        UIView.animate(withDuration: 0.1) { [self] in
            trackImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) { [self] in
                let transform = CATransform3DRotate(trackImage.transform3D, 45, 0, 1, 0)
                trackImage.transform3D = transform
            }
        }
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            panRecognizerChanged(gesture: gesture)
        case .ended:
            panRecognizerEnded(gesture: gesture)
        
            if gesture.velocity(in: superview).x > 300 && gesture.translation(in: superview).x > -gesture.translation(in: superview).y {
                previousTrackButton.sendActions(for: .allTouchEvents)
            } else if gesture.velocity(in: superview).x < -300 && gesture.translation(in: superview).x < -gesture.translation(in: superview).y {
                nextTrackButton.sendActions(for: .allTouchEvents)
            }
        default:
            break
        }
    }
    
    private func panRecognizerChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        transform = CGAffineTransform(translationX: 0, y: translation.y)
        miniTrackView.alpha = 1 + translation.y / 200
    }
    
    private func dismissPanRecognizerChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        transform = CGAffineTransform(translationX: 0, y: translation.y)
        miniTrackView.alpha = translation.y / bounds.height
    }
    
    private func panRecognizerEnded(gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.transform = .identity
            let velocity = gesture.velocity(in: self.superview)
            let translation = gesture.translation(in: self.superview)
            if velocity.y < -500 || translation.y < -300 {
                self.handleTapMaximized()
            } else {
                self.miniTrackView.alpha = 1
            }
        }
    }
    
    private func dismissPanRecognizerEnded(gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.transform = .identity
            let velocity = gesture.velocity(in: self.superview)
            let translation = gesture.translation(in: self.superview)
            if velocity.y > 500 || translation.y > 150 {
                self.transitionDelegate?.reduceView()
            } else {
                self.miniTrackView.alpha = 0
            }
        }
    }
    
    @objc private func handleTapMaximized() {
        transitionDelegate?.increseView(viewModel: nil)
    }
    
    private func monitorStartTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.largeTrackImage()
            self?.updateInfoCenter()
        }
    }
    
    @IBAction private func sliderUpAction(_ sender: UISlider) {
        switch sender.value {
        case 1:
            animate(view: increaseValueImageView) {}
        case 0:
            animate(view: reduceValueImageView) {}
        default:
            break
        }
    }
    @IBAction func timeSliderEditingDidBegin(_ sender: UISlider) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            sender.transform = CGAffineTransform(scaleX: 1, y: 2)
        }
    }
    @IBAction func timeSliderEditingDidEnd(_ sender: UISlider) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            sender.transform = .identity
        }
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        switch sender.value {
        case 1:
            increaseValueImageView.image = UIImage(named: "increaseVolumeActiveIcon")
        case 0:
            reduceValueImageView.image = UIImage(named: "reduceVolumeActiveIcon")
        default:
            increaseValueImageView.image = UIImage(named: "increaseVolumeIcon")
            reduceValueImageView.image = UIImage(named: "reduceVolumeIcon")
        }
        player.volume = sender.value
        
    }
    
    @IBAction private func timeSliderValueChanged(_ sender: UISlider) {
        let percentage = sender.value
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let currentTime = percentage * Float(totalSeconds)
        let cmtime = CMTimeMake(value: Int64(currentTime), timescale: 1)
        player.seek(to: cmtime)
    }
    
    private func observeCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateTimeLabel(time: time)
            self?.updateSlider(time: time)
            self?.updateInfoCenter()
        }
    }
    
    private func updateTimeLabel(time: CMTime) {
        self.currentTimeLabel.text = time.toDisplayString()
        guard let duration = self.player.currentItem?.duration else { return }
        
        let difference = duration - time
        self.durationTimeLabel.text = "-" + difference.toDisplayString()
    }
    
    private func updateSlider(time: CMTime) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        guard let duration = self.player.currentItem?.duration else { return }
        let totalTime = CMTimeGetSeconds(duration)
        let percentage = currentTime / totalTime
        timeSlider.value = Float(percentage)
    }
    
    private func largeTrackImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1 ,options: [.curveEaseInOut]) {
            self.trackImage.transform = .identity
        }
    }
    
    private func reduceTrackImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1 ,options: [.curveEaseInOut]) {
            self.trackImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    private func playTrack(audioURL: String) {
        guard let url = URL(string: audioURL) else { return }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    @IBAction private func closeViewAction(_ sender: UIButton) {
        transitionDelegate?.reduceView()
    }
    
    @IBAction private func previousTrackAction(_ sender: UIButton) {
        animate(view: sender) { [weak self] in
            self?.delegate?.moveBackForPreviousTrack()
        }
        pauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        player.pause()
    }
    
    @IBAction private func nextTrackAction(_ sender: UIButton) {
        animate(view: sender) { [weak self] in
            self?.delegate?.moveForwardForPreviousTrack()
        }
        pauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        player.pause()
    }
    
    @IBAction private func pauseAction(_ sender: UIButton) {
        animate(view: sender) {}
    
        switch player.timeControlStatus {
        case .paused:
            player.play()
            pauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
            miniPlayButton.setImage(UIImage(named: "miniPauseButton"), for: .normal)
            leftInsetConstraint.constant = 32
            rightInsetConstraint.constant = -32
            
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
                self.trackImage.clipsToBounds = false
            }
        case .playing:
            player.pause()
            pauseButton.setImage(UIImage(named: "playButtonLight"), for: .normal)
            miniPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
            leftInsetConstraint.constant = 48
            rightInsetConstraint.constant = -48
            
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
                self.trackImage.clipsToBounds = true
            }
        default:
            break
        }
    }
    
    private func animate(view: UIView, with completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15, delay: 0, options: []) {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: []) {
                view.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }
    
    func updateInfoCenter() {
        guard let item = player.currentItem else {return}
        var nowPlayingInfo : [String: Any] = [
            MPMediaItemPropertyPlaybackDuration: item.duration.seconds,
            MPMediaItemPropertyTitle: viewModel?.trackName as Any,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: item.currentTime().seconds,
            MPMediaItemPropertyMediaType: MPMediaType.anyAudio.rawValue,
            MPMediaItemPropertyArtist: viewModel?.artistName as Any
        ]
        guard let image = trackImage.image else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            return
        }
        let albumArt = MPMediaItemArtwork(boundsSize: trackImage.frame.size) { sz in
            return image
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArt
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func addActionsToControlCenter(){
        addActionToPlayCommand()
        addActionToPauseCommnd()
        addActionToPreviousCommand()
        addActionToNextCommand()
        addActionToChangePlaybackPositionCommand()
    }
    
    func addActionToChangePlaybackPositionCommand() {
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let currentEvent = event as? MPChangePlaybackPositionCommandEvent else { return .noActionableNowPlayingItem}
            let cmtime = CMTime(seconds: currentEvent.positionTime, preferredTimescale: CMTimeScale(2))
            self?.player.seek(to: cmtime)
            return .success
        }
    }
    func addActionToPlayCommand(){
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] event in
            self?.pauseButton.sendActions(for: .allTouchEvents)
            return .success
        }
    }
    func addActionToPauseCommnd(){
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] event in
            self?.pauseButton.sendActions(for: .allTouchEvents)
            return .success
        }
    }
    func addActionToPreviousCommand(){
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self] event in
            self?.previousTrackButton.sendActions(for: .allTouchEvents)
            return .success
        }
    }
    func addActionToNextCommand(){
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = true
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] event in
            self?.nextTrackButton.sendActions(for: .allTouchEvents)
            return .success
        }
    }
}
