# ocaml-gapi

Binding to [gapi](https://github.com/google/google-api-javascript-client)

## What does ocaml-gapi do ?

"gapi" (for Google API) is a library that implements JavaScript client
methods and attributes that can be used to implement Google Sign-In in a
web application.

## How to install and compile your project by using this plugin ?

You can use opam by pinning the repository with:
```Shell
opam pin add gapi https://github.com/Thibaut-Gudin/ocaml-gapi
```

to compile your project, use:
```Shell
dune build @install
```


## How to use it?

See [Google Sign-In JavaScript
API](https://developers.google.com/identity/sign-in/web/reference?hl=ca)
for more details

#### Type `Gapi.ux_values`

The optional argument `ux_mode` is a string that represents the "User
eXperience" that can be lived when using function form *Gapi* (mainly
the function for the consent flow). There is only two modes of "UX", to
impose that into this library you will have to use this type that can
take those values only:

     | Gapi.ux_value Popup (for "popup" value)

     | Gapi.ux_value Redirect (for "redirect")

In practice, if the `ux_mode` is on `popup` mode, then the *Gapi*
function will be executed as a popup on the same page were the function
was called. In the other hand, if the `ux_mode` is on `redirect` then
the *Gapi* function will be executed after a redirection of the user to
another page, you can change the default redirection uri with the
optional parameter `redirect_uri` in functions that use `ux_mode` as
parameter.

### `Gapi.load`

This function load the Google APIs platform library to your application,
you should call it before to use any other "Gapi" function into your
code.

See more details in [API documentation](https://github.com/google/google-api-javascript-client/blob/master/docs/reference.md#----gapiloadlibraries-callbackorconfig------)

### `Gapi.auth2_init`

> Initializes the GoogleAuth object. You must call this method before
  calling gapi.auth2.GoogleAuth's methods (methods that have a
  `googleAuth` argument).
  When you initialize the GoogleAuth object, you configure the object
  with your OAuth 2.0 client ID and any additional options you want to
  specify. Then, if the user has already signed in, the GoogleAuth
  object restores the user's sign-in state from the previous session.

Source: [Gapi AST](https://developers.google.com/identity/sign-in/web/reference?hl=ca)

This function takes a single argument of type `client_config`. A
`client_config` is composed of a required argument and a series of
optional arguments:

      ° `client_id`-> string : is the required argument, it represents
      the app's client ID
      ° `cookie_policy` -> string : The domain for which to create
      sign-in cookies. Either a URI, "single_host_origin", or
      "none". It's default value is "single_host_origin" if unspecified.
      ° `scope` -> string : The scope to request, as a space-delimited
      string. !!! This value is optional only if "fetch_basic_profile"
      is set to false !!!
      ° `fetch_basic_profile` -> bool : Adds 'profile', 'email', and
      'openid' to the requested scopes when "true". It's basic value is
      "true" when unspecified
      ° `hosted_domain` -> string : Indicate the G Suite domain to which
      users must belong to sign in. !!! You must request the 'email'
      scope when using this parameter if "fetch_basi_profile" = false !!!
      ° `ux_mode` -> Gapi.ux_values : See the corresponding section above.
      ° `redirect_uri` -> string : This parameter is applied only if
      "ux_mode" = Redirect, see the section *Type `Gapi.ux_values`*.

Source: [ClientConfig  AST](https://developers.google.com/identity/sign-in/web/reference?hl=ca#gapiauth2clientconfig)

It returns a result of type `googleAuth` that can be used for other
functions (see section "How to use a `googleAuth` result" below)

### Module `User_promise`

This module is mainly used in order to have a way to execute the
promise returned by the function `Gapi.then_`, the function
`Gapi.User_promise.then_` can be used if you want, for example, a function
that indicates if the function is in a state `onInit` or in a state
`onError` after an execution for a given user.

The types `user` and `error` give a precision about the `Obj.t` used in
argument for the callbacks of the promise.
`user` contains info about the "user" of the account that connects using
`then_` function.

#### `Gapi.signIn`

You can use `Gapi.User_promise.then_` by giving a `Gapi.User_promise.t`
as argument, that you obtain with the function
`Gapi.signIn`. `Gapi.signIn` takes a result of `Gapi.then_` as
argument.

For example with a callback called "wakeup":
```Ocaml
let _ = Gapi.load ~client:"auth2" ~callback:(fun _ -> wakeup ()) in
let init = Gapi.auth2_init (Gapi.client_config ~client_id:"test" ()) in
let auth = Gapi.then_ ~onInit(fun usr -> wakeup (Ok usr))
~onError:(fun msg -> wakeup (Error msg)) in
Gapi.User_promise.then_ (Gapi.signIn auth) (fun c -> wakeup (Ok c)) (fun
msg -> wakeup (Error msg))
```

### `Gapi.getAuthResponse` type authResponse

This type represents the response object returned from the user's auth
session, you can get the `authResponse` of a given user with the
function `Gapi.getAuthResponse`:

```Shell
        Gapi.getAuthResponse : User_promise.user -> ?boolean -> unit
```
The optional boolean argument "includeAuthorizationData" specifies
        whether to always return an access token and scopes or not. It default
        value is "true" and in this case the access token and requested
        scopes are not returned.


An `authResponse` object has several values accessible with this library:

#### `id_token`

Accessible with `Gapi.id_token`, this "string" value represents the ID
token granted.

[...TODO add other authResponse values...]


## How to use a `googleAuth` result

Like said above, the function `Gapi.auth2_init` returns a `googleAuth`,
that type can be used as an argument in order to use some functions that
are linked to the object.

### `Gapi.then_`

This is the main use of a `googleAuth`, this function takes 2 "callbacks"
in parameters: "onInit" and "onError". It returns a promise that will
calls the `onInit` function when the `GoogleAuth` object is fully
initialized or the "onError" function if an error is raised while
initializing.

Example:

```Ocaml
Gapi.then_ init
           ~onInit:(fun auth -> wakeup (Ok auth))
           ~onError:(fun msg -> wakeup (Error msg))
```

## Module `Lwt`

This module `Lwt` provides alternatives implementations of `Gapi`
functions that return a *promise* of a result, under the form of `_
Lwt.t` objects.

[Learn more about Lwt](https://ocsigen.org/lwt/latest/manual/manual)

### `Gapi.Lwt.load`
This version of the `load` function can't receive a *callback* argument,
because it is used in order to *wakeup* a thread in a *wait* state.

### `Gapi.Lwt.then_`
This version of the `then_` function takes only one argument of type
`googleAuth`, the `onInit` and `onError` functions are used in order to
provide a promise of result.
This function returns an object `Ok auth` if the execution of `then_`
works or an object `Error msg` if the execution of `then_` fails, you
can use this result in your program to differentiate cases of failure
or success.

Example:
```Ocaml
let init = Gapi.auth2_init (Gapi.client_config ~client_id:"id" ()) in
let%lwt auth = Gapi.Lwt.then_ in
match auth with
| Error msg ->
  print_endline ("Failed with code error: " ^ msg)
| Ok token -> (
  [...]
)
```

### `Gapi.Lwt.auth2_init`
This function is a combination of `Gapi.auth2_init` and `Gapi.Lwt.then_`
