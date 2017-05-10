//
//  FeedViewController.swift
//  Marslink
//
//  Created by apple on 17/4/26.
//  Copyright © 2017年 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit

class FeedViewController: UIViewController {

    lazy var adapter:IGListAdapter={
        return IGListAdapter(updater:IGListAdapterUpdater(),viewController:self,workingRangeSize:0)
    }()
    
    let loader = JournalEntryLoader()
    let pathfinder = Pathfinder()
    let wxScanner = WxScanner()
    
    let collectionView:IGListCollectionView={
        let view = IGListCollectionView(frame:CGRect.zero,collectionViewLayout:UICollectionViewFlowLayout())
        view.backgroundColor=UIColor.black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loader.loadLatest()
        view.addSubview(collectionView)
        
        adapter.collectionView = collectionView
        adapter.dataSource=self
        
        pathfinder.delegate=self
        pathfinder.connect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame=view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension FeedViewController:IGListAdapterDataSource{
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        
        var items:[IGListDiffable] = [wxScanner.currentWeather]
        items+=loader.entries as [IGListDiffable]
        items+=pathfinder.messages as [IGListDiffable]
        return items.sorted(by: { (left: Any, right: Any) ->Bool in
            if let left = left as? DateSortable,let right = right as? DateSortable{
                return left.date > right.date
            }
            return false
        })
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if object is Message{
            return MessageSectionController()
        }else if object is Weather{
            return WeatherSectionController()
        }else{
            return JournalSectionController()
        }
    }

    func emptyView(for listAdapter: IGListAdapter)->UIView?{
        return nil
    }
}

extension FeedViewController: PathfinderDelegate{
    func pathfinderDidUpdateMessages(pathfinder: Pathfinder) {
        adapter.performUpdates(animated: true, completion: nil)
    }
}
