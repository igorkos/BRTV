//
//  ArchiveSplitViewController.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/6/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

class ArchiveSplitViewController: UISplitViewController {
    lazy var master: AchiveChannelsRootController? = {
        return self.viewControllers.first as? AchiveChannelsRootController
    }()
    
    lazy var detail: AchiveChannelProgramsController? = {
        return self.viewControllers[1] as? AchiveChannelProgramsController
    }()
}
