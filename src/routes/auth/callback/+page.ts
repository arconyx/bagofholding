import { redirect } from '@sveltejs/kit';
import type { PageLoad } from './$types';


export const load: PageLoad = async ({ params, parent }) => {

    if ("code" in params) {
        const code = params.code as string;

        const { supabase } = await parent();
        const { error } = await supabase.auth.exchangeCodeForSession(code)

        if (!error) {
            if ("next" in params) {
                const next = params.next as string
                throw redirect(303, `/${next.slice(1)}`);
            }

        }
    }

    throw redirect(303, '/'); // TODO: Redirect somewhere helpful
};