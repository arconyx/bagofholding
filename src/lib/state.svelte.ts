import type { User } from "@supabase/supabase-js";

export interface UserState {
    user: User | null
    name: string
}

export const userState: UserState = $state({ user: null, name: "Anon" })