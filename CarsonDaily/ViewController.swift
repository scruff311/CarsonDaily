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
        
        UIApplication.shared.isIdleTimerDisabled = false

        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "The Carson Sampler"
        
        let path = Bundle.main.path(forResource: "Samples", ofType: "plist")!
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
        
        tableView.rowHeight = 65
        
        // trick to make sure you don't see seperator lines for cells that don't exist
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return songsArray!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        // Configure the cell...
        let songDict = songsArray![indexPath.row]
        let artistArray = Array(songDict.keys)
        let artist = artistArray[0]
        cell.textLabel?.text = artist
        cell.detailTextLabel?.text = songDict[artist]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        // get song and artist
        let songDict = songsArray![indexPath.row]
        let artistArray = Array(songDict.keys)
        let artist = artistArray[0]
        selectedSong = songDict[artist]
        
        // retrieve sample dict using song and artist
        let songsDict = artistDict[artist]
        selectedSamples = songsDict![selectedSong!]
        
        // perform segue
        self.performSegue(withIdentifier: "SampleSegue", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "SampleSegue" {
            let sampleVC = segue.destination as! SampleViewController
            sampleVC.songTitle = selectedSong
            sampleVC.sampleDict = selectedSamples
        }
    }
}

