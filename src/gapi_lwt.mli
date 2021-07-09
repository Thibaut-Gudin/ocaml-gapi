val load : client:string -> Ojs.t Lwt.t

val then_ : Base.googleAuth -> (Ojs.t, Ojs.t) result Lwt.t
