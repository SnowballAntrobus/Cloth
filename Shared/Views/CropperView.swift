//
//  CropperView.swift
//  Cloth
//
//  Created by Dante Gil-Marin on 3/25/21.
//

import SwiftUI

struct CropperView: View {
    @State var imageSize: CGSize = .zero
    
    @Binding var image: UIImage?
    @State var points: [CGPoint] = []
    @State var pointsResized: [CGPoint] = []
    
    @State var croppedImage: UIImage?
    @State var croppedImageData: Data?
    
    @Binding var clothItems: [ClothItem]
    @State private var newclothItemData = ClothItem.Datas()
    @State var activeSheet = false
    var body: some View {
            if (croppedImage != nil){
                VStack {
                    Image(uiImage: croppedImage ?? UIImage(systemName: "circle")!)
                        .resizable()
                        .scaledToFit()
                    Button(action: {croppedImage = nil; points = []; pointsResized = []}, label: {
                        Text("Reset")
                    }).padding()
                    Button(action: {croppedImageData = croppedImage!.pngData()!; newclothItemData.image = croppedImageData; activeSheet = true}, label: {
                        Text("Go")
                    }).padding()
                    .sheet(isPresented: $activeSheet) {
                        NavigationView {
                            ClothItemEditView(clothItemData: $newclothItemData)
                                .navigationBarItems(leading: Button("Dismiss") { activeSheet = false}, trailing: Button("Add") { let newclothItem = ClothItem(type: newclothItemData.type.id, color: newclothItemData.color, brand: newclothItemData.brand, price: newclothItemData.price, image: croppedImage); clothItems.append(newclothItem); activeSheet = false})
                            }
                    }

                }
            } else {
                VStack{
                    Image(uiImage: image ?? UIImage(systemName: "circle")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(rectReader())
                        .gesture(DragGesture().onChanged( { value in self.addNewPoint(value)}))
                        .overlay(DrawShape(points: points)
                            .stroke(lineWidth: 5)
                            .foregroundColor(.green))
                    Button(action: {cropImage()}, label: { Text("Crop") }).padding()
                    Button(action: {points = []; pointsResized = []}, label: { Text("Reset") }).padding()
                }
            }
    }
    
    private func rectReader() -> some View {
        return GeometryReader { (geometry) -> AnyView in
            let imageSize = geometry.size
            DispatchQueue.main.async {
                self.imageSize = imageSize
                self.imageSize.height = image!.size.height / imageSize.height
                self.imageSize.width = image!.size.width / imageSize.width
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
    }

    private func addNewPoint(_ value: DragGesture.Value) {
        var x: CGFloat = value.location.x
        var y: CGFloat = value.location.y
        
        x = x * imageSize.width
        y = y * imageSize.height
        
        pointsResized.append(CGPoint(x: x, y: y))
        points.append(value.location)
    }
    
    private func cropImage() {
        croppedImage = ZImageCropper.cropImage(ofImageView: UIImageView(image: image), withinPoints: pointsResized)
    }
}

struct CropperView_Previews: PreviewProvider {
    static var previews: some View {
        CropperView(image: .constant(UIImage(named: "pants")), clothItems: .constant(ClothItem.data))
    }
}

struct DrawShape: Shape {

    var points: [CGPoint]

    // drawing is happening here
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let firstPoint = points.first else { return path }

        path.move(to: firstPoint)
        for pointIndex in 1..<points.count {
            path.addLine(to: points[pointIndex])

        }
        return path
    }
}
