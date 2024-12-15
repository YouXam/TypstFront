#import "../../lib.typ": Link, Button, on-click

#let calc-winner(board) = {
  let lines = ((0, 1, 2), (3, 4, 5), (6, 7, 8), (0, 3, 6), (1, 4, 7), (2, 5, 8), (0, 4, 8), (2, 4, 6));

  for i in range(lines.len()) {
    let (a, b, c) = lines.at(i);
    if board.at(a).at(1) != "" and board.at(a).at(1) == board.at(b).at(1) and board.at(b).at(1) == board.at(c).at(1) {
      return board.at(a).at(1)
    }
  }
  return none
}

#let Page(ctx: (), query: (), storage: ()) = {
  let use-state = ctx.use-state
  let (board, set-board) = use-state("map", range(9).map(i => (i, "")))
  [
    #set align(center)

    #Link("..")[\<- Back to Home]

    = Tic Tac Toe

    #v(1em)

    #let winner = calc-winner(board)
    #let next = if calc.rem(board.filter(((i, v)) => v == "").len(), 2) == 0 { "X" } else { "O" }
    #let size = 30pt
    #let Square(i, v) = {
      on-click(() => {
        let next-board = board
        if next-board.at(i) == (i, "") and winner == none {
          next-board = next-board.map(((j, w)) => {
            if i == j { (j, next) } else { (j, w) }
          })
        }
        set-board(next-board)
      })[#box(height: size, width: size, stroke: 0.5pt)[#v]]
    }

    #if winner == none [
      Next player: #next
    ] else [
      Winner: #winner

      #Button(set-board(range(9).map(i => (i, ""))))[Restart]
    ]

    #table(columns: 3, stroke: none, inset: 0pt, align: center + horizon, ..board.map(((i, v)) => {
      Square(i, v)
    }))
  ]
}