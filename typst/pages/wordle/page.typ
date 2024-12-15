#import "../../lib.typ": Link, Button, on-click, state-merge, on-keydown

#let boxSize = 18pt
#let word(w, states, active: false) = {
  let res = ()
  let length = w.len()
  for i in range(5) {
    let letter_state = states.at(i, default: "")
    let letter = upper(w.at(i, default: ""))
    let fill = if letter == "" {
      white
    } else if letter_state == "correct" {
      rgb("#4caf50")
    } else if letter_state == "wrong" {
      rgb("#c5b566")
    } else if letter_state == "absence" {
      rgb("#797c7e")
    }
    let stroke = if active and i == length {
      1pt + blue
    } else if letter == "" {
      0.5pt + gray.lighten(30%)
    } else {
      0.5pt + fill
    }
    res.push(box(fill: fill, height: boxSize, width: boxSize, stroke: stroke, {
      set align(center + horizon)
      text(1.2em, fill: white)[#letter]
      if active and length == 5 and i == 4 {
        place(dx: 22pt, dy: -6pt, block(width: 100pt, text([Enter to submit], fill: gray, size: 0.6em)))
      }
    }))
  }
  res
}

#let answer = upper("typst")

#let check(guess, answer, display) = {
  let result = ()
  let answerArray = answer.clusters()
  let guessArray = guess.clusters()

  if not display {
    return range(guessArray.len()).map(it => "absence")
  }

  let usedAnswerIndices = (:)

  for i in range(guessArray.len()) {
    if guessArray.at(i) == answerArray.at(i) {
      result.push("correct")
      usedAnswerIndices.insert(str(i), true)
    } else {
      result.push(none)
    }
  }
  for i in range(guessArray.len()) {
    if result.at(i) == none {
      if answerArray.contains(guessArray.at(i)) and usedAnswerIndices.at(str(answerArray.position(it => it == guessArray.at(i))), default: none) == none {
        result.at(i) = "wrong"
        usedAnswerIndices.insert(str(answerArray.position(it => it == guessArray.at(i))), true)
      } else {
        result.at(i) = "absence"
      }
    }
  }

  result
}

#let Page(ctx: (), query: (), storage: ()) = {
  let use-state = ctx.use-state
  let (words, set-words) = use-state("words", range(6).map(it => ""))
  let (now-word, set-now-word) = use-state("now_word", 0)
  let is-win = words.slice(0, now-word).find(it => it == answer) != none
  let is-lose = now-word == 6 and not is-win
  set align(center)
  set page(margin: (top: 20pt, bottom: 0pt))

  let merged-checks = {
    let result = (:)
    for i in range(now-word) {
      let word-result = check(words.at(i), answer, true)
      for j in range(5) {
        let letter = words.at(i).at(j)
        let letter-result = word-result.at(j)
        if letter-result == "correct" {
          result.insert(letter, "correct")
        } else if letter-result == "wrong" and result.at(letter, default: "") != "correct" {
          result.insert(letter, "wrong")
        } else if letter-result == "absence" and result.at(letter, default: "") == "" {
          result.insert(letter, "absence")
        }
      }
    }
    result
  }

  let add-letter(letter) = {
    let this-word = words.at(now-word, default: none)
    if this-word == none {
      return set-words(words)
    }
    let new-word = words
    if this-word.len() < 5 and not is-win {
      new-word.at(now-word) = this-word + letter
    }
    set-words(new-word)
  }

  let del-letter() = {
    let this-word = words.at(now-word, default: none)
    if this-word == none {
      return set-words(words)
    }
    let new-word = words
    if this-word.len() > 0 and not is-win {
      new-word.at(now-word) = this-word.slice(0, this-word.len() - 1)
    }
    set-words(new-word)
  }

  let submit-word() = {
    let now-new-word = now-word
    if now-new-word < 6 and words.at(now-new-word, default: "").len() == 5 and not is-win {
      now-new-word += 1
    }
    set-now-word(now-new-word)
  }

  let Key(key, width: boxSize * 0.8, size: 0.7em) = {
    on-keydown(add-letter(key), key: lower(key))
    let color = if merged-checks.at(key, default: "") == "correct" {
      rgb("#4caf50")
    } else if merged-checks.at(key, default: "") == "wrong" {
      rgb("#c5b566")
    } else if merged-checks.at(key, default: "") == "absence" {
      rgb("#797c7e")
    } else {
      rgb("#d4d6da")
    }
    on-click(add-letter(key))[#box(width: width, radius: 1pt, height: boxSize, fill: color)[
        #set align(center + horizon)
        #set text(size, fill: if is-win or is-lose or words.at(now-word, default: "").len() == 5 {
          if merged-checks.at(key, default: "") == "" {
            gray
          } else {
            gray.lighten(60%)
          }
        } else if merged-checks.at(key, default: "") == "" { 
          black
        } else {
          white
        })
        #strong(key)
      ]]
  }

  let Enter(disable: false) = {
    on-keydown(submit-word(), key: "Enter")
    on-click(submit-word())[#box(width: boxSize * 1.25, height: boxSize, fill: rgb("#d4d6da"), radius: 1pt)[
        #set align(center + horizon)
        #set text(0.4em, fill: if disable { gray } else { black })
        #strong("ENTER")
      ]]
  }

  let Backspace(disable: false) = {
    on-keydown(del-letter(), key: "Backspace")
    on-click(del-letter())[#box(width: boxSize * 1.25, height: boxSize, fill: rgb("#d4d6da"), radius: 1pt)[
      #set align(center + horizon)
      #image(if disable { "backspace-disable.svg" } else { "backspace.svg" }, width: 40%)
    ]]
  }

  let Keyboard() = {
    set par(spacing: 2pt)
    grid(
      columns: 10,
      gutter: 2pt,
      Key("Q"),
      Key("W"),
      Key("E"),
      Key("R"),
      Key("T"),
      Key("Y"),
      Key("U"),
      Key("I"),
      Key("O"),
      Key("P"),
    )
    grid(
      columns: 9,
      gutter: 2pt,
      Key("A"),
      Key("S"),
      Key("D"),
      Key("F"),
      Key("G"),
      Key("H"),
      Key("J"),
      Key("K"),
      Key("L"),
    )
    grid(
      columns: 9,
      gutter: 2pt,
      Enter(disable: is-win or is-lose or words.at(now-word, default: "").len() != 5),
      Key("Z"),
      Key("X"),
      Key("C"),
      Key("V"),
      Key("B"),
      Key("N"),
      Key("M"),
      Backspace(disable: is-win or is-lose or words.at(now-word, default: "").len() == 0),
    )
  }

  [
    #Link("..")[\<- Back to Home]

    = Wordle

    #v(0.5em)

    #if is-win [
      #strong("You win!")
    ] else if is-lose [
      #strong([You lose! The answer is: #raw(answer)])
    ]

    #table(columns: 5, stroke: none, gutter: 2pt, inset: 0pt, ..range(6).map(it => {
      word(words.at(it), check(words.at(it), answer, it < now-word), active: it == now-word)
    }).flatten())

    #Keyboard()
  ]
}