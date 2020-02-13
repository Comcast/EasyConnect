/**
*  @file  Loader.swift
*  @brief Implementation Custom Loader (AMDOTS) for Network calls.
*/

import UIKit
import AMDots

class Loader: NSObject {
    
    /* Custom Loader for Network calls*/
    var dotsView: AMDots!
    
    /**
     * @brief Show the custom loader in input view
     * @param view the loader input view
     */
    func showLoader(view: UIView) {
        
          if((dotsView) == nil) {
             print("dots created at first time ")
             let height: CGFloat = UIScreen.main.bounds.size.height
             let width: CGFloat = UIScreen.main.bounds.size.width
             let center: CGPoint = CGPoint(x: width / 2.0, y: height / 2.0)
                    
             dotsView = AMDots(frame: CGRect(x: (view.frame.width/2)-75,
                                             y: view.frame.height/2,
                                             width: 150,
                                             height: 90),
                                colors: [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),#colorLiteral(red: 0.9137254902, green: 0.1176470588, blue: 0.3882352941, alpha: 1)])
            
             dotsView.backgroundColor = UIColor.clear
             dotsView.animationType = .scale
             dotsView.center = center
             view.addSubview(dotsView)
             dotsView.start()
             } else {
                print("only starts")
                dotsView.start()
             }
      }
       
    /**
     * @brief Hide the custom loader in input view
     */
       func hideLoader() {
            if let dots = dotsView {
            print("only stop")
            dots.stop()
       }
     }
}
