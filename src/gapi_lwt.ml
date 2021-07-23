let promise (f : _ -> unit) =
  let (promise, resolver) = Lwt.task () in
  f @@ Lwt.wakeup resolver ;
  promise

let load ~client = promise @@ fun wakeup -> Base.load ~client ~callback:wakeup

let then_ init =
  promise @@ fun wakeup ->
  Base.then_
    init
    ~onInit:(fun auth -> wakeup (Ok auth))
    ~onError:(fun msg -> wakeup (Error msg))

let auth2_init config =
  let init = Base.auth2_init config in
  then_ init
