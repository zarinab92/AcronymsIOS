//
//  AcronymsViewModel.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/29/21.
//

import UIKit

enum AcronymsVCState {
    case loading
    case loaded
    case noContent
    case errorOccured(error: Error)
}

protocol AcronymsViewModelDelegate: AnyObject {
    func stateDidChange(to state: AcronymsVCState)
    func didDeleteAcronym(error: Error?, indexPath: IndexPath)
    
}

class AcronymViewModel {
    
    weak var delegate: AcronymsViewModelDelegate?
    private var acronymsData: [Acronym] = []
    var numberOfRows: Int {
        return acronymsData.isEmpty ? 1 : acronymsData.count
    }
    
    var state: AcronymsVCState = .loading {
        didSet { //наблюдатель
            DispatchQueue.main.async {
                self.delegate?.stateDidChange(to: self.state)
            }
        }
    }
    
    init() {
        getAllAcronyms()
    }
    
    func getAcronym(for indexPath: IndexPath) -> Acronym {
        return acronymsData[indexPath.row]
    }
    
    func getAllAcronyms(with term: String? = nil) { // получение всех акронимов или же поиск. searchFor и getAllacronyms  в одной фунции, т.к они похожи
        
        acronymsData.removeAll()
        state = .loading
         
        ServiceLayer.request(router: term == nil ? .getAllAcronyms : .searchFor(term: term!)) { [weak self] (result: Result<[Acronym], RequestError>) in // тернарный оператор( если term нету, то это получение всех акронимов, если term есть, то идет поиск
            switch result  {
            case .failure(let error):
                if let weakSelf = self {
                    weakSelf.state = .errorOccured(error: error)
                }
            case .success(let acronyms):
                if let weakSelf = self {
                    weakSelf.acronymsData = acronyms
                    weakSelf.state = acronyms.isEmpty ? .noContent : .loaded // Teрнарный оператор
                }
            }
        }
    }
    
    func deleteAcronym(at indexPath: IndexPath) {
        
        guard let id = acronymsData[indexPath.row].id else {
            return
        }
        ServiceLayer.requestToDelete(router: .deleteAcronym(id: id)) { [weak self] (error) in
            DispatchQueue.main.async {
                if let weakSelf = self {
                    if let error = error {
                        weakSelf.delegate?.didDeleteAcronym(error:  error, indexPath: indexPath)
                    } else {
                        weakSelf.acronymsData.remove(at: indexPath.row)
                        weakSelf.delegate?.didDeleteAcronym(error:  nil, indexPath: indexPath)
                    }
                }
            }
        }
    }
}

