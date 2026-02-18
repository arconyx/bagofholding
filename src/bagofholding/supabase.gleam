import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option}
import gleam/result
import gleam/uri
import lustre/effect

pub type Client

// TODO: Use uuid type for uuids for consistent comparison and display
pub type BagId {
  BagId(uuid: String)
}

pub type CollectionId {
  CollectionId(uuid: String)
}

pub type UserId {
  UserId(uuid: String)
}

/// Create a new client for use in the browser using the
/// supplied database url and publisable key.
/// 
/// Uses the default options. Don't pass a secret key!
/// 
/// See https://supabase.com/docs/reference/javascript/initializing
/// for details.
@external(javascript, "./supabase_ffi.ts", "create_client")
pub fn create_client(url: String, key: String) -> Client

@external(javascript, "@supabase/supabase-js", "Session")
pub type Session

pub type AuthChangeEvent {
  InitialSession
  PasswordRecovery
  SignedIn
  SignedOut
  TokenRefeshed
  UserUpdated
  MFAChallengeVerified
}

@external(javascript, "@supabase/supabase-js", "Subscription")
type AuthSubscription

/// Register a callback for when the event state changes
@external(javascript, "./supabase_ffi.ts", "register_auth_state_listener")
fn register_auth_state_listener(
  client: Client,
  callback: fn(String, Option(Session)) -> Nil,
) -> AuthSubscription

/// Register a listener for auth state changes that can dispatch a message.
/// 
/// Supabase recommends:
/// - Events are emitted across tabs to keep your application's UI up-to-date.
/// Some events can fire very frequently, based on the number of tabs open.
/// Use a quick and efficient callback function, and defer or debounce as many
/// operations as you can to be performed outside of the callback.
/// - Avoid using async functions as callbacks.
/// - Do not use other Supabase functions in the callback function.
/// 
/// So basically do the minimum amount of work we can before dispatching a message.
pub fn listen_to_auth_events(
  client: Client,
  on_event: fn(AuthChangeEvent, Option(Session), fn(a) -> Nil) -> Nil,
) -> effect.Effect(a) {
  use dispatch <- effect.from()
  let _ =
    register_auth_state_listener(client, fn(event_str, session) {
      let event = case event_str {
        "INITIAL_SESSION" -> InitialSession |> Ok
        "SIGNED_IN" -> SignedIn |> Ok
        "SIGNED_OUT" -> SignedOut |> Ok
        "PASSWORD_RECOVERY" -> PasswordRecovery |> Ok
        "MFA_CHALLENGE_VERIFIED" -> MFAChallengeVerified |> Ok
        _ -> Error(Nil)
      }
      case event {
        Ok(event) -> on_event(event, session, dispatch)
        Error(Nil) -> Nil
      }
    })
  Nil
}

pub type OAuthProviders {
  Discord
}

@external(javascript, "@supabase/supabase-js", "AuthError")
pub type AuthError

type OAuthResponse

pub fn sign_in_with_oauth(
  client client: Client,
  provider provider: OAuthProviders,
  redirect_to url: uri.Uri,
  then callback: fn(Result(Nil, AuthError), fn(a) -> Nil) -> Nil,
) -> effect.Effect(a) {
  use dispatch <- effect.from()
  let provider_str = case provider {
    Discord -> "discord"
  }
  let login_attempt =
    sign_in_with_provider(client, provider_str, uri.to_string(url))
  promise.map(login_attempt, fn(response) {
    response
    |> result.replace(Nil)
    |> callback(dispatch)
  })
  Nil
}

@external(javascript, "./supabase_ffi.ts", "sign_in_with_provider")
fn sign_in_with_provider(
  client: Client,
  provider: String,
  callback_url: String,
) -> Promise(Result(OAuthResponse, AuthError))

@external(javascript, "./supabase_ffi.ts", "get_auth_error_message")
pub fn get_auth_error_message(error: AuthError) -> String

/// Only use this on the client
@external(javascript, "./supabase_ffi.ts", "get_session")
pub fn get_session(
  client: Client,
) -> Promise(Result(Option(Session), AuthError))

@external(javascript, "./supabase_ffi.ts", "get_user_id")
pub fn get_user_id(session: Session) -> UserId

@external(javascript, "@supabase/supabase-js", "PostgrestError")
pub type PostgrestError

@external(javascript, "./supabase_ffi.ts", "get_user_name")
fn get_user_name_unwrapped(
  client: Client,
  user_id: String,
) -> Promise(Result(Option(String), PostgrestError))

/// This makes a database query!
pub fn get_user_name(
  client: Client,
  user_id: UserId,
  then: fn(Option(String), fn(a) -> Nil) -> Nil,
) -> effect.Effect(a) {
  use dispatch <- effect.from()
  {
    use name <- promise.map(get_user_name_unwrapped(client, user_id.uuid))
    case name {
      Ok(name) -> then(name, dispatch)
      Error(_e) -> Nil
    }
  }
  Nil
}
