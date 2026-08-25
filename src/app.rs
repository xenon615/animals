use leptos:: {
    prelude::*,
    // logging
};

use leptos_meta::{provide_meta_context, MetaTags, Stylesheet, Title};
use leptos_router::{
    StaticSegment, components::{A, Route, Router, Routes}, hooks::{use_params_map}, path,
};

use crate::{
    parts::{
        header::*, hierarchy::Hierarchy, page::Page,animals::{Animals,Animal}
    }
};


pub fn shell(options: LeptosOptions) -> impl IntoView {
    view! {
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <AutoReload options=options.clone() />
                <HydrationScripts options islands=true/>
                <MetaTags/>
            </head>
            <body>
                <App/>
            </body>
        </html>
    }
}

// ---

#[component]
pub fn App() -> impl IntoView {
    // logging::log!("where do I run?");
    provide_meta_context();
    view! {
        <Stylesheet id="leptos" href="/pkg/animals.css"/>
        <Title text="Animals"/>

        <Router>
            <Header/>
            <main>
                <div class="container">
                    <Routes fallback=|| "Page not found.".into_view()>
                        <Route path=StaticSegment("/hierarchy") view=Hierarchy/>
                        <Route path=StaticSegment("/animals") view=Animals/>
                        <Route path=path!("/animals/:slug") view=Animal/>
                        <Route path=path!("/animals/genus/:slug") view=Animals/>
                        <Route path=StaticSegment("") view=Page/>
                        <Route path=path!("/:slug") view=Page/>
                    </Routes>
                </div>
            </main>
        </Router>

    }
}

// ---
