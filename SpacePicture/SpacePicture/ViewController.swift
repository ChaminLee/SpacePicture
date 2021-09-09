//
//  ViewController.swift
//  URLSession_Practice
//
//  Created by 이차민 on 2021/09/08.
//

import UIKit

class ViewController: UIViewController {
    
    // API 사용하기 위한 객체
    var apiHandler : APIHandler = APIHandler()

    // 데이터 모델 객체
    var spaceData: SpaceData? {
        didSet {
            print("data fetch completed")
        }
    }
    
    // 이미지 캐싱
    private let imageCache = NSCache<NSString, UIImage>()
    
    // 비동기 - 시간초 세줄 변수
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        
        // 시간초 증가
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {_ in
            self.counter += 1
            self.timeLabel.text = "\(self.counter)"
        }
    }

    // 불러오기 버튼
    let loadButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("사진 불러오기", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        bt.titleLabel?.textAlignment = .center
        
        let size: CGFloat = 5
        bt.titleEdgeInsets = UIEdgeInsets(top: size, left: size, bottom: size, right: size)
        bt.layer.masksToBounds = false
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .black
        bt.addTarget(self, action: #selector(loadSpaceData), for: .touchUpInside)
        return bt
    }()
    
    // 클리어
    let clearButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("클리어", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        bt.titleLabel?.textAlignment = .center
        
        let size: CGFloat = 5
        bt.titleEdgeInsets = UIEdgeInsets(top: size, left: size, bottom: size, right: size)
        bt.layer.masksToBounds = false
        bt.layer.cornerRadius = 5
        bt.backgroundColor = .systemIndigo
        bt.addTarget(self, action: #selector(clear), for: .touchUpInside)
        return bt
    }()
    
    // 클리어 액션
    @objc func clear() {
        self.counter = 0
        self.spaceImage.image = nil
        self.explanationLabel.text = nil
        self.titleLabel.text = nil
        self.dateLabel.text = nil
    }
    
    // 시간초
    let timeLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.font = UIFont(name: "Helvetica", size: 15)
        return lb
    }()
    
    // 메인 이미지
    let spaceImage: UIImageView = {
        let img = UIImageView()
        img.layer.masksToBounds = false
        img.layer.cornerRadius = img.frame.width / 2
        return img
    }()
    
    // 제목
    let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.font = UIFont(name: "Helvetica-Bold", size: 24)
        return lb
    }()
    
    // 날짜
    let dateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.font = UIFont(name: "Helvetica", size: 14)
        return lb
    }()
    
    // 설명
    let explanationLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.numberOfLines = 0
        lb.font = UIFont(name: "Helvetica", size: 15)
        return lb
    }()
    
    // 로딩 중 표시
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .black
        return indicator
    }()
    
    // 불러오기 버튼 액션
    @objc func loadSpaceData() {
        // 불러옴과 동시에 인디케이터 시작
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInteractive).async {
            // API 통해 데이터 불러오기
            self.apiHandler.getNASAData { data in
                // 정의해둔 모델 객체에 할당
                self.spaceData = data
                
                // 데이터를 제대로 잘 받아왔다면
                guard let data = self.spaceData else {
                    return
                }
                
                // 이미지 로드
                ImageLoader.loadImage(url: data.url) { [weak self] image in
                    // 메인 쓰레드임
                    self?.spaceImage.image = image
                    self?.activityIndicator.stopAnimating()
                    self?.titleLabel.text = data.title
                    self?.explanationLabel.text = data.explanation
                    self?.dateLabel.text = data.date
                }
            }
        }
    }
    
    // 구성 요소들 AutoLayout 처리
    func config() {
        view.backgroundColor = .white
        
        [clearButton, loadButton, spaceImage, titleLabel, explanationLabel, dateLabel, activityIndicator, timeLabel].forEach { item in
            self.view.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            spaceImage.topAnchor.constraint(equalTo: self.view.topAnchor),
            spaceImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            spaceImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            spaceImage.heightAnchor.constraint(equalToConstant: 400.0),
            
            titleLabel.topAnchor.constraint(equalTo: spaceImage.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: spaceImage.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: spaceImage.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            explanationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            explanationLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            explanationLabel.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            explanationLabel.heightAnchor.constraint(equalToConstant: 200.0),
            
            loadButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            loadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadButton.widthAnchor.constraint(equalToConstant: 110),
            
            clearButton.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor, constant: -10),
            clearButton.centerYAnchor.constraint(equalTo: loadButton.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 60),
            
            timeLabel.leadingAnchor.constraint(equalTo: loadButton.trailingAnchor, constant: 20),
            timeLabel.centerYAnchor.constraint(equalTo: loadButton.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            
        ])
    }

}

