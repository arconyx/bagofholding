import bagofholding/supabase
import gleam/string
import gleam/uri.{type Uri}
import lustre
import lustre/attribute.{type Attribute, class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem

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
  User(name: String)
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

  // TODO: Read login data if present
  let model = Anon(Index, PublicModel(supaclient:)) |> set_route(route)

  let effect =
    // We need to initialise modem in order for it to intercept links. To do that
    // we pass in a function that takes the `Uri` of the link that was clicked and
    // turns it into a `Msg`.
    modem.init(fn(uri) {
      uri
      |> parse_route
      |> UserNavigatedTo
    })

  #(model, effect)
}

type Route {
  Public(PublicRoute)
  Private(PrivateRoute)
}

type PublicRoute {
  Index
  NotFound(uri: Uri)

  // TODO: Support redirect after login
  AuthLogin
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

// TODO: Use uuid type for uuids for consistent comparison and display
type BagId {
  BagId(uuid: String)
}

type CollectionId {
  CollectionId(uuid: String)
}

fn parse_route(uri: Uri) -> Route {
  // Strip base path
  let path = case string.starts_with(uri.path, base_path) {
    False -> uri.path
    True -> string.length(base_path) |> string.drop_start(uri.path, _)
  }
  case uri.path_segments(path) {
    [] | [""] -> Index |> Public

    ["auth", "login"] -> AuthLogin |> Public
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

/// We also need a way to turn a Route back into a an `href` attribute that we
/// can then use on `html.a` elements. It is important to keep this function in
/// sync with the parsing, but once you do, all links are guaranteed to work!
///
fn href_public(route: PublicRoute) -> Attribute(msg) {
  let url =
    base_path
    <> case route {
      Index -> "/"
      AuthLogin -> "/auth/login"
      AuthCallback -> "/auth/callback"
      NotFound(_) -> "/404"
    }

  attribute.href(url)
}

fn href_private(route: PrivateRoute) -> Attribute(msg) {
  let url =
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

  attribute.href(url)
}

type Msg {
  UserNavigatedTo(route: Route)
  UserTriggerLogin
  UserLoginAs(user: User)
}

fn set_route(old_model model: Model, to route: Route) -> Model {
  case model, route {
    Anon(..) as a, Public(destination) -> Anon(..a, route: destination)
    // TODO: Redirect after login
    Anon(..) as a, Private(_) -> Anon(..a, route: AuthLogin)
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
    Anon(..) -> #(
      model,
      effect.from(fn(dispatch) {
        // TODO: Actual login logic
        dispatch(UserLoginAs(User(name: "Test")))
      }),
    )
  }
}

/// Switch to LoggedInModel with given user
fn login_complete(model: Model, user: User) -> #(Model, Effect(Msg)) {
  let #(route, supaclient) = case model {
    Anon(route:, data: PublicModel(supaclient:)) -> #(Public(route), supaclient)
    LoggedIn(route:, data: LoggedInModel(supaclient:, ..)) -> #(
      route,
      supaclient,
    )
  }

  #(
    LoggedInModel(supaclient:, user:) |> LoggedIn(route:, data: _),
    effect.none(),
  )
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserNavigatedTo(route:) -> navigate(model, route)
    UserTriggerLogin -> login_start(model)
    UserLoginAs(user:) -> login_complete(model, user)
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
    AuthCallback -> todo
    AuthLogin -> view_login()
    NotFound(uri) -> view_404(uri)
  }
}

fn view_logged_in(model: LoggedInModel, route: Route) {
  case route {
    Public(route) ->
      case route {
        Index -> view_index(model |> LoggedIn(route: Public(route)))
        AuthCallback -> todo
        AuthLogin -> view_login()
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
          html.a([href_public(AuthLogin)], [html.text("Sign in")]),
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
            html.a([class("text-sky-600"), href_public(AuthLogin)], [
              html.text("Sign in"),
            ]),
            html.text(" to get started."),
          ]),
        ])
      LoggedIn(data: LoggedInModel(user:, ..), ..) ->
        html.div([], [
          html.p([], [
            html.text(
              "Welcome, "
              <> user.name
              <> ", to the Bag of Holding, a tool to manage shared storage in Pathfinder 2e.",
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

fn view_login() -> List(Element(Msg)) {
  [
    html.button([event.on_click(UserTriggerLogin)], [html.text("Sign in")]),
  ]
}

fn view_404(uri: Uri) -> List(Element(Msg)) {
  [
    html.p([], [
      html.text(
        "No page was found for '"
        <> uri.to_string(uri)
        <> "'. Would you like to ",
      ),
      html.a([href_public(Index)], [html.text("return home")]),
      html.text("?"),
    ]),
  ]
}
