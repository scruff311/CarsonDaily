//
//  SampleViewController.swift
//  CarsonDaily
//
//  Created by Kevin Clark on 8/4/16.
//  Copyright © 2016 Translate Abroad. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class SampleViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sampleTempoLbl: UILabel!
    @IBOutlet weak var tapTempoLabel: UILabel!
    @IBOutlet weak var flashTempoView: UIView!
    @IBOutlet weak var noTouchyLbl: UILabel!
    
    var songTitle: String!
    var sampleDict: [String: AnyObject]!
    var sampleArray: [Sample]!
    var currentSample: Sample?
    var audioPlayer: AVAudioPlayer!
    var defaultTempo: Double!
    var lastTapTempo: Double!
    var lastTapTime: Date!
    var tapIntervals: [Double]!
    var flashColor: UIColor!
    
    // MARK: - View
    
    override func viewDidLoad()
    {
        print("VDL")
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true

        // Do any additional setup after loading the view.
        self.navigationItem.title = songTitle
        navigationController?.navigationBar.tintColor = UIColor.white
        
        sampleTempoLbl.layer.masksToBounds = true
        sampleTempoLbl.layer.cornerRadius = 5
        tapTempoLabel.layer.masksToBounds = true
        tapTempoLabel.layer.cornerRadius = 5
        flashTempoView.layer.masksToBounds = true
        flashTempoView.layer.cornerRadius = flashTempoView.bounds.size.width / 2 //make it a circle
        
        // create array of sample objects
        defaultTempo = sampleDict["Tempo"] as! Double
        lastTapTempo = defaultTempo
        sampleTempoLbl.text = String(defaultTempo)
        tapTempoLabel.text = ""
        
        flashColor = UIColor.init(red: 241/255.0, green: 180/255.0, blue: 111/255.0, alpha: 1)
        
        let sampleOrder = sampleDict["Order"] as! [String]
        for i in 0 ..< sampleOrder.count {
            let sampleTitle = sampleOrder[i]
            let fileName = sampleDict[sampleTitle] as! String
            let newSample = Sample(sampleTitle, fileName: fileName, order: i)
            if sampleArray == nil {
                sampleArray = [newSample]
            }
            else {
                sampleArray.append(newSample)
            }
        }
        // get the initial sampler ready to play
        loadSampleAtIndex(0)
        
        // trick to make sure you don't see seperator lines for cells that don't exist
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        print("VDA")
        let path = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.none)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Buttons
    
    @IBAction func tempoTouch(_ sender: AnyObject)
    {
        // hasn't been 4 taps yet
        if tapIntervals?.count < 3 {
            // flash tempo light
            flashTempoLight(0)
            
            // first tap, save and return
            if lastTapTime == nil {
                lastTapTime = Date()
                tempoButton.setTitle("3", for: UIControlState())
                print("1")
                return
            }
            
            let timeInterval = lastTapTime.timeIntervalSinceNow*(-1)

            // add first tap interval to array
            if tapIntervals == nil || tapIntervals?.count == 0 {
                tapIntervals = [timeInterval]
                lastTapTime = Date()
                tempoButton.setTitle("2", for: UIControlState())
                print("2")
                return
            }

            // add 2nd and 3rd tap intervals to array
            tapIntervals.append(timeInterval)
            lastTapTime = Date()
            if tapIntervals.count == 2 {
                tempoButton.setTitle("1", for: UIControlState())
                print("3")
            }
            else {
                tempoButton.setTitle("GO!", for: UIControlState())
                // calculate and set tempo
                var averageBeat = calculateTempo()
                let averageInterval = 60.0 / averageBeat
                lastTapTempo = averageBeat
                setPlayRate(Float(averageBeat/defaultTempo))
                
                // trim decimal for label display
                averageBeat *= 10
                let beatInt = Int(averageBeat)
                let beatFloat = Float(beatInt) / 10.0
                tapTempoLabel.text = String(beatFloat)
                print("4")
                
                // play audio after average time interval
                Timer.scheduledTimer(timeInterval: averageInterval,
                                                       target: self,
                                                       selector: #selector(SampleViewController.playAudio),
                                                       userInfo: nil,
                                                       repeats: false)
                
                // reset tempo vars
                tapIntervals.removeAll()
                lastTapTime = nil
                // disable tempo button
                tempoButton.setTitle("4", for: UIControlState())
                tempoButton.isEnabled = false
            }
        }
        // else 3 intervals recorded, calculate bpm and play sound
        else {
//            print("GO!")
//            playAudio()
            
//            tapIntervals.removeAll()
//            lastTapTime = nil
//            tempoButton.setTitle("4", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playTouch(_ sender: AnyObject)
    {
        setPlayRate(Float(lastTapTempo/defaultTempo))
        playAudio()
    }
    
    @IBAction func stopTouch(_ sender: AnyObject)
    {
        if audioPlayer == nil {
            return
        }
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        tempoButton.isEnabled = true
        playButton.isEnabled = true
        flashTempoView.layer.removeAllAnimations()
    }
    
    @IBAction func clearTouch(_ sender: AnyObject)
    {
        lastTapTempo = defaultTempo
        tapTempoLabel.text = ""
    }
    
    func flashTempoLight(_ repeatCount: Float)
    {
        // animate flash tempo view
        flashTempoView.backgroundColor = flashColor
        UIView.animate(withDuration: 60/lastTapTempo,
                                   delay: 0,
                                   options: .repeat,
                                   animations: {
                                    UIView.setAnimationRepeatCount(repeatCount)
                                    self.flashTempoView.backgroundColor = UIColor.black
            }, completion: { (complete) in
                // something to do
        })
    }
    
    //MARK: - Audio Player
    
    func calculateTempo() -> Double
    {
        let averageInterval = tapIntervals.reduce(0, +) / Double(tapIntervals.count)
        let averageBeat = 60.0 / averageInterval
        print("tempo: \(averageBeat)")
        return averageBeat
    }
    
    func setPlayRate(_ rate: Float)
    {
        audioPlayer.rate = rate
        print("rate: \(rate)")
    }
    
    func loadSampleAtIndex(_ index: Int)
    {
        let indexPath = IndexPath(row: index, section: 0);
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        setSampleToAudioPlayer()
    }
    
    func setSampleToAudioPlayer()
    {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: currentSample!.fileUrl as URL)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("audio error")
        }
        
        audioPlayer.volume = 1
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
    }
    
    func playAudio()
    {
        audioPlayer.play()
        
        // start flashing the tempo light
        let numberOfBeats = (defaultTempo / 60.0) * audioPlayer.duration
        let numberOfBeatsInt = Int(numberOfBeats + 0.5) //round it off
        print("number of beats = \(numberOfBeats), Int = \(numberOfBeatsInt)")
        flashTempoLight(Float(numberOfBeatsInt))
        
        tempoButton.isEnabled = false
        playButton.isEnabled = false
        noTouchyLbl.isHidden = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if flag == true {
            // increment row
            var index = currentSample?.order
            index! += 1
            // last row, return
            if index == sampleArray.count {
                index! = 0
            }
            
            loadSampleAtIndex(index!)
            
            tempoButton.isEnabled = true
            playButton.isEnabled = true
            noTouchyLbl.isHidden = false
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return sampleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SampleCell", for: indexPath) as! SampleCell
        
        // Configure the cell...
        cell.sample = sampleArray[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SampleCell
        cell.setSelected(true, animated: true)
        
        // grab sample for this row
        currentSample = cell.sample
        
        setSampleToAudioPlayer()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAtIndexPath indexPath: IndexPath)
    {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SampleCell
        cell.setSelected(false, animated: true)
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
//    {
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
