//
//  ListDetailHeaderView.swift
//  Todoosha
//
//  Created by Artem Kvashnin on 20.05.2022.
//

import UIKit




protocol ListDetailHeaderViewDelegate: AnyObject {
    
    func headerTapped(sender: UITableViewHeaderFooterView)
    
}

class ListDetailHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "ListDetailHeaderView"
    
    var isCollapsed: Bool = false
    var sectionNumber: Int!
    
    weak var delegate: ListDetailHeaderViewDelegate?

    var label: UILabel = {
        var label = UILabel()
        label.numberOfLines = 1
        label.contentMode = .left
        return label
    }()
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "chevron.down")
        return imageView
    }()
    
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    func rotateChevron() {
        isCollapsed.toggle()
        UIView.setAnimationsEnabled(true)
        UIView.animate(withDuration: 0.2) {
            let rotationTransform = CGAffineTransform(rotationAngle: self.isCollapsed ? -(.pi / 2) : 0)
            self.imageView.transform = rotationTransform
        }
    }
    
    
    func update(with section: ListDetailViewController.Section) {
        
        label.text = section.name
        //isCollapsed = section.isCollapsed
        
        
         
    }
    
    @objc func viewTapped() {

        delegate?.headerTapped(sender: self)
        rotateChevron()
    }
}
