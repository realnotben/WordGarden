//
//  ContentView.swift
//  WordGarden
//
//  Created by FIGUEROA, BENJAMIN on 1/16/26.
//

import SwiftUI

struct ContentView: View {
    private static let maximumGuesses = 8 // Need to refer to this as Self.maximumGuesses
    
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var gameStatusMessage = "How many guesses to uncover the hidden word??"
    @State private var currentWordIndex = 0 // index in wordsToGuess
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @FocusState private var textFieldIsFocused: Bool
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"] // All caps
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            //TODO: Switch to wordsToGuess[currentWordIndex]
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            // As long as guessedLetter is not an empty string, we can continue, otherwise don't do anything
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                            updateGamePlay()
                        }
                    
                    Button("Guess a Letter:") {
                        guessALetter()
                        updateGamePlay()
                    }
                    
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    // if all the words have been guessed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    
                    // Reset after word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1_)
                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses // because maximum guesses is Static
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How many guesses to uncover the hidden word?"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }

            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            // CREATE A STRING FROM A REPEATING VALUE
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1_)
        }
    }
    
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = wordToGuess.map { letter in
            lettersGuessed.contains(letter) ? "\(letter)" : "_"
        } .joined(separator: " ")
            }
    
    func updateGamePlay() {
        
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "flower\(guessesRemaining)"
        }
        
        // When do we play another word?
        if !revealedWord.contains("_") {
            // Guessed when there are no "_" in revealedWord
            gameStatusMessage = "You guessed it! It took you \(lettersGuessed.count) guesses to guess the word!"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
        } else if  guessesRemaining == 0 {
            // Word missed
            gameStatusMessage = "So sorry, you're all out of guesses..."
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
        } else {
            // Keep guessing
            //TODO: Redo this with LocalizedStringKey & Inflect
            gameStatusMessage = "You've made \(lettersGuessed.count) guess\(lettersGuessed.count == 1 ? "." : "es.")"
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've tried all of the words, restart from the beginning?"
        }
        
        guessedLetter = ""
    }
}

#Preview {
    ContentView()
}
