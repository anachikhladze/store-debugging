//
//  ProductsListViewModel.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import Foundation

protocol ProductsListViewModelDelegate: AnyObject {
    func productsFetched(_ products: [ProductModel])
    func productsAmountChanged()
    func showError(_ error: Error)
}

final class ProductsListViewModel {
    
    weak var delegate: ProductsListViewModelDelegate?
    
    var products: [ProductModel]?
    var totalPrice: Double? { products?.reduce(0) { $0 + $1.price * Double(($1.selectedAmount ?? 0))} }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        NetworkManager.shared.fetchProducts { [weak self] response in
            switch response {
            case .success(let products):
                self?.products = products
                self?.delegate?.productsFetched(products)
            case .failure(let error):
                self?.delegate?.showError(error)
            }
        }
    }
    
    func addProduct(at index: Int) {
        // Handle if products are out of stock
        guard var product = products?[index] else { return }
        
        if product.stock <= 0 {
            print("Product is out of stock.")
        } else {
            product.selectedAmount = (products?[index].selectedAmount ?? 0) + 1
            products?[index].selectedAmount = product.selectedAmount
            delegate?.productsAmountChanged()
        }
    }
    
    func removeProduct(at index: Int) {
        guard var product = products?[index] else { return }
        
        // Handle if selected quantity of product is already 0
        if product.selectedAmount ?? 0 > 0 {
            product.selectedAmount = (products?[index].selectedAmount ?? 0) - 1
            products?[index].selectedAmount = product.selectedAmount
            delegate?.productsAmountChanged()
        } else {
            print("Selected quantity is 0.")
        }
    }
}
