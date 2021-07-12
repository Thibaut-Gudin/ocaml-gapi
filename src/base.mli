val load : client:string -> callback:(unit -> unit) -> unit
  [@@js.global "gapi.load"]

type ux_values = Popup [@js "popup"] | Redirect [@js "redirect"] [@@js.enum]

type client_config

val client_config :
  client_id:string ->
  ?cookie_policy:string ->
  ?scope:string ->
  ?fetch_basic_profile:bool ->
  ?hosted_domain:string ->
  ?ux_mode:ux_values ->
  ?redirect_uri:string ->
  unit ->
  client_config
  [@@js.builder] [@@js.verbatim_names]

(*type googleAuth [@@js.global "gapi.auth2.GoogleAuth"]*)

type googleAuth

val auth2_init : client_config -> googleAuth [@@js.global "gapi.auth2.init"]

val then_ :
  googleAuth -> onInit:(Ojs.t -> unit) -> onError:(Ojs.t -> unit) -> unit
  [@@js.call]

module User_promise : sig
  type t

  type user

  type error = Ojs.t

  val then_ : t -> (user -> unit) -> (error -> unit) -> unit [@@js.call]
end

val signIn : Ojs.t -> User_promise.t [@@js.call]

type authResponse

val getAuthResponse :
  User_promise.user -> ?includeAuthorizationData:bool -> unit -> authResponse
  [@@js.call]

val id_token : authResponse -> string [@@js.get "id_token"]
