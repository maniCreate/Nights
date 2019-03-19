//
//  GridView.swift
//  Nights
//
//  Created by Syunsuke Nakao on 2019/03/19.
//  Copyright © 2019 Syunsuke Nakao. All rights reserved.
//

import UIKit

class gridView: UIView {
    
    override func draw(_ rect: CGRect) {
        
        self.frame = rect
        self.backgroundColor = .clear
        
        //線を描くクラスUIBezierPathを生成
        let path = UIBezierPath()
        
        //線の起点＋帰着点をそれぞれ指定
        //move=起点
        path.move(to: setPoint(rect, x: 1, y: 0))
        //addline=帰着点
        path.addLine(to: setPoint(rect, x: 1, y: 3))
        
        path.move(to: setPoint(rect, x: 2, y: 0))
        path.addLine(to: setPoint(rect, x: 2, y: 3))
        
        path.move(to: setPoint(rect, x: 0, y: 1))
        path.addLine(to: setPoint(rect, x: 3, y: 1))
        
        path.move(to: setPoint(rect, x: 0, y: 2))
        path.addLine(to: setPoint(rect, x: 3, y: 2))
        
        //設定した起点と帰着点を結ぶ
        path.close()
        //線の色を指定
        UIColor.white.setStroke()
        //線の太さを指定
        path.lineWidth = 1.0
        //線を描画する
        path.stroke()
    }

    //ViewのRectから線の座標を計算する
    private func setPoint(_ rect: CGRect, x: CGFloat, y: CGFloat) -> CGPoint {
        let width = rect.width / 3
        let height = rect.height / 3
        
        let setX = width * x
        let setY = height * y
        return CGPoint(x: setX, y: setY)
    }
}
