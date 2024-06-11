//
//  SIRootWidgets.swift
//  KKR App
//
//  Created by Ajinkya Sonar on 13/02/23.
//

import UIKit

class SICustomWidget {
    var widgetType: KKRLayoutWidgetType?
    var customLayout: SILayoutBuilderWidget?
    var layoutData: [SILayoutData]?
    var isLoaded: Bool?
    var isLoadingData: Bool?
    var itemHeight: CGFloat?
    var itemRatio: CGFloat?
}

class SICustomCellWidget {
    var item: SILayoutBuilderWidgetDataItem?
    var cellWidgetType: KKRCellWidgetType?
    var widgetIndex: Int?
    var customLayout: SILayoutBuilderWidget?
    var dependencyItems: [SIFeedsListingItem]?
    var cellItemHeight: CGFloat?
    var isLoaded: Bool?
    var isLoadingData: Bool?
}
