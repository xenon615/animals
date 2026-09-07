use leptos::{
    prelude::*,
    // logging
};

use leptos_meta::{MetaTags, Stylesheet, provide_meta_context};
use leptos_router::{
    Lazy, StaticSegment,
    components::{ParentRoute, Route, Router, Routes},
    path,
};

use crate::{
    admin::AdminRoutes,
    public::{
        layout::Layout as PublicLayout,
        parts::{
            animals::{Animal, Animals},
            hierarchy::Hierarchy,
            page::Page,
        },
    },
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
            <App/>
        </html>
    }
}

// ---

#[component]
pub fn App() -> impl IntoView {
    provide_meta_context();
    view! {
        <Stylesheet id="animals" href="/pkg/animals.css"/>
        <Router>
            <Routes fallback= | | "Page not found.".into_view()>
                <AdminRoutes/>
                <ParentRoute path = StaticSegment("") view = PublicLayout>
                    <Route path=StaticSegment("") view=Page/>
                    <Route path=StaticSegment("/hierarchy") view=Hierarchy/>
                    <Route path=StaticSegment("/animals") view=Animals/>
                    <Route path=path!("/animals/:slug") view=Animal/>
                    <Route path=path!("/animals/genus/:slug") view=Animals/>
                    <Route path=path!("/:slug") view=Page/>
                </ParentRoute>
            </Routes>
        </Router>
    }
}
