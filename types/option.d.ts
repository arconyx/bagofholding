declare module "*/option.mjs" {
    export class Some<T> {
        constructor(value: T)
    }

    export class None { }

    export type Option$<T> = Some<T> | None

    export function Option$Some<T>(value: T): Option$<T>
    export function Option$None<T>(): Option$<T>
}