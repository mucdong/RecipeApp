//
//  ListOfRecipeViewController.swift
//  RecipeApp
//
//  Created by Nguyen D on 3/7/20.
//  Copyright © 2020 Nguyen D. All rights reserved.
//

import UIKit

class ListOfRecipeViewController: UIViewController {
    @IBOutlet weak var tfRecipeType: UITextField!
    @IBOutlet weak var tblRecipe: UITableView!
    
    private var pvRecipeType : UIPickerView?
    
    private var elementName: String = String()
    private var typeId = String()
    private  var typeName = String()
    
    private var listOfRecipeTypes = [RecipeType]()
    private var listOfRecipe = [Recipe]()
    private var currentType: RecipeType?
    private var selectedRecipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblRecipe.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeCell")
        
        if let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        
        // UIPickerView
        self.pvRecipeType = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.pvRecipeType?.delegate = self
        self.pvRecipeType?.dataSource = self
        self.pvRecipeType?.backgroundColor = UIColor.white
        tfRecipeType.inputView = self.pvRecipeType

        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()

        // Adding Done Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ListOfRecipeViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        tfRecipeType.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadListOfRecipe()
    }
    

    @objc func doneClick() {
        tfRecipeType.resignFirstResponder()
    }
    
    func loadListOfRecipe() {
        if currentType == nil {
            return
        }
        
        listOfRecipe = DBUtils.shared.loadListRecipe(byType: currentType!.id)
        tblRecipe.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetail" {
            let vc = segue.destination as? RecipeDetailViewController
            vc?.recipe = selectedRecipe
        } else if segue.identifier == "showAdd" {
            let nav = segue.destination as? UINavigationController
            let vc = nav!.topViewController as? RecipeAddingViewController
            vc?.recipeType = currentType!.id
        }
    }

}

// MARK: - TableView DataSource & Delegate
extension ListOfRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
        let type = listOfRecipe[indexPath.row]
        cell.textLabel?.text = type.title
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecipe = listOfRecipe[indexPath.row]
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }
}

// MARK: - XML Parser
extension ListOfRecipeViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "type" {
            typeId = String()
            typeName = String()
        }
        self.elementName = elementName
        
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "type" {
            let type = RecipeType()
            type.id = Int(typeId) ?? 0
            type.name = typeName
            listOfRecipeTypes.append(type)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "id" {
                typeId += data
            } else if self.elementName == "name" {
                typeName += data
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if listOfRecipeTypes.count > 0 {
            currentType = listOfRecipeTypes[0]
            tfRecipeType.text = currentType?.name
            loadListOfRecipe()
        }
    }
}

// MARK: - UIPicker DataSource & Delegate
extension ListOfRecipeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfRecipeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = listOfRecipeTypes[row]
        return type.name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentType = listOfRecipeTypes[row]
        tfRecipeType.text = currentType!.name
        self.loadListOfRecipe()
    }
}
