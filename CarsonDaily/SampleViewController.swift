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

class SampleViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sampleTempoLbl: UILabel!
    @IBOutlet weak var tapTempoLabel: UILabel!
    
    var songTitle: String!
    var sampleDict: [String: AnyObject]!
    var sampleArray: [Sample]!
    var currentSample: Sample?
    var audioPlayer: AVAudioPlayer!
    var defaultTempo: Double!
    var lastTapTempo: Double!
    var lastTapTime: NSDate!
    var tapIntervals: [Double]!
    
    // MARK: - View
    
    override func viewDidLoad()
    {
        print("VDL")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = songTitle
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        sampleTempoLbl.layer.masksToBounds = true
        sampleTempoLbl.layer.cornerRadius = 5
        tapTempoLabel.layer.masksToBounds = true
        tapTempoLabel.layer.cornerRadius = 5
        
        // create array of sample objects
        defaultTempo = sampleDict["Tempo"] as! Double
        lastTapTempo = defaultTempo
        sampleTempoLbl.text = String(defaultTempo)
        tapTempoLabel.text = ""
        
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
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 1))
    }
    
    override func viewDidAppear(animated: Bool)
    {
        print("VDA")
        let path = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(path, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Buttons
    
    @IBAction func tempoTouch(sender: AnyObject)
    {
        // hasn't been 4 taps yet
        if tapIntervals?.count < 3 {
            // first tap, save and return
            if lastTapTime == nil {
                lastTapTime = NSDate()
                tempoButton.setTitle("3", forState: UIControlState.Normal)
                print("1")
                return
            }
            
            let timeInterval = lastTapTime.timeIntervalSinceNow*(-1)

            // add first tap interval to array
            if tapIntervals == nil || tapIntervals?.count == 0 {
                tapIntervals = [timeInterval]
                lastTapTime = NSDate()
                tempoButton.setTitle("2", forState: UIControlState.Normal)
                print("2")
                return
            }

            // add 2nd and 3rd tap intervals to array
            tapIntervals.append(timeInterval)
            lastTapTime = NSDate()
            if tapIntervals.count == 2 {
                tempoButton.setTitle("1", forState: UIControlState.Normal)
                print("3")
            }
            else {
                tempoButton.setTitle("GO!", forState: UIControlState.Normal)
                var averageBeat = calculateTempo()
                lastTapTempo = averageBeat
                // trim decimal for label display
                averageBeat *= 10
                let beatInt = Int(averageBeat)
                let beatFloat = Float(beatInt) / 10.0
                tapTempoLabel.text = String(beatFloat)
                print("4")
                
                // calculate and set tempo
                print(tapIntervals)
                let averageTempo = calculateTempo()
                setPlayRate(Float(averageTempo/defaultTempo))
            }
            
        }
        // else 3 intervals recorded, calculate bpm and play sound
        else {
            print("GO!")
            playAudio()
            
            tapIntervals.removeAll()
            lastTapTime = nil
            tempoButton.setTitle("4", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playTouch(sender: AnyObject)
    {
        setPlayRate(Float(lastTapTempo/defaultTempo))
        playAudio()
    }
    
    @IBAction func stopTouch(sender: AnyObject)
    {
        if audioPlayer == nil {
            return
        }
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        tempoButton.enabled = true
        playButton.enabled = true
    }
    
    @IBAction func clearTouch(sender: AnyObject)
    {
        lastTapTempo = defaultTempo
        tapTempoLabel.text = ""
    }
    
    func calculateTempo() -> Double
    {
        var totalTime: Double = 0
        for time in tapIntervals {
            totalTime += time
        }
        
        let averageBeat = 60.0 / (totalTime / Double(tapIntervals.count))
        print("tempo: \(averageBeat)")
        return averageBeat
    }
    
    func setPlayRate(rate: Float)
    {
        audioPlayer.rate = rate
        print("rate: \(rate)")
    }
    
    func loadSampleAtIndex(index: Int)
    {
        let indexPath = NSIndexPath(forRow: index, inSection: 0);
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        setSampleToAudioPlayer()
    }
    
    func setSampleToAudioPlayer()
    {
        do {
        try audioPlayer = AVAudioPlayer(contentsOfURL: currentSample!.fileUrl)
        }
        catch {
        print("audio error")
        }
        
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()
    }
    
    func playAudio()
    {
        audioPlayer.play()
        
        tempoButton.enabled = false
        playButton.enabled = false
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool)
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
            
            tempoButton.enabled = true
            playButton.enabled = true
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return sampleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SampleCell", forIndexPath: indexPath) as! SampleCell
        
        // Configure the cell...
        cell.sample = sampleArray[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SampleCell
        cell.setSelected(true, animated: true)
        
        // grab sample for this row
        currentSample = cell.sample
        
        setSampleToAudioPlayer()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
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
