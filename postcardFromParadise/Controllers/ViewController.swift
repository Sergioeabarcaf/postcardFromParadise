//
//  ViewController.swift
//  postcardFromParadise
//
//  Created by Sergio Abarca Flores on 25-07-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate {

    @IBOutlet weak var postcardImageView: UIImageView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var colors = [UIColor]()
    var image : UIImage?
    var topText = "Bienvenido a iOS 11"
    var bottomText = "El mejor curso lanzado a la fecha."
    var topFontName = "Avenir Next"
    var bottomFontName = "Avenir Next"
    var topFontColor = UIColor.white
    var bottomFontColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colors += [.black, .gray, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .magenta]
        
        for hue in 0...9 {
            for sat in 1...10{
                let color = UIColor(hue: CGFloat(hue)/10, saturation: CGFloat(sat)/10, brightness: 1, alpha: 1)
                self.colors.append(color)
            }
        }
        
        self.renderPostcard()
        self.colorCollectionView.dragDelegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        let color = self.colors[indexPath.row]
        cell.backgroundColor = color
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //MARK: Collection View Drag Delegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let color = self.colors[indexPath.row]
        let itemProvider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: itemProvider)
        return [item]
    }
    
    //MARK: Funciones propias
    
    func renderPostcard(){
        //Definir zona de trabajo (3000x2400)
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        // crear dos rectangulos para los textos
        let topRect = CGRect(x: 300, y: 200, width: 2400, height: 800)
        let bottomRect = CGRect.init(x: 300, y: 1800, width: 2400, height: 400)
        // a partir de los nombres de fuentes, crear dos objetos fuentes con Aveir Next por defecto
        let topFont = UIFont(name: self.topFontName, size: 250) ?? UIFont.systemFont(ofSize: 240)
        let bottomFont = UIFont(name: self.bottomFontName, size: 150) ?? UIFont.systemFont(ofSize: 120)
        
        //NSMutableParagraphStylepara centrar texto en rectangulos
        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        //Definir color y fuentes de la etiqueta
        let topAttributes : [NSAttributedStringKey : Any] = [.foregroundColor : self.topFontColor, .font : topFont, .paragraphStyle : centered]
        let bottomAttributes : [NSAttributedStringKey : Any] = [.foregroundColor : self.bottomFontColor, .font : bottomFont, .paragraphStyle : centered]
        
        //Iniciar renderizacion de imagen
        let renderer = UIGraphicsImageRenderer(size: drawRect.size)
        self.postcardImageView.image = renderer.image(actions: { (context) in
            //Renderizar la zona con fondo gris
            UIColor.gray.set()
            context.fill(drawRect)
            //Pintar imagen del usuario, solo si hay
            self.image?.draw(at: CGPoint(x: 0, y: 0))
            //Cargar los atributos en los rectangulos correspondientes
            self.topText.draw(in: topRect, withAttributes: topAttributes)
            self.bottomText.draw(in: bottomRect, withAttributes: bottomAttributes)
        })
    }
}

