//
//  ViewController2.swift
//  PillID
//
//  Created by Shruti on 7/23/19.
//  Copyright © 2019 Shruti Sharma. All rights reserved.
//

import UIKit
import MediaPlayer
import BSImageView
import BSImagePicker
import AVFoundation
import Photos

class ViewController2: UIViewController {
    var count = 1
    let total_number_of_pictures = 1
    
    var backgrounds: [PHAsset]! = nil
    var idx = 0
    var programmed = false
    
    let colors = [
        UIColor(red: 233/255, green: 203/255, blue: 198/255, alpha: 1),
        UIColor(red: 38/255, green: 188/255, blue: 192/255, alpha: 1),
        UIColor(red: 253/255, green: 221/255, blue: 164/255, alpha: 1),
        UIColor(red: 235/255, green: 154/255, blue: 171/255, alpha: 1),
        UIColor(red: 87/255, green: 141/255, blue: 155/255, alpha: 1)
    ]
    
    let vc = BSImagePickerViewController()
    var programmaticVolumeChange = false
    
    func changeVolumeProgramatically() {
        print ("Change volume")
        MPVolumeView.setVolume(0)
        programmaticVolumeChange = true
    }
    
    func listenVolumeButton() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            
        } catch {
            print("Error")
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print ("got signal")
        if keyPath == "outputVolume" {
            if (programmaticVolumeChange) {
                programmaticVolumeChange = false
            } else {
                if (count == total_number_of_pictures) {
                    print ("set background")
                    setRandomBackgroundColor()
                    count = 1
                } else {
                    count += 1
                }
            
                changeVolumeProgramatically()
            }
        }
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = false
        manager.requestImage(for: asset, targetSize: CGSize(width: view.bounds.width, height: UIScreen.main.bounds.height), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func setRandomBackgroundColor() {
        
        if (backgrounds == nil) {
            self.view.backgroundColor = colors[idx]
            idx += 1
            if (idx == colors.count) {
                idx = 0
            }
        } else {
            let asset = backgrounds[idx]
            let bg = getAssetThumbnail(asset: asset)
            UIGraphicsBeginImageContext(self.view.frame.size)
            bg.draw(in: self.view.bounds)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
            
            idx += 1
            if (idx == backgrounds.count) {
                idx = 0
            }
        }
        print (idx)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bs_presentImagePickerController(vc, animated: true,
        select: { (asset: PHAsset) -> Void in
//            print ("Asset selected")
        }, deselect: { (asset: PHAsset) -> Void in
//            print ("Asset deselected")
        }, cancel: { (assets: [PHAsset]) -> Void in
//            print ("Image picker cancelled" )
        }, finish: { (assets: [PHAsset]) -> Void in
            self.backgrounds = assets
//            print ("Done")
            self.setRandomBackgroundColor()
        }, completion: nil)
        
        listenVolumeButton()
        
        let volumeView = MPVolumeView(frame: .zero)
        view.addSubview(volumeView)
        
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        slider?.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
