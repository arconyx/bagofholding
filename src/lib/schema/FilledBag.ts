import type { Tables } from "$lib/supabase";

export interface FilledBag extends Tables<"bags"> {
    items: Tables<'items'>[];
}
