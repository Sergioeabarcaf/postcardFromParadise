//
//  ViewController.swift
//  postcardFromParadise
//
//  Created by Sergio Abarca Flores on 25-07-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    

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
        
        self.colorCollectionView.dragDelegate = self
        self.postcardImageView.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: self)
        self.postcardImageView.addInteraction(dropInteraction)
        let dragInteraction  = UIDragInteraction(delegate: self)
        self.postcardImageView.addInteraction(dragInteraction)
        
        self.renderPostcard()
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
    
    //MARK: Drop Interaction Delegate
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    //funcion que se ejecuta cuando ha sido soltado el objeto
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // obtener posicion donde se ha soltado el objeto
        let dropLocation = session.location(in: self.postcardImageView)
        //identificar si el objeto soltado es un string (fuentes)
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]){
            //cargar objeto soltado
            session.loadObjects(ofClass: NSString.self, completion: {items in
                //si se puede el primer item se puede almacenar de tipo string
                guard let font = items.first as? String else {return}
                
                 //identificar si el objeto fue soltado en la mitad superior o inferior de la pantalla
                if dropLocation.y < self.postcardImageView.bounds.midY{
                    self.topFontName = font
                }
                else{
                    self.bottomFontName = font
                }
                //Renderizar los cambios realizado
                self.renderPostcard()
            })
            
        //identificar si el objeto soltado es una imagen
        }else if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]){
            session.loadObjects(ofClass: UIImage.self) { (items) in
                guard let imagen = items.first as? UIImage else {return}
                
                self.image = imagen
                
                self.renderPostcard()
                
            }
            
        //identificar si el objeto soltado no es ninguno de los anteriores, por lo que es un color
        }else{
            //cargar objeto en la session de manera asincronica
            session.loadObjects(ofClass: UIColor.self, completion: {items in
                //si el primer objeto del arreglo es de tipo UIColor, almacenarlo, sino, salir
                guard let color = items.first as? UIColor else {return}
                
                //identificar si el objeto fue soltado en la mitad superior o inferior de la pantalla
                if dropLocation.y < self.postcardImageView.bounds.midY{
                    self.topFontColor = color
                }
                else{
                    self.bottomFontColor = color
                }
                //Renderizar los cambios realizado
                self.renderPostcard()
            })
        }
    }
    
    //MARK: Drag Interaction Delegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let imagen = self.postcardImageView.image else { return [] }
        let provider = NSItemProvider(object: imagen)
        let item = UIDragItem(itemProvider: provider)
        
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
    
    //MARK: Gesture Recognizer
    
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        //Encontrar la localizacion del tap y decidir si tiene que cambiar el texto de arriba o abajo
        let changeTop = (sender.location(in: self.postcardImageView).y < self.postcardImageView.bounds.midY) ? true : false

        let alert = UIAlertController(title: "Camabiar texto", message: "Ingrese el nuevo texto", preferredStyle: .alert)
        alert.addTextField {textField in
            textField.placeholder = "¿Que quieres colocar aca?"
            if changeTop{
                textField.text = self.topText
            }
            else{
                textField.text = self.bottomText
            }
        }
        
        let changeAction = UIAlertAction(title: "Cambiar texto", style: .default) { action in
            guard let newText = alert.textFields?[0].text else {return}
            if changeTop{
                self.topText = newText
            }
            else{
                self.bottomText = newText
            }
            
            self.renderPostcard()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

