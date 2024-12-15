#import "../lib.typ": Link, Button

#let Page(ctx: (), query: (), storage: ()) = {
  let use-state = ctx.use-state
  let (counter, set-counter) = use-state("counter", 0)
  show heading: it => {
    it
    v(0.5em)
  }
  [
    = TypstFront

    This website is written in Typst. 
    
    #Link("https://github.com/YouXam/TypstFront")[TypstFront] is a front-end framework that allows you to build dynamic and interactive web pages using #Link("https://typst.app/docs")[Typst]. This project is *mainly for fun* and not intended to be used in production. 

    == Example Pages

    _Note: If you feel that the feedback from clicking or pressing keys is slow, this might be normal, as each interaction requires sending a network request. You can #Link("https://github.com/YouXam/TypstFront")[run the project locally] to experience the full speed._


    #set list(spacing: 1em)
    - #Link("/todo")[Todo List]
    - #Link("/tetris")[Tetris]
    - #Link("/tictactoe")[Tic Tac Toe]
    - #Link("/wordle")[Wordle]

    == Counter Example

    ```typst
    #import "../lib.typ": Button
    #let Page(ctx: (), query: (), storage: ()) = {
      let use-state = ctx.use-state
      let (counter, set-counter) = use-state("counter", 0)

      Button(set-counter(counter + 1))[Counter: #counter]
    }
    ```

    #box()[
      #Button(set-counter(counter + 1))[Counter #counter]
    ]

    == How TypstFront Works

    See #Link("explain")[here] for a brief explanation of how TypstFront works and other information.

  ]
}