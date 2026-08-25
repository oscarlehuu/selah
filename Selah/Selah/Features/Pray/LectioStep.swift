import Foundation

struct LectioStep {
    let name: String
    let headline: String
    let guide: String

    static let all = [
        LectioStep(name: "Read", headline: "Read it slowly", guide: "Read the words once out loud, then once in silence. Don’t study it. Just let it arrive."),
        LectioStep(name: "Reflect", headline: "Where does it touch you?", guide: "One word probably stood out. Stay with that word for a moment instead of moving on."),
        LectioStep(name: "Pray", headline: "Say it back to God", guide: "Here is a prayer in your own weather. Change any word. It is yours."),
        LectioStep(name: "Rest", headline: "Now just stay", guide: "Nothing left to do. Breathe with the light and let the silence be enough.")
    ]
}
