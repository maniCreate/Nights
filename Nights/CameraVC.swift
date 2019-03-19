//
//  ViewController.swift
//  Nights
//
//  Created by Syunsuke Nakao on 2019/03/07.
//  Copyright © 2019 Syunsuke Nakao. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var flashButton: UIBarButtonItem!
    @IBOutlet var timerButton: UIBarButtonItem!
    
    @IBOutlet var cameraView: UIImageView!
    @IBOutlet var controlView: UIView!
    
    var captureSession = AVCaptureSession()
    
    //
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    //キャプチャーの出力データを受け取るオブジェクト
    var photoOutput: AVCapturePhotoOutput?
    
    //プレビュー表示用のレイヤー
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var imagePicker:UIImagePickerController!
    
    var gridLine: gridView!
    var gridflag: Bool = false
    
    var headerMenuView: UIView!
    var headerMenuFlag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        let screenUIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        screenUIButton.setImage(UIImage(named: "screenButton"), for: .normal)
        screenUIButton.contentMode = .scaleAspectFit
        screenUIButton.addTarget(self, action: #selector(CameraVC.appearHeaderMenu), for: .touchUpInside)
        screenButtonView.addSubview(screenUIButton)
        navigationItem.titleView = screenButtonView
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: .default)

        let flashUIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        flashUIButton.setImage(UIImage(named: "flashButton"), for: .normal)
        flashUIButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        flashUIButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        navigationItem.leftBarButtonItem?.customView = flashUIButton
        flashUIButton.addTarget(self, action: #selector(CameraVC.appearGridLine), for: .touchUpInside)

        let timerUIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        timerUIButton.setImage(UIImage(named: "timerButton"), for: .normal)
        timerUIButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        timerUIButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        navigationItem.rightBarButtonItem?.customView = timerUIButton
        
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true

        let buttonSize:CGFloat = 60
        
        let stackView = UIStackView()
        stackView.frame.size = controlView.frame.size
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 7
        controlView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: controlView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: controlView.centerYAnchor).isActive = true
        
        let cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "cameraButton"), for: .normal)
        cameraButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        cameraButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.addTarget(self, action: #selector(CameraVC.shutterButton(_:)), for: .touchUpInside)
        
        let settingButton = UIButton()
        settingButton.setImage(UIImage(named: "settingButton"), for: .normal)
        settingButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        settingButton.imageView?.contentMode = .scaleAspectFit
        settingButton.addTarget(self, action: #selector(CameraVC.toSettings), for: .touchUpInside)
        
        
        let filterButton = UIButton()
        filterButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        filterButton.setImage(UIImage(named: "filterButton"), for: .normal)
        filterButton.imageView?.contentMode = .scaleAspectFit
        
        
        let functionButton = UIButton()
        functionButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        functionButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        functionButton.setImage(UIImage(named: "functionButton"), for: .normal)
        functionButton.imageView?.contentMode = .scaleAspectFit
        
        
        let albumButton = UIButton()
        albumButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        albumButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        albumButton.setImage(UIImage(named: "albumButton"), for: .normal)
        albumButton.imageView?.contentMode = .scaleAspectFit
        albumButton.addTarget(self, action: #selector(CameraVC.openAlbum), for: .touchUpInside)
        
        
        stackView.addArrangedSubview(albumButton)
        stackView.addArrangedSubview(functionButton)
        stackView.addArrangedSubview(cameraButton)
        stackView.addArrangedSubview(filterButton)
        stackView.addArrangedSubview(settingButton)
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    //カメラのプレビューを表示するレイヤーの設定
    func setupPreviewLayer() {
        //設定したAVCaptureSessionのプレビューレイヤーを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //プレビューレイヤーが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        //プレビューレイヤーの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = cameraView.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    //入出力データの設定
    func setupInputOutput() {
        do {
            //指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice!)
            //指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput!)
            //出力データを受け取るオブジェクトを指定
            photoOutput = AVCapturePhotoOutput()
            //出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    
    func setupDevice() {
        
        //カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        //プロパティの条件を満たしたデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        
        //起動時のカメラを設定
        currentDevice = mainCamera
        
    }
    
    //カメラ画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    }
    
    
    //headerMenuのセットアップ
    func headerMenuSetUp() {
        
        headerMenuView = UIView()
        headerMenuView.backgroundColor = UIColor.rgba(red: 0, green: 0, blue: 0, alpha: 0.6)
        headerMenuView.frame = CGRect(x: 0, y: 10, width: self.cameraView.frame.width, height: self.cameraView.frame.height/2)
        
        let stackView = UIStackView()
        stackView.frame.size = headerMenuView.frame.size
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 7
        
        let buttonFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let button1 = UIButton(frame: buttonFrame)
        button1.setTitle("１", for: .normal)
        let button2 = UIButton(frame: buttonFrame)
        button2.setTitle("２", for: .normal)
        let button3 = UIButton(frame: buttonFrame)
        button3.setTitle("３", for: .normal)
        let button4 = UIButton(frame: buttonFrame)
        button4.setTitle("４", for: .normal)
        
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(button4)
        
        headerMenuView.addSubview(stackView)
        
        self.cameraView.addSubview(headerMenuView)
        self.cameraView.bringSubviewToFront(headerMenuView)
    }
    
    //シャッターボタンが押された時の処理
    @objc func shutterButton(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        //フラッシュの設定
        settings.flashMode = .auto
        //カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        //撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as! AVCapturePhotoCaptureDelegate)
    }
    
    @objc func toSettings() {
        performSegue(withIdentifier: "toSettings", sender: nil)
    }
    
    @objc func openAlbum() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func appearGridLine() {
        if gridflag == false {
            gridLine = gridView()
            gridLine.draw(self.cameraView.frame)
            self.cameraView.addSubview(gridLine)
            print("Button tapped.")
            print(gridflag)
            gridflag = true
            
        } else {
            self.gridLine.removeFromSuperview()
            gridflag = false
        }
    }
    @objc func appearHeaderMenu() {
        if headerMenuFlag == false {
            headerMenuSetUp()
            headerMenuFlag = true
        } else {
            self.headerMenuView.removeFromSuperview()
            headerMenuFlag = false
        }
    }

}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    //撮影された画像データが生成された時に呼ばれるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            //Data型をUIImage型に変換
            let uiImage = UIImage(data: imageData)
            //写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
        }
    }
}
