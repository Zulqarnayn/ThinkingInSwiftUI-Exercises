//
//  ContentView.swift
//  Exercise.1
//
//  Created by Asif Mujtaba on 11/9/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var item = Remote(url: URL(string: "https://picsum.photos/v2/list")!, transform: { try? JSONDecoder().decode([Photo].self, from: $0) })
    
    var body: some View {
        VStack {
            if let photos = item.value {
                NavigationStack {
                    List(photos) { photo in
                        NavigationLink{
                            PhotoView(url: photo.download_url, aspectRatio: photo.width / photo.height)
                        } label: {
                            Text(photo.author)
                        }
                        
                    }
                }
            } else {
                ProgressView {
                    Text("Loading photos")
                }
                .onAppear {
                    item.load()
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PhotoView: View {
    @ObservedObject var image: Remote<UIImage>
    var aspectRatio: CGFloat
    
    var placeholderImage: Image {
        image.value.map(Image.init) ?? Image(systemName: "photo")
    }
    
    init(url: URL, aspectRatio: CGFloat) {
        image = Remote(url: url,transform: { data in
            UIImage(data: data)
        })
        self.aspectRatio = aspectRatio
    }
    
    var body: some View {
        placeholderImage
            .resizable()
            .foregroundColor(.secondary)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .padding()
            .onAppear { image.load() }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(url: URL(string: "https://picsum.photos/id/0/5000/3333")!, aspectRatio: 0.5)
    }
}
