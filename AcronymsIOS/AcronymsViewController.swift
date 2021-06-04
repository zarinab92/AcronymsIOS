//
//  ViewController.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/23/21.
//

import UIKit

class AcronymsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: AcronymViewModel!
    var refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AcronymViewModel()
        viewModel.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
   @objc func refresh() {
    viewModel.getAllAcronyms()
   }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createAcronym" {
            let destionation = segue.destination as! CreateAcronymTVC
            destionation.delegate = self
        } else if segue.identifier == "updateAcronym" {
            let destionation = segue.destination as! CreateAcronymTVC
            destionation.delegate = self
            
            if let index = tableView.indexPath(for: (sender as! UITableViewCell)){
                destionation.acronym = viewModel.getAcronym(for: index)
                 
            }
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        Auth.shared.logOut()
    }
}

extension AcronymsViewController: CreateAcronymTVCDelegate {
    func acronymsDidUpdated(vc: CreateAcronymTVC, acronym: Acronym) {
        navigationController?.popViewController(animated: true)
        refresh()
    }
    
}

extension AcronymsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        viewModel.getAllAcronyms(with: text)
    }
    
}

extension AcronymsViewController: AcronymsViewModelDelegate {
    
    func didDeleteAcronym(error: Error?, indexPath: IndexPath) {
        if let error = error {
            ErrorPresenter.showError(message: error.localizedDescription, on: self)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func stateDidChange(to state: AcronymsVCState) {
        switch state {
        case .errorOccured(error: let error):
            ErrorPresenter.showError(message: error.localizedDescription, on: self)
            tableView.reloadData()
        case .loaded, .noContent:
            tableView.reloadData()
            refreshControl.endRefreshing()
        case .loading:
            tableView.reloadData()
        }
    }
}

extension AcronymsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        viewModel .deleteAcronym(at: indexPath)
    }
}

extension AcronymsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        switch viewModel.state {
        case .loaded:
            cell = tableView.dequeueReusableCell(withIdentifier: "acronymCell", for: indexPath)
            
            cell.textLabel?.text = viewModel.getAcronym(for: indexPath).short
            cell.detailTextLabel?.text = viewModel.getAcronym(for: indexPath).long
        case .loading:
            cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
        case .noContent:
            cell = tableView.dequeueReusableCell(withIdentifier: "noContentCell", for: indexPath)
        case .errorOccured:
            cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
        }
         
        return cell
    }
}

