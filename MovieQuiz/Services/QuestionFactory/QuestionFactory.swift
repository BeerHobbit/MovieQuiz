import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    //MARK: - Private Custom Types
    
    private enum RatingCompression: CaseIterable {
        case greater
        case less
        
        var questionText: String {
            switch self {
            case .greater:
                return "Рейтинг этого фильма больше чем"
            case .less:
                return "Рейтинг этого фильма меньше чем"
            }
        }
        
        func isCorrect(rating: Float, comparedTo value: Float) -> Bool{
            switch self {
            case .greater:
                return rating > value
            case .less:
                return rating < value
            }
        }
    }
    
    private enum KeyError: Error {
        case invalidAPIKey(String)
        
        func printError() {
            switch self {
            case .invalidAPIKey(let message):
                print(message)
            }
        }
        
    }
    
    
    //MARK: - Private Properties
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    /*
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    */
    
    
    //MARK: - Initializer
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    
    //MARK: - Public Methods
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData()
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = Float((6..<10).randomElement() ?? 7)
            let compression = RatingCompression.allCases.randomElement() ?? .greater
            let text = "\(compression.questionText) \(Int(randomRating))?"
            let correctAnswer = compression.isCorrect(rating: rating, comparedTo: randomRating)
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }
            switch result {
                
            case .success(let mostPopularMovies):
                if mostPopularMovies.hasError {
                    let keyError = KeyError.invalidAPIKey(mostPopularMovies.errorMessage)
                    keyError.printError()
                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData()
                    }
                } else {
                    self.movies = mostPopularMovies.items
                    DispatchQueue.main.async {
                        self.delegate?.didLoadDataFromServer()
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData()
                }
                
            }
        }
    }
    
}

