#import "../../lib.typ": Link

#let Page(ctx: (), query: (), storage: ()) = {
  show heading: it => {
    it
    v(0.5em)
  }
  [
  #Link("..")[\<- Back to Home]

  = The principles and details of TypstFront

  == Core Architecture 

  The heart of TypstFront lies in its state-based architecture, drawing inspiration from React’s approach to managing user
  interfaces. At its core, the framework maintains a clear relationship between state and output: any given state will
  consistently produce the same rendered page. When users interact with the page through clicks or keyboard inputs, these
  actions trigger state changes, which in turn cause the interface to update accordingly.

  To overcome Typst’s inherent lack of interactive features, TypstFront employs a combination of HTML ```html <a>``` tags,
  JavaScript event handlers, and client-server communication. This architecture enables interactive behavior while working
  within Typst’s constraints.

  === Example: Counter Implementation 

  Consider a simple counter implementation as an illustrative example:

  ```typst
  #import "../lib.typ": Button
  #let Page(ctx: (), query: (), storage: ()) = {
      let use-state = ctx.use-state
      let (counter, set-counter) = use-state("counter", 0)

      Button(set-counter(counter + 1))[Counter: #counter]
  }
  ```

  Let’s examine how a simple counter works:

  When a user first visits the page, the counter initializes to its default state of ```js 0```. The framework then generates an
  ```html <a>``` tag that displays ```js "Counter: 0"``` as the current state. Crucially, this ```html <a>``` tag’s href attribute contains the next potential state encoded as ```js { counter: 1 }```. This encoding represents the state transition that should occur when the user clicks the button.

  ```typst
  #let on-click(state, body) = {
    link("/_action?data=" + state-string(state))[#body]
  }
  ```

  On the frontend, JavaScript processes these special links in two steps. First, it removes their href attributes to
  prevent default browser navigation. Then, it attaches click event listeners to handle user interactions. When a user
  clicks the counter button, JavaScript sends a POST request to the server with the payload ```js { counter: 1 }```, representing
  the desired new state.

  The backend receives the new state data. Then, it embeds this state into the Typst source code. Next, it triggers a new
  render of the page. During this render, the use-state hook returns the updated value of ```js 1```, completing the state
  transition cycle.

  ```ts
  let state = {}
  if (req.method === "POST") {
    const data = await req.json();
    state = data.state ?? {}
    // ...
  }
  ```

  === Additional Features 

  Beyond this basic counter example, TypstFront implements additional features following similar architectural principles.
  The framework includes storage management through use-storage and keyboard event handling capabilities. These features
  maintain the same pattern of state management and event processing, so i won’t delve into them in detail here.

  == Limitations 
  
  However, TypstFront does face several significant limitations. The framework’s architecture introduces notable latency
  since every interaction requires a complete network round-trip to the server for processing.

  The interaction model remains relatively basic, relying on manually bound JavaScript events rather than providing a rich
  set of native interactive capabilities.

  Furthermore, the current implementation lacks support for modern web features such as animations and multimedia content,
  which can restrict its use in more dynamic web applications.

  At its heart, this project is just a fun experiment to explore the boundaries of Typst’s (or any other typesetting
  language’s) capabilities. The results might not be practical, but they’re certainly entertaining and might spark some
  interesting ideas for future experiments!

  ]
}