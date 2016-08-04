//
//  SampleViewController.swift
//  CarsonDaily
//
//  Created by Kevin Clark on 8/4/16.
//  Copyright © 2016 Translate Abroad. All rights reserved.
//

import UIKit
import AVFoundation

class SampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var songTitle: String!
    var sampleDict: [String: AnyObject]!
    var sampleArray: [Sample]!
    var currentSample: Sample?
    var audioPlayer: AVAudioPlayer!
    var defaultTempo: Double!
    var lastTapTime: NSDate!
    var tapIntervals: [Double]!
    
    override func viewDidLoad()
    {
        print("VDL")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = songTitle
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // create array of sample objects
        defaultTempo = sampleDict["Tempo"] as! Double
        let sampleOrder = sampleDict["Order"] as! [String]
        for sampleTitle in sampleOrder {
            let fileName = sampleDict[sampleTitle] as! String
            let newSample = Sample(sampleTitle, fileName: fileName)
            if sampleArray == nil {
                sampleArray = [newSample]
            }
            else {
                sampleArray.append(newSample)
            }
        }
        currentSample = sampleArray[0]
        
        // trick to make sure you don't see seperator lines for cells that don't exist
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 1))
    }
    
    override func viewDidAppear(animated: Bool)
    {
        print("VDA")
        print("current sample: \(currentSample?.fileName)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
                print("4")
            }
            
        }
        // else 3 intervals recorded, calculate bpm and play sound
        else {
            print("GO!")
            print(tapIntervals)
            
            var totalTime: Double = 0
            for time in tapIntervals {
                totalTime += time
            }
            
            let averageBeat = 60.0 / (totalTime / Double(tapIntervals.count))
            print("tempo: \(averageBeat)")
            
            playAudio(Float(averageBeat/defaultTempo))
            
            tapIntervals.removeAll()
            lastTapTime = nil
            tempoButton.setTitle("4", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playTouch(sender: AnyObject)
    {
        playAudio(1.0)
    }
    
    @IBAction func stopTouch(sender: AnyObject)
    {
        audioPlayer.stop()
    }
    
    func playAudio(rate: Float)
    {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: currentSample!.fileUrl)
        }
        catch {
            print("audio error")
        }
        
        audioPlayer.prepareToPlay()
        audioPlayer.enableRate = true
        audioPlayer.rate = rate
        audioPlayer.play()
        print("rate: \(rate)")
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
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SampleCell
        cell.setSelected(false, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        print("WDC")
        if indexPath.row == 0 {
            print("row 1")
            cell as! SampleCell
            cell.setSelected(true, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
