//
//  NavigationBarSettings.swift
//  Nights
//
//  Created by Syunsuke Nakao on 2019/03/07.
//  Copyright © 2019 Syunsuke Nakao. All rights reserved.
//

import UIKit

class NavigationBarSettings: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーのタイトル色
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.rgba(red: 255, green: 255, blue: 255, alpha: 1)]
        //　ナビゲーションバーの背景色
        navigationBar.barTintColor = UIColor.rgba(red: 26, green: 26, blue: 26, alpha: 1)
        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        navigationBar.tintColor = UIColor.rgba(red: 255, green: 255, blue: 255, alpha: 0.7)
        
        
    }
}

extension UIColor {
    class func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

