use leptos:: {
    prelude::*,
    // logging
};

use leptos_meta::{provide_meta_context, MetaTags, Stylesheet, Title};
use leptos_router::{
    StaticSegment, components::{Route, Router, Routes, ParentRoute}, path, nested_router::Outlet
};

use crate::{
    admin::dashboard::DashBoard,
    public:: parts::{
        animals::{Animal, Animals}, header::*, hierarchy::Hierarchy, page::Page
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
                <ParentRoute path = StaticSegment("/admin") view = AdminLayout>
                    <Route  path = StaticSegment("") view = DashBoard/>
                </ParentRoute>
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

// ---

#[component]
fn AdminLayout() -> impl IntoView {
    view! {
        <Title text="Animals Admin"/>
        <body class="admin-layout">
            <main>
                <Outlet/>
            </main>
        </body>
    }
}

// ---

#[component]
fn PublicLayout() -> impl IntoView {
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
