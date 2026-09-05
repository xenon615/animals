
use leptos::prelude::*;
use leptos_meta::Title;
use leptos_router::nested_router::Outlet;
use crate::public::parts::header::Header;

#[component]
pub fn Layout() -> impl IntoView {
    view! {
        <Title text="Animals"/>
        <body class="public-layout">
            <main>
                <Header/>
                <div class="container">
                    <Outlet/>
                </div>
            </main>
        </body>
    }
}
