import bagofholding/supabase.{
  type BagId, type CollectionId, type UserId, BagId, CollectionId,
}
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri.{type Uri}
import lustre
import lustre/attribute.{type Attribute, class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem
import plinth/browser/location
import plinth/browser/window

const base_path = "SUBSTITUTE_BASE_PATH"

const supabase_url = "SUBSTITUTE_PUBLIC_SUPABASE_URL"

const supabase_key = "SUBSTITUTE_PUBLIC_SUPABASE_KEY"

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Anon(route: PublicRoute, data: PublicModel)
  LoggedIn(route: Route, data: LoggedInModel)
}

type PublicModel {
  PublicModel(supaclient: supabase.Client)
}

type LoggedInModel {
  LoggedInModel(supaclient: supabase.Client, user: User)
}

type User {
  NewUser(id: UserId)
  UnloadedUser(id: UserId)
  NamedUser(id: UserId, name: String)
}

fn init(_: a) -> #(Model, Effect(Msg)) {
  // The server for a typical SPA will often serve the application to *any*
  // HTTP request, and let the app itself determine what to show. Modem stores
  // the first URL so we can parse it for the app's initial route.
  let route = case modem.initial_uri() {
    Ok(uri) -> parse_route(uri)
    Error(_) -> Index |> Public
  }

  let supaclient = supabase.create_client(supabase_url, supabase_key)

  let auth_listener =
    supabase.listen_to_auth_events(supaclient, fn(event, session, dispatch) {
      case event, session {
        supabase.InitialSession, Some(session)
        | supabase.SignedIn, Some(session)
        ->
          supabase.get_user_id(session)
          |> UserUpdateSession
          |> dispatch
        supabase.SignedOut, _ -> dispatch(UserSetAnon)
        e, s -> {
          echo #(e, s)
          Nil
        }
      }
    })

  let model = Anon(Index, PublicModel(supaclient:)) |> set_route(route)

  // We need to initialise modem in order for it to intercept links. To do that
  // we pass in a function that takes the `Uri` of the link that was clicked and
  // turns it into a `Msg`.
  let modem_effect =
    modem.init(fn(uri) {
      uri
      |> parse_route
      |> UserNavigatedTo
    })

  let effects = effect.batch([auth_listener, modem_effect])

  #(model, effects)
}

type Route {
  Public(PublicRoute)
  Private(PrivateRoute)
}

type PublicRoute {
  Index
  NotFound(uri: Uri)

  // TODO: Support redirect after login
  AuthLogin(error: Option(supabase.AuthError))
  AuthCallback
}

type PrivateRoute {
  AuthLogout

  BagView(id: BagId)
  BagEdit(id: BagId)
  BagDelete(id: BagId)
  BagAddItem(id: BagId)

  CollectionView(id: CollectionId)
  CollectionEdit(id: CollectionId)
  CollectionDelete(id: CollectionId)
  CollectionCreateBag(id: CollectionId)
  CollectionMembers(id: CollectionId)
  CollectionLeave(id: CollectionId)

  CollectionsList
  CollectionsCreate

  UserOnboard
}

// Keep in sync with parsing
fn parse_route(uri: Uri) -> Route {
  // Strip base path
  let path = case string.starts_with(uri.path, base_path) {
    False -> uri.path
    True -> string.length(base_path) |> string.drop_start(uri.path, _)
  }
  case uri.path_segments(path) {
    [] | [""] -> Index |> Public

    ["auth", "login"] -> AuthLogin(error: None) |> Public
    ["auth", "logout"] -> AuthLogout |> Private
    ["auth", "callback"] -> AuthCallback |> Public

    ["bag", id] -> BagId(id) |> BagView |> Private
    ["bag", id, "edit"] -> BagId(id) |> BagEdit |> Private
    ["bag", id, "delete"] -> BagId(id) |> BagDelete |> Private
    ["bag", id, "items", "new"] -> BagId(id) |> BagAddItem |> Private

    ["collection", id] -> CollectionId(id) |> CollectionView |> Private
    ["collection", id, "edit"] -> CollectionId(id) |> CollectionEdit |> Private
    ["collection", id, "delete"] ->
      CollectionId(id) |> CollectionDelete |> Private
    ["collection", id, "bags", "new"] ->
      CollectionId(id) |> CollectionCreateBag |> Private
    ["collection", id, "members"] ->
      CollectionId(id) |> CollectionMembers |> Private
    ["collection", id, "leave"] ->
      CollectionId(id) |> CollectionLeave |> Private

    ["collections"] -> CollectionsList |> Private
    ["collections", "new"] -> CollectionsCreate |> Private

    ["user", "onboard"] -> UserOnboard |> Private

    _ -> NotFound(uri:) |> Public
  }
}

/// Keep in sync with parsing
fn public_route_to_str(route: PublicRoute) -> String {
  base_path
  <> case route {
    Index -> "/"
    AuthLogin(_) -> "/auth/login"
    AuthCallback -> "/auth/callback"
    NotFound(_) -> "/404"
  }
}

/// Keep in sync with parsing
fn private_route_to_str(route: PrivateRoute) -> String {
  base_path
  <> case route {
    AuthLogout -> "/auth/logout"
    BagView(id:) -> "/bag/" <> id.uuid
    BagEdit(id:) -> "/bag/" <> id.uuid <> "/edit"
    BagDelete(id:) -> "/bag/" <> id.uuid <> "/delete"
    BagAddItem(id:) -> "/bag/" <> id.uuid <> "/items/new"
    CollectionView(id:) -> "/collection/" <> id.uuid
    CollectionEdit(id:) -> "/collection/" <> id.uuid <> "/edit"
    CollectionDelete(id:) -> "/collection/" <> id.uuid <> "/delete"
    CollectionCreateBag(id:) -> "/collection/" <> id.uuid <> "/bags/new"
    CollectionMembers(id:) -> "/collection/" <> id.uuid <> "/members"
    CollectionLeave(id:) -> "/collection/" <> id.uuid <> "/members/leave"
    CollectionsList -> "/collections"
    CollectionsCreate -> "/collections/new"
    UserOnboard -> "/user/onboard"
  }
}

/// Always use a valid link in hrefs but using this function
fn href_public(route: PublicRoute) -> Attribute(msg) {
  public_route_to_str(route) |> attribute.href()
}

/// Always use a valid link in hrefs but using this function
fn href_private(route: PrivateRoute) -> Attribute(msg) {
  private_route_to_str(route) |> attribute.href()
}

type Msg {
  UserNavigatedTo(route: Route)
  UserTriggerSignin
  SigninEncounterError(err: supabase.AuthError)
  UserUpdateSession(id: UserId)
  UserSetName(name: Option(String))
  UserSetAnon
}

fn get_route(model: Model) -> Route {
  case model {
    Anon(route:, ..) -> route |> Public
    LoggedIn(route:, ..) -> route
  }
}

fn set_route(old_model model: Model, to route: Route) -> Model {
  case model, route {
    Anon(..) as a, Public(destination) -> Anon(..a, route: destination)
    // TODO: Redirect after login
    Anon(..) as a, Private(_) -> Anon(..a, route: AuthLogin(error: None))
    LoggedIn(..) as l, destination -> LoggedIn(..l, route: destination)
  }
}

fn navigate(old_model model: Model, to route: Route) -> #(Model, Effect(Msg)) {
  let new_model = set_route(model, route)
  #(new_model, effect.none())
}

/// Trigger supabase login flow
fn login_start(old_state model: Model) -> #(Model, Effect(Msg)) {
  case model {
    // If the user is already signed in just redirect to the collections list
    LoggedIn(..) -> navigate(model, Private(CollectionsList))
    Anon(data: PublicModel(supaclient:), ..) -> {
      let origin = window.self() |> window.location() |> location.origin()
      let redirect = origin <> base_path <> public_route_to_str(AuthCallback)
      case uri.parse(redirect) {
        Error(_) -> #(model, effect.none())
        Ok(redirect) -> {
          let effect =
            supabase.sign_in_with_oauth(
              supaclient,
              supabase.Discord,
              redirect,
              fn(result, dispatch) {
                case result {
                  Ok(_) -> Nil
                  Error(e) -> e |> SigninEncounterError |> dispatch
                }
              },
            )
          #(model, effect)
        }
      }
    }
  }
}

/// Switch to LoggedInModel with given user
fn update_user_id(model: Model, id: UserId) -> #(Model, Effect(Msg)) {
  let get_name = fn(client) {
    supabase.get_user_name(client, id, fn(name, dispatch) {
      dispatch(UserSetName(name:))
    })
  }

  case model {
    Anon(route:, data: PublicModel(supaclient:)) -> {
      let new_model =
        LoggedIn(
          route: Public(route),
          data: LoggedInModel(supaclient:, user: UnloadedUser(id:)),
        )
      #(new_model, get_name(supaclient))
    }
    LoggedIn(route:, data:) ->
      case data.user.id == id {
        // user id has not changed, nothing to update
        True -> #(model, effect.none())
        False -> {
          let new_model =
            LoggedIn(
              route: route,
              data: LoggedInModel(
                supaclient: data.supaclient,
                user: UnloadedUser(id:),
              ),
            )
          #(new_model, get_name(data.supaclient))
        }
      }
  }
}

// TODO: We might need to start pushing when we change the route
fn logout(model: Model) -> #(Model, Effect(Msg)) {
  let new_model = case model {
    LoggedIn(route: Public(public), data: LoggedInModel(supaclient:, ..)) ->
      Anon(route: public, data: PublicModel(supaclient:))
    // redirect to index page if they're on an private route
    LoggedIn(route: Private(_), data: LoggedInModel(supaclient:, ..)) ->
      Anon(route: Index, data: PublicModel(supaclient:))
    Anon(..) as a -> a
  }
  #(new_model, effect.none())
}

/// If on the login page update the model with the given error.
/// Else do nothing.
fn show_login_error(
  model: Model,
  error: supabase.AuthError,
) -> #(Model, Effect(Msg)) {
  case get_route(model) {
    Public(AuthLogin(_)) -> #(
      set_route(model, error |> Some |> AuthLogin |> Public),
      effect.none(),
    )
    _ -> #(model, effect.none())
  }
}

/// Update user name, redirecting unnamed users to onboarding
fn update_user_name(model: Model, name: Option(String)) -> #(Model, Effect(Msg)) {
  case model {
    LoggedIn(route:, data:) ->
      case name {
        Some(name) -> #(
          LoggedIn(
            route:,
            data: LoggedInModel(..data, user: NamedUser(data.user.id, name)),
          ),
          effect.none(),
        )
        None -> #(
          LoggedIn(
            route: Private(UserOnboard),
            data: LoggedInModel(..data, user: NewUser(data.user.id)),
          ),
          effect.none(),
        )
      }
    m -> #(m, effect.none())
  }
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    SigninEncounterError(err:) -> show_login_error(model, err)
    UserNavigatedTo(route:) -> navigate(model, route)
    UserTriggerSignin -> login_start(model)
    UserUpdateSession(id) -> update_user_id(model, id)
    UserSetAnon -> logout(model)
    UserSetName(name) -> update_user_name(model, name)
  }
}

fn view(model: Model) -> Element(Msg) {
  with_header(model, case model {
    Anon(route:, data:) -> view_anon(data, route)
    LoggedIn(route:, data:) -> view_logged_in(data, route)
  })
}

fn view_anon(model: PublicModel, route: PublicRoute) {
  case route {
    Index -> view_index(model |> Anon(route:))
    AuthCallback -> view_auth_callback_anon(model)
    AuthLogin(e) -> view_login(e)
    NotFound(uri) -> view_404(uri)
  }
}

fn view_logged_in(model: LoggedInModel, route: Route) {
  case route {
    Public(route) ->
      case route {
        Index -> view_index(model |> LoggedIn(route: Public(route)))
        AuthCallback -> view_auth_callback_logged_in(model)
        AuthLogin(e) -> view_login(e)
        NotFound(uri) -> view_404(uri)
      }
    Private(route) -> todo
  }
}

fn with_header(model: Model, body: List(Element(a))) -> Element(a) {
  html.div([], [
    html.nav(
      [class("auto flex flex-row justify-between pb-2 pl-4 pr-4 pt-2")],
      case model {
        Anon(..) -> [
          html.a([href_public(AuthLogin(None))], [html.text("Sign in")]),
        ]
        LoggedIn(..) -> [
          html.div([], [
            html.a([href_private(CollectionsList)], [html.text("Collections")]),
          ]),
          html.div([], [
            html.a([href_private(AuthLogout)], [html.text("Sign out")]),
          ]),
        ]
      },
    ),
    html.hr([class("mb-2 ml-2 mr-2")]),
    html.main([class("p-2")], body),
  ])
}

fn view_index(model: Model) -> List(Element(a)) {
  [
    html.h1([class("text-xl")], [html.text("Bag of Holding")]),

    case model {
      Anon(..) ->
        html.div([], [
          html.p([], [
            html.text(
              "Welcome to the Bag of Holding, a tool to manage shared storage in Pathfinder 2e.",
            ),
          ]),
          html.p([], [
            html.a([class("text-sky-600"), href_public(AuthLogin(None))], [
              html.text("Sign in"),
            ]),
            html.text(" to get started."),
          ]),
        ])
      LoggedIn(data: LoggedInModel(..), ..) ->
        html.div([], [
          html.p([], [
            html.text(
              "Welcome to the Bag of Holding, a tool to manage shared storage in Pathfinder 2e.",
            ),
          ]),
          html.p([], [
            html.a([class("text-sky-600"), href_private(CollectionsList)], [
              html.text("View"),
            ]),
            html.text(" your collections."),
          ]),
        ])
    },
  ]
}

fn view_login(error: Option(supabase.AuthError)) -> List(Element(Msg)) {
  let std = [
    html.button([event.on_click(UserTriggerSignin)], [html.text("Sign in")]),
  ]
  case error {
    Some(err) -> [
      html.p([], [
        html.text(
          "A login error has occured: " <> supabase.get_auth_error_message(err),
        ),
      ]),
      ..std
    ]
    None -> std
  }
}

fn view_404(uri: Uri) -> List(Element(Msg)) {
  [
    html.p([], [
      html.text(
        "No page was found for '"
        <> uri.to_string(uri)
        <> "'. Would you like to ",
      ),
      html.a([class("text-sky-600"), href_public(Index)], [
        html.text("return home"),
      ]),
      html.text("?"),
    ]),
  ]
}

// Model parameter is for the sake of preventing calling the wrong function
fn view_auth_callback_anon(_model: PublicModel) -> List(Element(Msg)) {
  [
    html.p([], [
      html.text(
        "You are not logged in. If you just tried to log in something went wrong. ",
      ),
      html.a([class("text-sky-600"), href_public(Index)], [
        html.text("Return home."),
      ]),
    ]),
  ]
}

fn view_auth_callback_logged_in(_model: LoggedInModel) -> List(Element(Msg)) {
  [
    html.p([], [
      html.text("You are logged in. "),
      html.a([class("text-sky-600"), href_public(Index)], [
        html.text("Return home."),
      ]),
    ]),
  ]
}
