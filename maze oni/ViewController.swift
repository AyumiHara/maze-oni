//
//  ViewController.swift
//  maze oni
//
//  Created by 原 あゆみ on 2018/04/12.
//  Copyright © 2018年 原あゆみ. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    
    
    var playerView : UIView!
    var playerMotionManager: CMMotionManager!
    var speedX :Double = 0.0
    var speedY :Double = 0.0
    
    let screenSize = UIScreen.main.bounds.size
    
    let maze = [
        [1,0,0,0,1,0],
        [1,0,1,0,1,0],
        [3,0,1,0,1,0],
        [1,1,1,0,0,0],
        [1,0,0,1,1,0],
        [0,0,1,0,0,0],
        [0,1,1,0,1,0],
        [0,0,0,0,1,1],
        [0,1,1,0,0,0],
        [0,0,1,1,1,2],
    ]
    
    var startView : UIView!
    var goalView : UIView!
    
    var wallRectArray = [CGRect]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHight = screenSize.height / CGFloat(maze.count)
        let cellOffSetX = screenSize.width / CGFloat(maze[0].count*2)
        let cellOffSetY = screenSize.height / CGFloat(maze.count*2)
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count{
            
            switch maze[y][x]{
            case 1:
                let wallView = createView(x: x, y: y, width: cellWidth, height: cellHight, offSetX: cellOffSetX, offsetY: cellOffSetY)
                wallView.backgroundColor = UIColor.black
                view.addSubview(wallView)
                wallRectArray.append(wallView.frame)
            case 2:
               startView = createView(x: x, y: y, width: cellWidth, height: cellHight, offSetX: cellOffSetX, offsetY: cellOffSetY)
                startView.backgroundColor = UIColor.green
                view.addSubview(startView)
                
                print("スタート")
                print(startView)
                
                
            case 3:
                goalView = createView(x: x, y: y, width: cellWidth, height: cellHight, offSetX: cellOffSetX, offsetY: cellOffSetY)
                goalView.backgroundColor = UIColor.red
                view.addSubview(goalView)
                
                
            default:
                break
                
            }
        }
      }
        
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth/6, height: cellHight/6))
       
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.gray
        self.view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        self.startAccelerometer()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createView(x:Int, y:Int, width:CGFloat, height:CGFloat, offSetX:CGFloat, offsetY: CGFloat ) -> UIView{
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offSetX + width * CGFloat(x), y: offSetX + width * CGFloat(y))
        
        view.center = center
        
        return view
    }
    
    func startAccelerometer() {
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            
            self .speedX += CMAccelerometerData!.acceleration.x
            self .speedY += CMAccelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedX)/3)
            var posY = self.playerView.center.y + (CGFloat(self.speedY)/3)
            
            
            if posX <= self.playerView.frame.width / 2{
                self.speedX = 0
                self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.width / 2{
                self.speedY = 0
                self.playerView.frame.width / 2
                
            }
             self.playerView.center = CGPoint(x: posX, y: posY)
            
        }
        for wallRect in self .wallRectArray {
            if (wallRect.intersects(self.playerView.frame)){
                self.gameCheck(result: "game over", message: "壁に当たりました")
                return
            }
            
            print(goalView)
            if (self.goalView.frame.intersects(self.playerView.frame)){
                self.gameCheck(result: "clear", message: "クリアしました")
                return
            }
        }
        
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func gameCheck(result :String , message:String){
        if playerMotionManager.isAccelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {(action: UIAlertAction!) -> Void in
            
            self.retry()
        })
        
        gameCheckAlert.addAction(retryAction)
        
        self.present(gameCheckAlert, animated: true, completion: nil)
        
    }
    
    func retry() {
        playerView.center = startView.center
        
        if !playerMotionManager.isAccelerometerActive {
            self.startAccelerometer()
        }
        speedX = 0.0
        speedY = 0.0
    }


}

