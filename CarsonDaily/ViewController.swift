//
//  ViewController.swift
//  CarsonDaily
//
//  Created by Kevin Clark on 8/4/16.
//  Copyright © 2016 Translate Abroad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var artistDict: [String: [String: [String: AnyObject]]]!
    var songsArray: [[String: String]]?
    var selectedSong: String?
    var selectedSamples: [String: AnyObject]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "The Carson Sampler"
        
        let path = NSBundle.mainBundle().pathForResource("Samples", ofType: "plist")!
        artistDict = NSDictionary(contentsOfFile: path) as! [String: [String: [String: AnyObject]]]
        
        for (artist, songs) in artistDict {
            print(artist)
            print(songs)
            for (song, samples) in songs {
                print(samples)
                if songsArray == nil {
                    songsArray = [[artist: song]]
                }
                else {
                    songsArray!.append([artist: song])
                }
            }
        }
        
        // trick to make sure you don't see seperator lines for cells that don't exist
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 1))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return songsArray!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath)
        
        // Configure the cell...
        let songDict = songsArray![indexPath.row]
        let artist = Array(songDict.keys)[0]
        cell.textLabel?.text = artist
        cell.detailTextLabel?.text = songDict[artist]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        // get song and artist
        let songDict = songsArray![indexPath.row]
        let artist = Array(songDict.keys)[0]
        selectedSong = songDict[artist]
        
        // retrieve sample dict using song and artist
        let songsDict = artistDict[artist]
        selectedSamples = songsDict![selectedSong!]
        
        // perform segue
        self.performSegueWithIdentifier("SampleSegue", sender: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "SampleSegue" {
            let sampleVC = segue.destinationViewController as! SampleViewController
            sampleVC.songTitle = selectedSong
            sampleVC.sampleDict = selectedSamples
        }
    }
}

