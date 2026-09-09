use leptos::prelude::*;
use leptos_router::components::A;

use crate::admin::entities;
#[component]
pub fn SideBar() -> impl IntoView {
    let entities =  entities::get_list();

    view! {
            <div class="entities">
            {
                entities.into_iter().map(|e| view! {
                    <div>
                        <A href={e.slug}>{e.label}</A>
                    </div>
                }).collect_view()
            }
            </div>
    }
}
