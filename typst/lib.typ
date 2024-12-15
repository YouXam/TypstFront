#let urlencode(text) = {
  let map = (
    " ": "+",
    "!": "%21",
    "\"": "%22",
    "#": "%23",
    "$": "%24",
    "%": "%25",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "*": "%2A",
    "+": "%2B",
    ",": "%2C",
    "-": "%2D",
    ".": "%2E",
    "/": "%2F",
    ":": "%3A",
    ";": "%3B",
    "<": "%3C",
    "=": "%3D",
    ">": "%3E",
    "?": "%3F",
    "@": "%40",
    "[": "%5B",
    "\\": "%5C",
    "]": "%5D",
    "^": "%5E",
    "_": "%5F",
    "`": "%60",
    "{": "%7B",
    "|": "%7C",
    "}": "%7D",
    "~": "%7E",
  );

  let a = ()
  for char in text.clusters() {
    if map.at(char, default: false) != false {
      a.push(map.at(char))
    } else {
      a.push(char)
    }
  }

  a.join("")
}


#let merge(..objs) = {
  let objs = objs.pos()
  if type(objs.at(objs.len() - 1)) != "dictionary" {
    return objs.at(objs.len() - 1)
  }
  let a = (:)
  for obj in objs {
    for key in obj.keys() {
      let value-type = type(obj.at(key)) 
      if value-type  == "dictionary" {
        a.insert(key, merge(
          a.at(key, default: (:)),
          obj.at(key)
        ))
      } else {
        a.insert(key, obj.at(key))
      }
    }
  }
  a
}

#let state-merge(..objs) = {
  let a = (:)
  for obj in objs.pos() {
    for key in obj.keys() {
      if key == "state" {
        if a.at("state", default: none) == none {
          a.insert("state", (
            old: obj.at("state").old,
            delta: obj.at("state").delta
          ))
        } else {
          a.insert("state", (
            old: a.at("state").old,
            delta: merge(
              a.at("state").delta,
              obj.at("state").delta
            )
          ))
        }
      } else {
        a.insert(key, merge(
          a.at(key, default: (:)),
          obj.at(key)
        ))
      }
    }
  }
  a
}

#let apply-state(state) = {
  if state.at("state", default: none) != none {
    state.insert("state", merge(state.at("state").old, state.at("state").delta))
  }
  state
}

#let state-string(state) = {
  let data = if type(state) == "function" {
    state()
  } else {
    state
  }
  urlencode(json.encode(apply-state(data), pretty: false))
}

#let on-click(state, body) = {
  link("/_action?data=" + state-string(state))[#body]
}

#let on-keydown(state, key: none, keycode: none, prevent-default: false) = {
  link(
    "/_keydown?data=" + state-string(state) + 
    (if key != none { "&key=" + urlencode(key) } else { "" }) +
    (if keycode != none { "&code=" + str(keycode) } else { "" }) +
    (if prevent-default { "&prevent_default=true" } else { "" })
  )[
    #set text(size: 0pt)
    a
  ]
}


#let Button(new-state, disabled: false, height: auto, radius: 2pt, inset: 5pt, body) = {
  if disabled {
    box(stroke: 0.5pt + gray, inset: inset, radius: radius, height: height)[
      #set text(fill: gray)
      #set align(center + horizon)
      #body
    ]
  } else {
    on-click(
      new-state,
      box(stroke: 0.5pt, inset: inset, radius: radius, height: height)[
        #set align(center + horizon)
        #body
      ]
    )
  }
}

#let Link(href, body) = {
  show link: it => {
    set text(fill: blue)
    underline(it, offset: 2pt)
  }
  link(href)[#body]
}

#let redirect(href) = {
  (
    redirect: href
  )
}
