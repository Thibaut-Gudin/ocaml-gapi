let load ~client =
  let (promise, resolver) = Lwt.wait () in
  let n_callback = function f -> Lwt.wakeup resolver f in
  Base.load ~client ~callback:n_callback ;
  promise

let promise (f : _ -> unit) =
  let (promise, resolver) = Lwt.task () in
  f @@ Lwt.wakeup resolver ;
  promise

let then_ init =
  promise @@ fun wakeup ->
  Base.then_
    init
    ~onInit:(fun auth -> wakeup (Ok auth))
    ~onError:(fun msg -> wakeup (Error msg))
