//
//  BackgroundTimer.swift
//  Chipldapp
//
//  Created by Mr.Б on 19/11/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import Foundation

class BackgroundTimer {
    
    let timeInterval: TimeInterval
    var eventHandler: (() -> Void)?
    private var state: State = .suspended
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: .infinity)
        t.setEventHandler(handler: { [weak self] in self?.eventHandler?() })
        return t
    }()
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume() // If the timer is suspended, calling cancel without resuming triggers a crash (documented here: https://forums.developer.apple.com/thread/15902)
        eventHandler = nil
    }
    
    func resume() {
        guard state != .resumed else { return }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        guard state != .suspended else { return }
        state = .suspended
        timer.suspend()
    }

    private enum State {
        case suspended
        case resumed
    }
}
