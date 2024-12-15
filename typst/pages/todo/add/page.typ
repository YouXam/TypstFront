#import "../../../lib.typ": Link, on-click, Button, state-merge, redirect, on-keydown
#import "@preview/shadowed:0.1.2": shadowed

#let Page(ctx: (), query: (), storage: ()) = {
  let use-state = ctx.use-state
  let use-storage = ctx.use-storage
  let (key, set-key) = use-state("key", "")
  let (todo, set-todo, ..) = use-storage("todo", ())
  [
    #align(
      center,
    )[
      #box()[

        #align(left)[
          #Link("..")[\<- Back to TodoList]
        ]
        #v(1em)

        = Add Todo

        #v(0.5em)

        #let submit_action = state-merge(set-todo(v => {
          v.push(key)
          v
        }), redirect(".."))

        #shadowed()[
          #grid(
            columns: (175pt, auto),
            box(stroke: 0.5pt + if key.len() != 0 { black } else { gray }, fill: gray.lighten(95%), width: 175pt, inset: (x: 5pt), height: 20pt, radius: (
              top-left: 2pt,
              top-right: 0pt,
              bottom-left: 2pt,
              bottom-right: 0pt
            ))[
              #grid(columns: (1fr, 20pt), align(horizon + left)[
                  #if key.len() != 0 {
                    grid(
                      columns: (auto, 1pt, 1fr),
                      gutter: 0.5pt,
                      key,
                      line(length: 10pt, stroke: 0.5pt, start: (0%, 0%), end: (0%, 60%)),
                      [],
                    )
                  } else {
                    text("Enter...", fill: gray)
                  }
                ], align(horizon)[
                  #if key.len() != 0 {
                    on-click(set-key(key.slice(0, key.len() - 1)))[
                      #box(height: 20pt)[
                        #image("backspace.svg")
                      ]
                    ]
                  } else {
                    box(height: 20pt)
                  }
                ],
              )
            ],
            Button(submit_action, disabled: key.len() == 0, height: 20pt, radius: (
              top-left: 0pt,
              top-right: 2pt,
              bottom-left: 0pt,
              bottom-right: 2pt
            ))[Submit]
          )
        ]

        #text(size: 0.8em, fill: gray)[
          #set par(spacing: 0.8em)
          Only available on desktop, you can type directly using the keyboard.
          
          Only letters, numbers, and spaces are allowed.

          Use backspace to delete, enter to submit.
        ]

        #let Key(text) = {
          on-keydown(set-key(key + text), key: text)
        }

        #{
          Key("1"); Key("2"); Key("3"); Key("4"); Key("5"); Key("6"); Key("7")
          Key("8"); Key("9"); Key("0"); Key("a"); Key("b"); Key("c"); Key("d"); Key("e")
          Key("f"); Key("g"); Key("h"); Key("i"); Key("j"); Key("k"); Key("l"); Key("m")
          Key("n"); Key("o"); Key("p"); Key("q"); Key("r"); Key("s"); Key("t"); Key("u")
          Key("v"); Key("w"); Key("x"); Key("y"); Key("z");
          on-keydown(set-key(key + " "), key: " ", prevent-default: true)
          if key.len() != 0 {
            on-keydown(set-key(key.slice(0, key.len() - 1)), keycode: 8)
            on-keydown(submit_action, key: "Enter")
          }
        }
      ]
    ]
  ]
}