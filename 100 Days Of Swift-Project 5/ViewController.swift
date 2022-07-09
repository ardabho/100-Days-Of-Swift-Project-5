//
//  ViewController.swift
//  100 Days Of Swift-Project 5
//
//  Created by Arda Büyükhatipoğlu on 11.06.2022.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var currentQuestion: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "background_3.jpg"))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startwords = try? String(contentsOf: startWordsURL) {
                self.allWords = startwords.components(separatedBy: "\n")
            }
        }
        
        if self.allWords.isEmpty {
            self.allWords = ["silkworm"]
        }
        
        
        loadQuestion()
        startGame()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func restartGame() {
        currentQuestion.word = allWords.randomElement()!
        currentQuestion.answers.removeAll()
        startGame()
    }
    //MARK: - User Defaults functions
    
    func save() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(currentQuestion) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "question")
        } else {
            print("Failed to save people data")
        }
    }
    
    func loadQuestion() {
        let defaults = UserDefaults.standard
        
        if let savedQuestion = defaults.object(forKey: "question") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                try currentQuestion = jsonDecoder.decode(Question.self, from: savedQuestion)
            } catch {
                print("Failed to load question")
            }
        } else {
            currentQuestion = Question(word: allWords.randomElement()!, answers: [])
        }
    }
    
    //MARK: - Answer Validation functions:
    
    /// Check if the word user typed is possible with the given words letters.
    /// - Parameter word: Word ( String ) entered by the user
    /// - Returns: Bool
    func isPossible(word: String) -> Bool {
        guard var tempword = title?.lowercased() else { return false}
        
        for letter in word {
            if let position = tempword.firstIndex(of: letter) {
                tempword.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    ///Checks if the word is entered before by the user
    func isOriginal(word: String) -> Bool {
        return !currentQuestion.answers.contains(word.lowercased())
    }
    
    ///Checks if the word is a real word by comparing it with allWords
    func isReal(word: String) -> Bool {
        if word.count < 2 {
            return false
        } else if word.lowercased() == title?.lowercased() {
            return false
        } else {
            
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return mispelledRange.location == NSNotFound
        }
    }
    
    // Submit the word
    func submit(_ answer: String) {
        
        let lowerCased = answer.lowercased()
        
        if isPossible(word: lowerCased){
            if isOriginal(word: lowerCased){
                if isReal(word: lowerCased){
                    
                    currentQuestion.answers.insert(answer, at: 0)
                    save()
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                    
                } else {
                    showErrorMessage(title: "Word not recognized", message: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(title: "Word used already", message: "Be more original!")
            }
        } else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage(title: "Word not possible", message: "You can't make up that word from \(title)")
        }
    }
    
    func showErrorMessage(title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    
    @objc func startGame() {
        title = currentQuestion.word
        tableView.reloadData()
    }
    
    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion.answers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = currentQuestion.answers[indexPath.row]
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
