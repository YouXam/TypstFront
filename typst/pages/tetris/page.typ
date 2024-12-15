#import "../../lib.typ": Button, on-keydown, Link
#import "soviet-matrix/lib.typ": game

#let Page(ctx: (), query: (), storage: ()) = {
  set page(width: 600pt, margin: (top: 20pt))
  let use-state = ctx.use-state
  let (move, set-move) = use-state("move", "")
  Link("..")[\<- Back to Home]

  let kbd(key) = {
    box(inset: 1pt, baseline: 3pt)[
      #box(
        stroke: 0.5pt,
        fill: gray.lighten(80%),
        inset: 2pt,
        radius: 1pt,
        baseline: 3pt
      )[
        #set text(size: 0.8em)
        #set align(center + horizon)
        #text(key)
      ]
    ]
  }

  let Operation(append, body) = {
    Button(set-move(move + append), inset: (x: 4pt, y: 2pt))[#body]
  }
  [
    #set text(size: 0.6em)
    #grid(
      columns: (50%, 50%),
      align: center,
      game([#move]),
      block(height: 1fr)[
        #set align(horizon)
        #table(
          columns: 1,
          stroke: none,
          Operation("q")[Left Rotate (#kbd("q")/#kbd("z"))],
          Operation("w")[Half Turn (#kbd("w")/#kbd("up"))],
          Operation("e")[Right Rotate (#kbd("e")/#kbd("x"))],
          Operation("a")[Left (#kbd("left")/#kbd("a"))],
          Operation("s")[Down (#kbd("down")/#kbd("s"))],
          Operation("d")[Right (#kbd("right")/#kbd("d"))],
          Operation("f")[Fast Drop (#kbd("space")/#kbd("enter"))]
        )
      ]
    )
  ]

  on-keydown(set-move(move + "q"), key: "q")
  on-keydown(set-move(move + "q"), key: "z")
  on-keydown(set-move(move + "w"), key: "w")
  on-keydown(set-move(move + "w"), keycode: 38, prevent-default: true)
  on-keydown(set-move(move + "e"), key: "e")
  on-keydown(set-move(move + "e"), key: "x")
  on-keydown(set-move(move + "a"), key: "a")
  on-keydown(set-move(move + "a"), keycode: 37, prevent-default: true)
  on-keydown(set-move(move + "s"), key: "s")
  on-keydown(set-move(move + "s"), keycode: 40, prevent-default: true)
  on-keydown(set-move(move + "d"), key: "d")
  on-keydown(set-move(move + "d"), keycode: 39, prevent-default: true)
  on-keydown(set-move(move + "f"), key: " ", prevent-default: true)
  on-keydown(set-move(move + "f"), key: "Enter")
}