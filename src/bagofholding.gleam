import bagofholding/supabase.{
  type BagId, type CollectionId, type UserId, BagId, CollectionId,
}
import gleam/bool
import gleam/javascript/promise
import gleam/list
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

// CONSTANTS -------------------------------------------------------------
// These are updated by a postprocessing script during build

const base_path = "SUBSTITUTE_BASE_PATH"

const supabase_url = "SUBSTITUTE_PUBLIC_SUPABASE_URL"

const supabase_key = "SUBSTITUTE_PUBLIC_SUPABASE_KEY"

// MAIN -------------------------------------------------------------------

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODELS ----------------------------------------------------------------

type Model {
  Anon(route: PublicRoute, supaclient: supabase.Client, data: PublicModel)
  LoggedIn(route: Route, supaclient: supabase.Client, data: LoggedInModel)
}

type PublicModel {
  PublicModel
}

type LoggedInModel {
  LoggedInModel(user: User)
}

type User {
  NewUser(id: UserId)
  UnloadedUser(id: UserId)
  NamedUser(id: UserId, name: String)
}

fn get_user_name(user: User) {
  case user {
    NewUser(..) -> "New User"
    UnloadedUser(..) -> "Profile"
    NamedUser(name:, ..) -> name
  }
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

  CollectionsList(collections: List(#(CollectionId, String)))
  CollectionsCreate

  UserOnboard
}

fn get_route(model: Model) -> Route {
  case model {
    Anon(route:, ..) -> route |> Public
    LoggedIn(route:, ..) -> route
  }
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

    ["collections"] -> CollectionsList([]) |> Private
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
    CollectionsList(_) -> "/collections"
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

type LustreUpdate =
  #(Model, Effect(Msg))

fn init(_: a) -> LustreUpdate {
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

  let #(model, restore_effect) = case route {
    Public(public) -> Anon(public, supaclient, PublicModel) |> no_effect()
    Private(private) -> #(
      Anon(Index, supaclient, PublicModel),
      effect.from(fn(dispatch) {
        promise.map(supabase.get_session(supaclient), fn(session) {
          case session {
            Ok(Some(session)) ->
              InternalRestoreRoute(session, private) |> dispatch
            _ -> Nil
          }
        })
        Nil
      }),
    )
  }

  // We need to initialise modem in order for it to intercept links. To do that
  // we pass in a function that takes the `Uri` of the link that was clicked and
  // turns it into a `Msg`.
  let modem_effect =
    modem.init(fn(uri) {
      uri
      |> parse_route
      |> UserNavigateTo
    })

  let effects = effect.batch([auth_listener, modem_effect, restore_effect])

  #(model, effects)
}

// UPDATES -------------------------------------------------------------------------

type Msg {
  // Load session and silently return to given route
  InternalRestoreRoute(session: supabase.Session, route: PrivateRoute)
  UserNavigateTo(route: Route)
  UserTriggerSignin
  SigninEncounterError(err: supabase.AuthError)
  UserUpdateSession(id: UserId)
  UserSetName(name: Option(String))
  UserSetAnon
}

fn no_effect(model: Model) -> LustreUpdate {
  #(model, effect.none())
}

fn push_route(route: Route) -> Effect(Msg) {
  modem.push(
    case route {
      Public(route) -> public_route_to_str(route)
      Private(route) -> private_route_to_str(route)
    },
    None,
    None,
  )
}

/// Updates route in the model and pushes the new page to the stack
/// 
/// Anonymous users accessing private routes are redirected to the home page.
fn update_route(old_model model: Model, to route: Route) -> LustreUpdate {
  // Abort if the route is unchanged
  use <- bool.guard(get_route(model) == route, no_effect(model))

  case model, route {
    Anon(..) as a, Public(public) -> #(
      Anon(..a, route: public),
      push_route(Public(public)),
    )
    Anon(..) as a, Private(_) -> #(
      Anon(..a, route: Index),
      push_route(Public(Index)),
    )
    LoggedIn(..) as l, route ->
      case route {
        Public(..) -> #(LoggedIn(..l, route:), push_route(route))
        Private(private) -> #(
          LoggedIn(..l, route:),
          effect.batch([push_route(route), init_page(private, model.supaclient)]),
        )
      }
  }
}

/// Load initial page data when state in route is empty
fn init_page(route: PrivateRoute, client: supabase.Client) -> Effect(Msg) {
  case route {
    CollectionsList([]) -> todo
    _ -> effect.none()
  }
}

/// If the user triggered init on a private page then we need to load
/// the session before restoring their route by rewriting history.
/// This message is triggered once the session is loaded and only affects
/// users if they're still on the home page.
/// 
/// Restoring route on public pages is handled directly in the init function
fn update_restore_route(
  model: Model,
  session: supabase.Session,
  route: PrivateRoute,
) -> LustreUpdate {
  case get_route(model) {
    Public(Index) -> {
      let #(model, name_update) =
        supabase.get_user_id(session) |> update_user_id(model, _)
      #(
        model,
        effect.batch([
          name_update,
          modem.replace(private_route_to_str(route), None, None),
        ]),
      )
    }
    _ -> no_effect(model)
  }
}

/// Trigger supabase login flow
fn update_begin_login(old_state model: Model) -> LustreUpdate {
  case model {
    // If the user is already signed in just redirect to the collections list
    LoggedIn(..) -> update_route(model, Private(CollectionsList([])))
    Anon(supaclient:, ..) -> {
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
fn update_user_id(model: Model, id: UserId) -> LustreUpdate {
  let get_name = fn(client) {
    supabase.get_user_name(client, id, fn(name, dispatch) {
      dispatch(UserSetName(name:))
    })
  }

  case model {
    Anon(route:, supaclient:, data: PublicModel) -> {
      let new_model =
        LoggedIn(
          route: Public(route),
          supaclient:,
          data: LoggedInModel(user: UnloadedUser(id:)),
        )
      #(new_model, get_name(supaclient))
    }
    LoggedIn(..) as lim ->
      case lim.data.user.id == id {
        // user id has not changed, nothing to update
        True -> #(model, effect.none())
        False -> {
          let new_model =
            LoggedIn(..lim, data: LoggedInModel(user: UnloadedUser(id:)))
          #(new_model, get_name(lim.supaclient))
        }
      }
  }
}

fn update_logout(model: Model) -> LustreUpdate {
  case model {
    LoggedIn(route: Public(public), supaclient:, data: LoggedInModel(..)) ->
      Anon(route: public, supaclient:, data: PublicModel) |> no_effect()
    // redirect to index page if they're on an private route
    LoggedIn(route: Private(_), supaclient:, ..) -> #(
      Anon(route: Index, supaclient:, data: PublicModel),
      push_route(Public(Index)),
    )
    Anon(..) as a -> a |> no_effect()
  }
}

/// If on the login page update the model with the given error.
/// Else do nothing.
fn update_show_login_error(
  model: Model,
  error: supabase.AuthError,
) -> LustreUpdate {
  case model, get_route(model) {
    Anon(..) as a, Public(AuthLogin(_)) -> #(
      // This updates the route without triggering navigate
      // it is ok because we check the route is unchanged
      // and thus the url doesn't need to change
      Anon(..a, route: AuthLogin(error: Some(error))),
      effect.none(),
    )
    _, _ -> #(model, effect.none())
  }
}

/// Update user name, redirecting unnamed users to onboarding
fn update_user_name(model: Model, name: Option(String)) -> LustreUpdate {
  case model {
    LoggedIn(data:, ..) as lim ->
      case name {
        Some(name) -> #(
          LoggedIn(
            ..lim,
            data: LoggedInModel(user: NamedUser(data.user.id, name)),
          ),
          effect.none(),
        )
        None -> #(
          LoggedIn(
            ..lim,
            route: Private(UserOnboard),
            data: LoggedInModel(user: NewUser(data.user.id)),
          ),
          effect.none(),
        )
      }
    m -> #(m, effect.none())
  }
}

fn update(model: Model, msg: Msg) -> LustreUpdate {
  case msg {
    InternalRestoreRoute(session:, route:) ->
      update_restore_route(model, session, route)
    SigninEncounterError(err:) -> update_show_login_error(model, err)
    UserNavigateTo(route:) -> update_route(model, route)
    UserTriggerSignin -> update_begin_login(model)
    UserUpdateSession(id) -> update_user_id(model, id)
    UserSetAnon -> update_logout(model)
    UserSetName(name) -> update_user_name(model, name)
  }
}

// VIEW -------------------------------------------------------------

/// Generate page state from model
/// 
/// This doesn't need access to the supabase client because all
/// api calls should be triggered by effects
fn view(model: Model) -> Element(Msg) {
  with_header(model, case model {
    Anon(route:, data:, ..) -> view_anon(data, route)
    LoggedIn(route:, data:, ..) -> view_logged_in(data, route)
  })
}

fn view_anon(model: PublicModel, route: PublicRoute) {
  case route {
    Index -> view_index_anon(model)
    AuthCallback -> view_auth_callback_anon(model)
    AuthLogin(e) -> view_login(e)
    NotFound(uri) -> view_404(uri)
  }
}

fn view_logged_in(model: LoggedInModel, route: Route) {
  case route {
    Public(route) ->
      case route {
        Index -> view_index_signed_in(model)
        AuthCallback -> view_auth_callback_logged_in(model)
        AuthLogin(e) -> view_login(e)
        NotFound(uri) -> view_404(uri)
      }
    // TODO
    Private(route) ->
      case route {
        CollectionsList(collections) -> view_collections_list(collections)
        _ -> view_404(uri.empty)
      }
  }
}

fn with_header(model: Model, body: List(Element(Msg))) -> Element(Msg) {
  html.div([], [
    html.nav(
      [class("auto flex flex-row justify-between pb-2 pl-4 pr-4 pt-2")],
      case model {
        Anon(..) -> [
          html.a([href_public(AuthLogin(None))], [html.text("Sign in")]),
        ]
        LoggedIn(data: LoggedInModel(user:), ..) -> [
          html.div([], [
            html.a([href_private(CollectionsList([]))], [
              html.text("Collections"),
            ]),
          ]),
          html.div([class("flex flex-row gap-x-2")], [
            html.span([], [html.text(get_user_name(user))]),
            html.a([href_private(AuthLogout)], [html.text("Sign out")]),
          ]),
        ]
      },
    ),
    html.hr([class("mb-2 ml-2 mr-2")]),
    html.main([class("p-2")], body),
  ])
}

fn view_index_anon(_model: PublicModel) {
  [
    h1("Bag of Holding"),
    html.div([], [
      html.p([], [
        html.text(
          "Welcome to the Bag of Holding, a tool to manage shared storage in Pathfinder 2e.",
        ),
      ]),
      html.p([], [
        a_public(AuthLogin(None), "Sign in"),
        html.text(" to get started."),
      ]),
    ]),
  ]
}

fn view_index_signed_in(_model: LoggedInModel) -> List(Element(Msg)) {
  [
    h1("Bag of Holding"),
    html.div([], [
      html.p([], [
        html.text(
          "Welcome to the Bag of Holding, a tool to manage shared storage in Pathfinder 2e.",
        ),
      ]),
      html.p([], [
        a_private(CollectionsList([]), "View"),
        html.text(" your collections."),
      ]),
    ]),
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
      a_public(Index, "return home"),
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
      a_public(Index, "Return home."),
    ]),
  ]
}

fn view_auth_callback_logged_in(_model: LoggedInModel) -> List(Element(Msg)) {
  [
    html.p([], [
      html.text("You are logged in. "),
      a_public(Index, "Return home."),
    ]),
  ]
}

fn view_collections_list(
  collections: List(#(CollectionId, String)),
) -> List(Element(Msg)) {
  [
    h1("Collections"),
    html.ul(
      [class("pb-4 pt-4 text-lg")],
      list.map(collections, fn(pair) {
        html.li([], [a_private(CollectionView(pair.0), pair.1)])
      }),
    ),
  ]
}

// VIEW HELPERS ----------------------------------------------

fn h1(text: String) -> Element(Msg) {
  html.h1([class("text-xl")], [html.text(text)])
}

fn a_public(route: PublicRoute, text: String) -> Element(Msg) {
  html.a([class("text-sky-600"), href_public(route)], [html.text(text)])
}

fn a_private(route: PrivateRoute, text: String) -> Element(Msg) {
  html.a([class("text-sky-600"), href_private(route)], [html.text(text)])
}
