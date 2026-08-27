use leptos::prelude::*;
use leptos_router::{components::A, hooks::use_location};
#[component]
pub fn Header() -> impl IntoView {
    view! {
        <div class="header">
            <div class= "side">
                <div>Something Left</div>
            </div>
            <div class= "middle">
                <Menu/>
            </div>
            <div class= "side">Something Right</div>
        </div>
    }
}

// ---

#[component]
pub fn Menu() ->impl IntoView {
    // let location = use_location();
    let routes = vec![("", "Home"), ("animals", "Animals"), ("hierarchy", "Hierarchy"), ("about", "About") ];

    view! {
        <nav class="menu">
            {
                routes.into_iter().map(|r| view! {
                    <A href= move || format!("/{}", r.0)>{r.1}</A>
                }).collect_view()
            }
        </nav>
    }
}
