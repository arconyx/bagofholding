import type { User } from "@supabase/supabase-js";

export interface UserState {
    user: User | null
}

export const userState: UserState = $state({ user: null })