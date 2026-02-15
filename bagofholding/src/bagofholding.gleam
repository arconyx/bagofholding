import gleam/int
import gleam/string
import gleam/uri.{type Uri}
import lustre
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(route: Route)
}

fn init(_: a) -> #(Model, Effect(Msg)) {
  // The server for a typical SPA will often serve the application to *any*
  // HTTP request, and let the app itself determine what to show. Modem stores
  // the first URL so we can parse it for the app's initial route.
  let route = case modem.initial_uri() {
    Ok(uri) -> parse_route(uri)
    Error(_) -> Index
  }

  let model = Model(route:)

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
  Index

  AuthLogin
  AuthLogout
  AuthCallback

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

  NotFound(uri: Uri)
}

// TODO: Use uuid type for uuids for consistent comparison and display
type BagId {
  BagId(uuid: String)
}

type CollectionId {
  CollectionId(uuid: String)
}

fn parse_route(uri: Uri) -> Route {
  // TODO: Base dir
  case uri.path_segments(uri.path) {
    [] | [""] -> Index

    ["auth", "login"] -> AuthLogin
    ["auth", "logout"] -> AuthLogout
    ["auth", "callback"] -> AuthCallback

    ["bag", id] -> BagId(id) |> BagView
    ["bag", id, "edit"] -> BagId(id) |> BagEdit
    ["bag", id, "delete"] -> BagId(id) |> BagDelete
    ["bag", id, "items", "new"] -> BagId(id) |> BagAddItem

    ["collection", id] -> CollectionId(id) |> CollectionView
    ["collection", id, "edit"] -> CollectionId(id) |> CollectionEdit
    ["collection", id, "delete"] -> CollectionId(id) |> CollectionDelete
    ["collection", id, "bags", "new"] -> CollectionId(id) |> CollectionCreateBag
    ["collection", id, "members"] -> CollectionId(id) |> CollectionMembers
    ["collection", id, "leave"] -> CollectionId(id) |> CollectionLeave

    ["collections"] -> CollectionsList
    ["collections", "new"] -> CollectionsCreate

    ["user", "onboard"] -> UserOnboard

    _ -> NotFound(uri:)
  }
}

/// We also need a way to turn a Route back into a an `href` attribute that we
/// can then use on `html.a` elements. It is important to keep this function in
/// sync with the parsing, but once you do, all links are guaranteed to work!
///
fn href(route: Route) -> Attribute(msg) {
  let url = case route {
    Index -> "/"
    AuthLogin -> "/auth/login"
    AuthLogout -> "/auth/logout"
    AuthCallback -> "/auth/callback"
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
    NotFound(_) -> "/404"
  }

  attribute.href(url)
}

type Msg {
  UserNavigatedTo(route: Route)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserNavigatedTo(route:) -> #(Model(route:), effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  html.text(model.route |> string.inspect)
}
