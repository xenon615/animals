use leptos::prelude::*;
use crate::backend::{Page, get_page};
use leptos_router::hooks::use_params_map;
#[component]
pub fn Page() -> impl IntoView {
    let params = use_params_map();
    let slug = move || params.with(|p| p.get("slug").unwrap_or("home".to_string()));
    let page_res = Resource::new(| | (), move | _ |get_page(slug()));

    view! {
        <Transition
            fallback = move || view! {<p>"Loading ... "</p>}
        >
            {
                move || {
                    match page_res.get() {
                        None => None,
                        Some(Err(e)) => Some(view! {{e.to_string()}}.into_any()),
                        Some(Ok(page)) =>  Some(view! {<PageTemplate page/>}.into_any()),
                    }
                }
            }

        </Transition>
    }
}

#[component]
fn PageTemplate(page: Page) -> impl IntoView {
    view! {
        <h1 class="page-title">{page.title.clone()}</h1>
        <div class="page-content" inner_html= {page.content.clone()}/>
    }
}
