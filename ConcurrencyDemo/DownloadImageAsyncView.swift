//
//  ContentView.swift
//  ConcurrencyDemo
//
//  Created by ahmed hussien on 13/05/2024.
//

import SwiftUI
import Combine

struct DownloadImageAsyncView: View {
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View{
        ZStack{
            Color.black.ignoresSafeArea()
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250,height: 250)
                    .cornerRadius(20)
                //                        .onTapGesture {
                //                            viewModel.fetImagesWithTask()
                //                        }
            }
        }
        .onAppear{
            
//            Task{
//               await viewModel.fetchImagesWithAsync()
//               print("finished 1122")
//            }
           // print("finished")
            
            //usingAsync1()
            //usingAsync2()
            //usingSync2()
            // usingSync1()
            
            // 1
            viewModel.fetchImagesWithEscaping()
            print("finished")
            
            // 2
            //viewModel.fetImagesWithCombine()
            
            // 3
            //viewModel.fetImagesWithCombine2()
            
            // 4
            //viewModel.fetImagesWithTask()
            
            //5
            //                Task {
            //
            //                   await viewModel.fetImageWithContinuation()
            //                }
            
        }
    }
    
    
    func usingAsync1(){
        DispatchQueue.global().async {
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 2)
                
                let res = repeatElement("***", count: i)
                
                print(res.joined())
                
            }
        }
        
        print("Finished")
        
        DispatchQueue.global().async {
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 1)
                
                let res = repeatElement("###", count: i)
                
                print(res.joined())
                
            }
        }
        
        
    }
    func usingAsync2(){
        
        DispatchQueue.global().async {
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 2)
                
                let res = repeatElement("***", count: i)
                
                print(res.joined())
                
            }
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 1)
                
                let res = repeatElement("###", count: i)
                
                print(res.joined())
                
            }
        }
        
        print("Finished")
    }
    func usingSync1(){
        DispatchQueue.global().sync {
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 1)
                
                let res = repeatElement("***", count: i)
                
                print(res.joined())
                
            }
        }
        
        print("Finished")
        
        DispatchQueue.global().sync {
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 1)
                
                let res = repeatElement("###", count: i)
                
                print(res.joined())
                
            }
        }
        
        
    }
    func usingSync2(){
        DispatchQueue.global().sync {
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 2)
                
                let res = repeatElement("***", count: i)
                
                print(res.joined())
                
            }
            
            for i in 0...10 {
                
                Thread.sleep(forTimeInterval: 1)
                
                let res = repeatElement("###", count: i)
                
                print(res.joined())
                
            }
        }
        
        print("Finished")
    }
}

#Preview {
    DownloadImageAsyncView()
}

//MARK: - Services
class DownloadImageAsyncServices{
    
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func getUrl() -> URL?{
        guard let url = URL(string: url) else {return nil}
        return url
    }
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage?{
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage? ,_ error: Error?) -> Void){
        Thread.sleep(forTimeInterval: 10)
        guard let url = getUrl() else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let image = UIImage(data: data),
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else{
                completionHandler(nil,error)
                return
            }
            completionHandler(image,nil)
            print("pass 10 second")
        }
        .resume()
    }
    
    func downloadWithEscaping2(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void){
        guard let url = getUrl() else {return}
        URLSession.shared.dataTask(with: url) { data, response, error in
            let image = self.handleResponse(data: data, response: response as? HTTPURLResponse)
            completionHandler(image,nil)
        }
        .resume()
    }
    
    func downloadImageWithContinuation() async throws -> UIImage?{
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let url = getUrl() else {return}
            URLSession.shared.dataTask(with: url) { data, response, error in
                let image = self.handleResponse(data: data, response: response as? HTTPURLResponse)
                if let image = image {
                    continuation.resume(returning: image)
                }
                else if let error = error {
                    continuation.resume(throwing: error as! Never)
                }
                else{
                    continuation.resume(throwing: error as! Never)
                }
            }
            .resume()
        }
    }
    
    
    func downloadWithCombine() -> AnyPublisher<UIImage?,Error>{
        guard let url = self.getUrl() else {return Fail(error: URLError(.badURL)).eraseToAnyPublisher()}
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError{$0}
            .eraseToAnyPublisher()
    }
    
    func downloadImageWithAsync() async throws -> UIImage?{
        // 1. weak self -> no need
        // 2. safer code (completionHandler usage X)
        
        guard let url = self.getUrl() else {throw URLError(.badURL)}
        
        
        let (data,response) = try await URLSession.shared.data(from: url)
        return handleResponse(data: data, response: response)
        
    }
    
    //    func downloadImageWithDispatchQueue() -> AnyPublisher<UIImage?,Error>{
    //
    //        guard let url = self.getUrl() else {return Fail(error: URLError(.badURL)).eraseToAnyPublisher()}
    //
    //        DispatchQueue.global().sync {
    //            return URLSession.shared.dataTaskPublisher(for: url)
    //                .map(handleResponse)
    //                .mapError{$0}
    //                .eraseToAnyPublisher()
    //        }
    //    }
}

//MARK: - ViewModel
class DownloadImageAsyncViewModel: ObservableObject{
    
    @Published var image:UIImage? = nil
    let dataServices = DownloadImageAsyncServices(url: "https://picsum.photos/200")
    var cancellables = Set<AnyCancellable>()
    
    func fetchImagesWithEscaping(){
        dataServices.downloadWithEscaping { [weak self] image, error in
            if let error = error{
                print(error.localizedDescription)
            }else{
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.image = image
                }
            }
        }
    }
    
    func fetchImagesWithCombine(){
        dataServices.downloadWithCombine()
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] image in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.image = image
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchImagesWithCombine2(){
        dataServices.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            } receiveValue: { [weak self] image in
                guard let self = self else {return}
                self.image = image
            }
            .store(in: &cancellables)
    }
    
    func fetchImageWithContinuation() async{
        do {
            guard let image = try await dataServices.downloadImageWithContinuation() else {return}
            self.image = image
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func fetchImagesWithAsync() async{
        do{
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            guard let image = try await dataServices.downloadImageWithAsync() else {return}
            await MainActor.run{
                self.image = image
                print("finish fetch ")
            }
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func fetchImagesWithTask(){
        Task{
            await fetchImagesWithAsync()
            print("finish fetch ")
        }
    }
    
    func fetchImageWithDispatchQueue(){
        DispatchQueue.global().sync {
            Thread.sleep(forTimeInterval: 10)
            dataServices.downloadWithCombine()
                .sink { completion in
                    switch completion{
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] image in
                    guard let self = self else {return}
                    DispatchQueue.main.async {
                        self.image = image
                        print("pass 10 seconde")
                    }
                }
                .store(in: &cancellables)
        }
    }
    
}
