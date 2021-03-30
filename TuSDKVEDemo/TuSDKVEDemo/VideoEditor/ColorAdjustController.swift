//
//  ColorAdjustController.swift
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/3/18.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

import UIKit

class ColorAdjustController: EditorBaseController {
    class ColorAdjustItem {
        var effect: TUPVEditorEffect
        var builder = TUPVEColorAdjustEffect_PropertyBuilder()
        var items:[ColorAdjustSourceItem] = ColorAdjustSourceItem.all()
        private let index = 3000
        init(viewModel: EditorViewModel) {
            if viewModel.state == .resource {
                effect = TUPVEditorEffect(viewModel.ctx, withType: TUPVEColorAdjustEffect_TYPE_NAME)
                viewModel.clipItems[0].videoClip.effects().add(effect, at: index)
                viewModel.build()
                builder = TUPVEColorAdjustEffect_PropertyBuilder()
                for item in items {
                    let value = TUPVEColorAdjustEffect_PropertyItem(item.code, with: item.valueFormat())
                    builder.holder.items.add(value)
                }
            } else {
                effect = viewModel.clipItems[0].videoClip.effects().getEffect(index)!
                if let prop = effect.getProperty(TUPVEColorAdjustEffect_PROP_PARAM) {
                    let holder = TUPVEColorAdjustEffect_PropertyHolder(property: prop)
                    builder = TUPVEColorAdjustEffect_PropertyBuilder(holder: holder)
                    if let values = holder.items as? [TUPVEColorAdjustEffect_PropertyItem] {
                        items = []
                        for value in values {
                            items.append(ColorAdjustSourceItem(code: value.name, values: value.values))
                        }
                    }
                }
            }
        }
        func change(index: Int, item: ColorAdjustSourceItem) {
            let value = TUPVEColorAdjustEffect_PropertyItem(item.code, with: item.valueFormat())
            builder.holder.items[index] = value
        }
    }
    override init(viewModel: EditorViewModel) {
        super.init(viewModel: viewModel)
        videoItem = ColorAdjustItem(viewModel: viewModel)
    }
    var videoItem: ColorAdjustItem!
    private let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    func editor() {
        videoItem.effect.setProperty(videoItem.builder.makeProperty(), forKey: TUPVEColorAdjustEffect_PROP_PARAM)
        if !self.isPlaying {
            self.player.previewFrame(self.currentTs)
        }
    }
    func swap(at i: Int, to j: Int) {
        let temp = videoItem.builder.holder.items[i]
        videoItem.builder.holder.items[i] = videoItem.builder.holder.items[j]
        videoItem.builder.holder.items[j] = temp
        self.editor()
        (self.videoItem.items[j], self.videoItem.items[i]) = (self.videoItem.items[i], self.videoItem.items[j])
        tableView.reloadData()
    }
}

extension ColorAdjustController: UITableViewDelegate, UITableViewDataSource {
    func setupView() {
        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 100
        tableView.register(ColorAdjustCell.self, forCellReuseIdentifier: "ColorAdjustCell")
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoItem.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorAdjustCell") as! ColorAdjustCell
        cell.item = videoItem.items[indexPath.row]
        cell.upButton.isHidden = false
        cell.downButton.isHidden = false
        if indexPath.row == 0 {
            cell.upButton.isHidden = true
        } else if indexPath.row == videoItem.items.count - 1 {
            cell.downButton.isHidden = true
        }
        cell.changeCompletion = {[weak self] item in
            guard let `self` = self else { return }
            self.videoItem.change(index: indexPath.row, item: item)
            self.editor()
        }
        cell.upCompletion = {[weak self] in
            guard let `self` = self else { return }
            self.swap(at: indexPath.row, to: indexPath.row - 1)
        }
        cell.downCompletion = {[weak self] in
            guard let `self` = self else { return }
            self.swap(at: indexPath.row, to: indexPath.row + 1)
        }
        return cell
    }
}

class ColorAdjustCell: UITableViewCell {
    var item: ColorAdjustSourceItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title
            if item.properties.count == 1 {
                centerSliderView.isHidden = false
                topSliderView.isHidden = true
                bottomSliderView.isHidden = true
                centerSliderView.item = item.properties[0]
            } else {
                topSliderView.isHidden = false
                bottomSliderView.isHidden = false
                centerSliderView.isHidden = true
                topSliderView.item = item.properties.first
                bottomSliderView.item = item.properties.last
            }
        }
    }
    var changeCompletion:((ColorAdjustSourceItem)->Void)?
    var upCompletion:(()->Void)?
    var downCompletion:(()->Void)?

    let titleLabel = UILabel()
    let topSliderView = ColorAdjustSliderView(frame: .zero)
    let centerSliderView = ColorAdjustSliderView(frame: .zero)
    let bottomSliderView = ColorAdjustSliderView(frame: .zero)
    let upButton = UIButton()
    let downButton = UIButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .black
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.width.equalTo(50)
        }
        let lineView = UIView()
        lineView.backgroundColor = .init(white: 1, alpha: 0.8)
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        upButton.setTitle("上移", for: .normal)
        upButton.setTitleColor(.black, for: .normal)
        upButton.backgroundColor = .white
        upButton.layer.cornerRadius = 3
        upButton.titleLabel?.font = .systemFont(ofSize: 12)
        upButton.addTarget(self, action: #selector(upAction), for: .touchUpInside)

        contentView.addSubview(upButton)
        upButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(15)
            make.height.equalTo(25)
            make.width.equalTo(50)
        }
        
        downButton.setTitle("下移", for: .normal)
        downButton.setTitleColor(.black, for: .normal)
        downButton.backgroundColor = .white
        downButton.layer.cornerRadius = 3
        downButton.titleLabel?.font = .systemFont(ofSize: 12)
        downButton.addTarget(self, action: #selector(downAction), for: .touchUpInside)
        contentView.addSubview(downButton)
        downButton.snp.makeConstraints { (make) in
            make.right.width.height.equalTo(upButton)
            make.bottom.equalTo(-15)
        }
        contentView.addSubview(topSliderView)
        contentView.addSubview(bottomSliderView)
        contentView.addSubview(centerSliderView)
        centerSliderView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp_right)
            make.right.equalTo(-60)
            make.height.equalTo(50)
        }
        topSliderView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp_right)
            make.right.equalTo(-60)
            make.top.equalTo(0)
            make.height.equalTo(50)
        }
        bottomSliderView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp_right)
            make.right.equalTo(-60)
            make.height.equalTo(50)
            make.bottom.equalTo(0)
        }
        centerSliderView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.item else { return }
            item.properties[0].value = value
            self.changeCompletion?(item)
        }
        topSliderView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.item else { return }
            item.properties[0].value = value
            self.changeCompletion?(item)
        }
        bottomSliderView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self, let item = self.item, item.properties.count > 1 else { return }
            item.properties[1].value = value
            self.changeCompletion?(item)
        }
    }
    @objc func upAction() {
        self.upCompletion?()
    }
    @objc func downAction() {
        self.downCompletion?()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class ColorAdjustSliderView: UIView {
    var item: ColorAdjustSourceItem.PropertyItem? {
        didSet {
            guard let item = item else { return }
            sliderView.slider.minimumValue = item.min
            sliderView.slider.maximumValue = item.max
            sliderView.slider.value = item.value
            sliderView.text = item.title
            valueLabel.text = item.value.titleFormat()
        }
    }
    let sliderView = SliderBarView(title: "", state: .native)
    let valueLabel = UILabel()
    var sliderValueChangedCompleted: ((Float) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        valueLabel.text = "0.00"
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 12)
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(35)
        }
        sliderView.sliderValueChangedCompleted = {[weak self] value in
            guard let `self` = self else { return }
            self.valueLabel.text = value.titleFormat()
            self.sliderValueChangedCompleted?(value)
        }
        addSubview(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(valueLabel.snp.left)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
