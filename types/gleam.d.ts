declare module "*/gleam.mjs" {
    export interface Result<T, E> { }

    export const Result: {
        new <T, E>(): Result<T, E>
    }

    export class Ok<T, E> extends Result<T, E> {
        constructor(value: T)
    }

    export class Error<T, E> extends Result<T, E> {
        constructor(value: E)
    }

    export function Result$Ok<T, E>(value: T): Result<T, E>;
    export function Result$Error<T, E>(error: E): Result<T, E>;
    export function Result$isError<T, E>(result: Result<T, E>): boolean;
    export function Result$isOk<T, E>(result: Result<T, E>): boolean;
    export function Result$Ok$0<T, E>(result: Result<T, E>): T | undefined;
    export function Result$Error$0<T, E>(result: Result<T, E>): E | undefined;

    export function map<T, E, N>(result: Result<T, E>, fun: (value: T) => N): Result<N, E>
}