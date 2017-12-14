 //
//  ViewController.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 8..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import UIKit
import AVFoundation
//import Alamofire
import CoreML
import Accelerate
@available(iOS 11.0, *)
class ViewController: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var serButton: UIButton!
    @IBOutlet weak var filelistButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    public static let shared = ViewController()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var prob : [Double]!
    var date = Date()
    let formatter = DateFormatter()
    var result : String = ""
    var r : Int = 0
    let model =  serLSTM()
    // var flag = 0
    @IBOutlet weak var back: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // d Do any additional setup after loading the view, typically from a nib.
        formatter.dateFormat = "yyyy-MM-dd.HH.mm.ss"
        self.recordButton.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.filelistButton.layer.cornerRadius = 10
        self.serButton.layer.cornerRadius = 10
        self.helpLabel.layer.cornerRadius = 125
        recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in          // 마이크 승인여부
                DispatchQueue.main.async {
                    if allowed {    // 허용되어있으면 loadUI실행
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func play(_ sender:UIButton){
        if ViewController.shared.result != ""{
            if sender.titleLabel?.text == "재생"{
                recordButton.isEnabled = false
                sender.setTitle("중단", for: .normal)
                preparePlayer()
                audioPlayer.play()
            }
            else{
                audioPlayer.stop()
                self.audioPlayerDidFinishPlaying(audioPlayer, successfully: true)
            }
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("재생", for: .normal)
    }
    func preparePlayer(){   //재생할 파일의 url과 볼륨등을 설정할 수 있음
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        
        do{audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)}
        catch{
            print("prepare playing failed")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        audioPlayer.volume = 1.0
    }
    
    
    func startRecording() {
        ViewController.shared.result = formatter.string(from: date) + ".wav"
        print(ViewController.shared.result)
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("중단", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        audioRecorder.stop()
        audioRecorder = nil
        print(audioFilename)
        
        if success {
            recordButton.setTitle("녹음", for: .normal)
        } else {
            recordButton.setTitle("녹음", for: .normal)
            // recording failed :(
        }
    }
    func recordTapped() {
        if audioRecorder == nil {
            date = Date()
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadRecordingUI() {
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    @IBAction func ser(_ sender:UIButton){
        if ViewController.shared.result != ""{
            serButton.setTitle("...", for: .normal)
            self.fft_result()
        }
    }
    func fft_result() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        let file = try! AVAudioFile(forReading: audioFilename)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        //let asset = AVURLAsset(url: audioFilename, options: nil)
        //let audioDuration = asset.duration
        let WAV_SAMPLIEING_RATE = 16000
        let WAV_INPUT_SEC = 5    //Int(CMTimeGetSeconds(audioDuration))
        
        let win_size = Int(0.025 * Float(WAV_SAMPLIEING_RATE))
        let half_win = Int(win_size/2)
        var y : [[Float]] = [[]]
        var centroid : Int = 0
        var pt = centroid+half_win
        let data_len = WAV_SAMPLIEING_RATE * WAV_INPUT_SEC
        // lancé l'audio dans le core AVaudioFile
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
        try! file.read(into:buf) // You probably want better error handling
        var floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        // print(floatArray) Amplitude 값들
        
        if(floatArray.count<data_len){
            while (floatArray.count < data_len){
                floatArray.append(0)
            }
        }
        print(floatArray)
        let nUniquePts = 257
        var p : [Float] = []
        while (centroid < data_len){

            let s1 = Array(floatArray[pt-half_win..<pt+half_win])
            p = performFFT(s1)
            p = Array(p[0..<nUniquePts])
            //y.append(p)
            pt = pt + 160
            centroid = pt + half_win
        }
        //print(y)
        guard let mlMultiArray = try? MLMultiArray(shape:[40,12], dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for (index, element) in p.enumerated() {
            mlMultiArray[index] = NSNumber(floatLiteral: Double(element))
        }
        let output = try? model.prediction(wav: mlMultiArray,lstm_1_h_in: mlMultiArray,lstm_1_c_in : mlMultiArray)
        print(output)
        
        
        
        
        
        // (서버연동) get the date time String from the date object
        /*var audioFilename = getDocumentsDirectory().appendingPathComponent(ViewController.shared.result)
        Alamofire.request("http://163.239.169.54:5005/uploads").responseString { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            if ((response.response!.statusCode) >= 200 && (response.response!.statusCode) < 300){
                print("Success")
            }
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(audioFilename, withName: "file")
        },
            to: "http://163.239.169.54:5005/uploads",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //print(response["Result"])
                        //print(response.result)
                        let data = response.result.value
                        let jsondata = data as! NSDictionary
                        //print(jsondata)
                        //self.resultLabel.text = "(\(jsondata["classification"] as! Int))\(self.answer[jsondata["classification"] as! Int])"
                        // print(resultLabel.text)
                        //print(jsondata["classification"]!)
                        print(jsondata["classification"] as! Int)
                        ViewController.shared.r = jsondata["classification"] as! Int
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let serViewController = storyBoard.instantiateViewController(withIdentifier: "serViewController") as! SerViewController
                        self.present(serViewController, animated: true, completion: nil)
                        /* [Happy , Sad, Angry, Frustrated, Excited, Neutral] */
                        
                        //self.resultLabel.text = "(\(jsondata["classification"] as! Int))\(self.answer[jsondata["classification"] as! Int])"
                        
                        
                        //UIView.transition(with: self.back, duration: 5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.image = UIImage(named: "l\(jsondata["classification"] as! Int)")}, completion: nil)
                        
                        //let newViewController = SerViewController()
                       // self.navigationController?.pushViewController(newViewController, animated: true)
                        //self.back.image = nil
                        /*UIView.transition(with: self.back, duration: 3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {self.back.backgroundColor = self.UIColorFromHex(rgbValue: UInt32(self.corlor_set[jsondata["classification"] as! Int]))})
                         */
                        //self.back.image=UIImage(named: "\(jsondata["classification"] as! Int)")
                        
                        //self.prob = jsondata["prob"] as! [Double]
                        //debugPrint(self.prob)
                        /*
                         self.setChart(dataPoints: self.category, values: self.prob)
                         
                         self.barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 3.0)
                         */
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )*/
        
        
        
        
        serButton.setTitle("감정 인식", for: .normal)
    }
    /*public func fft(input: [Float]) -> [Float] {
        var real = [Float](input)
        var imaginary = [Float](repeating: 0.0, count: input.count)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
        
        let length = vDSP_Length(floor(log2(Float(input.count))))
        //let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetup(length, 0)
        vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](repeating: 0.0, count: input.count)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: input.count)
        vDSP_vsmul(sqrt(x: magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
        
        vDSP_destroy_fftsetup(weights)
        
        return normalizedMagnitudes
    }
    public func sqrt(x: [Float]) -> [Float] {
        // convert swift array to C vector
        let temp = UnsafeMutablePointer<Float>.allocate(capacity: x.count)
        for i in 0..<x.count  {
            temp[i] = x[i];
        }
        let count = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        count[0] = Int32(x.count)
        vvsqrtf(temp, temp, count)
        // convert C vector to swift array
        var results = [Float](repeating: 0.0, count: x.count)
        for i in 0..<x.count {
            results[i] = temp[i];
        }
        // Free memory
        count.deallocate(capacity: 1)
        temp.deallocate(capacity: x.count)
        return results
    }*/
    func performFFT(_ input: [Float]) -> [Float] {
        
        var real = [Float](input)
        var imag = [Float](repeating: 0.0, count: input.count)
        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)
        
        let length = vDSP_Length(floor(log2(Float(input.count))))
        let radix = FFTRadix(kFFTRadix2)
        let weights = vDSP_create_fftsetup(length, radix)
        vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
        
        
        var magnitudes = [Float](repeating: 0.0, count: input.count)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: input.count)
        
        vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))
        
        vDSP_destroy_fftsetup(weights)
        return normalizedMagnitudes
    }
    public func sqrt(_ x: [Float]) -> [Float] {
        var results = [Float](repeating: 0.0, count: x.count)
        vvsqrtf(&results, x, [Int32(x.count)])
        return results
    }
    
}


