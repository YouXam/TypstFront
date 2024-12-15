#import "../../lib.typ": Button, Link, on-click

#let Page(ctx: (), query: (), storage: ()) = {
  let use-storage = ctx.use-storage
  let (todo, set-todo, ..) = use-storage("todo", ())
  [
    #Link("..")[\<- Back to Home]

    = TodoList

    #v(1em)
    #Link("add")[Add Todo]
    #v(0.5em)

    #let Delete(index) = {
      on-click(() => {
        let new-todo = todo
        new-todo.remove(index)
        return set-todo(new-todo)
      })[
        #set text(fill: red)
        #h(1em)
        Delete
      ]
    }

    #if todo.len() == 0 {
      text("Empty", fill: gray)
    } else {
      let items = ()
      for i in range(todo.len()) {
        items.push((i, todo.at(i)))
      }
      list(..items.map((it) => {
        [#it.at(1) #Delete(it.at(0))]
      }))
    }
  ]
}