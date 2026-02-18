import { AuthChangeEvent, AuthError, createClient, PostgrestError, Provider, Session, Subscription, SupabaseClient, User } from "@supabase/supabase-js";
import { Option$, Option$None, Option$Some } from "../../gleam_stdlib/gleam/option.mjs"
import { Result$Error, Result$Ok, Result } from "../../gleam_stdlib/gleam.mjs"
// @ts-expect-error
import { map as map_untyped } from "../../gleam_stdlib/gleam/result.mjs"
import type { Database } from "../../types/supabase_database"
import { UserId$UserId, type UserId } from "./supabase.mjs"

type Client = SupabaseClient<Database>

// Create supabase client with default options
export function create_client(url: string, key: string): Client {
    return createClient(url, key)
}

export function register_auth_state_listener(client: Client, callback: (event: AuthChangeEvent, session: Option$<Session>) => void): Subscription {
    return client.auth.onAuthStateChange((event, session) => {
        callback(event, wrap_option(session))
    }).data.subscription
}

export async function sign_in_with_provider(client: Client, provider: Provider, callback_url: string): Promise<Result<{ provider: Provider, url: String }, AuthError>> {
    const obj = await client.auth.signInWithOAuth({
        provider: provider,
        options: {
            redirectTo: callback_url
        }
    });
    return wrap_result(obj);
}

function wrap_option<T>(value: T | null): Option$<T> {
    if (value === null || value === undefined) {
        return Option$None()
    } else {
        return Option$Some(value)
    }
}

function wrap_result<D, E>(obj: { data: D, error: null } | { data: null, error: E } | { data: D, error: E }): Result<D, E> {
    const { data, error } = obj
    if (error === null) {
        return Result$Ok(data)
    } else {
        return Result$Error(error)
    }
}

/// This wraps Gleam's `result.map` because it getting it to be typed
/// in a seperate type declaration is more trouble than it should be
function map<D, E, N>(r: Result<D, E>, fun: (arg0: D) => N): Result<N, E> {
    return map_untyped(r, fun)
}

/**
 * This is only secure on the client I think.
 * 
 * May return `Option$None` if the user is not signed in.
 * @param client Supabase client
 */
export async function get_session(client: Client): Promise<Result<Option$<Session>, AuthError>> {
    const query = await client.auth.getSession()
    let result = wrap_result(query)
    return map(result, (d) => { return wrap_option(d.session) })
}

export function get_user_id(session: Session): UserId {
    return UserId$UserId(session.user.id)
}

/**
 * Gets the name of the user logged into the session
 * 
 * The empty string is None
 * @param client 
 * @param user_id 
 * @returns 
 */
export async function get_user_name(client: Client, user_id: string): Promise<Result<Option$<string>, PostgrestError>> {
    const query = await client.from("players").select("name").eq('id', user_id).limit(1).single()
    let r = wrap_result(query)
    return map(r, (obj) => {
        const name = obj.name
        if (name.length === 0) {
            return Option$None()
        } else {
            return Option$Some(name)
        }
    })
}

export function get_error_message(err: AuthError): string {
    return err.message
}