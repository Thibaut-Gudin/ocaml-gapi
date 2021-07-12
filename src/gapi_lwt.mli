val load : client:string -> unit Lwt.t

val auth2_init : Base.client_config -> (Ojs.t, Ojs.t) result Lwt.t
