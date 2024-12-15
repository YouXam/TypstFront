#set page(width: 512pt, height: auto, margin: (top: 32pt, rest: 64pt))

//state_begin
#let _query = ()
#let _state = ()
#let _storage = ()
//state_end

#let ctx = (use-state: (key, default) => {
  let value = _state.at(key, default: none)
  let value = if value == none { default } else { value }
  let update-function = (v) => {
    let delta = (:)
    if type(v) == "function" {
      delta.insert(key, v(value))
    } else {
      delta.insert(key, v)
    }
    (state: (old: _state, delta: delta))
  }
  return (value, update-function)
}, use-storage: (key, default) => {
  let value = _storage.at(key, default: none)
  let value = if value == none { default } else { value }
  let update-function = (v) => {
    if type(v) == "function" {
      v = v(value)
    }
    (
      storage: ("set": ((key, v), ).to-dict()),
      state: (old: _state, delta: (:))
    )
  }
  let delete-function = () => {
    (
      storage: ("delete": (key, )),
      state: (old: _state, delta: (:))
    )
  }
  return (value, update-function, delete-function)
})