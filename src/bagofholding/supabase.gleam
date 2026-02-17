pub type Client

/// Create a new client for use in the browser using the
/// supplied database url and publisable key.
/// 
/// Uses the default options. Don't pass a secret key!
/// 
/// See https://supabase.com/docs/reference/javascript/initializing
/// for details.
@external(javascript, "./supabase_ffi.ts", "create_client")
pub fn create_client(url: String, key: String) -> Client
