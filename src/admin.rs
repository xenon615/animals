pub mod entities;
pub mod layout;

use leptos::prelude::*;
use leptos_meta::Title;
use leptos_router::{
    Lazy, LazyRoute, MatchNestedRoutes, StaticSegment,
    any_nested_route::IntoAnyNestedRoute,
    components::{Outlet, ParentRoute, Route},
    lazy_route,
};

use self::entities::{dashboard::DashBoardRoute, users::UsersRoute};
use crate::backend::{Login, get_current_user};
use layout::AdminLayout;

#[component(transparent)]
pub fn AdminRoutes() -> impl MatchNestedRoutes + Clone {
    view! {
        <ParentRoute path = StaticSegment("/admin") view = {Lazy::<AdminRoute>::new()}>
            <Route path= StaticSegment("") view ={Lazy::<DashBoardRoute>::new()} />
            <Route path= StaticSegment("/users") view = {Lazy::<UsersRoute>::new()} />
        </ParentRoute>
    }
    .into_inner()
    .into_any_nested_route()
}

// ---

#[derive(Clone, Default)]
pub struct AdminRoute;

#[lazy_route]
impl LazyRoute for AdminRoute {
    fn data() -> Self {
        Self
    }
    fn view(this: Self) -> AnyView {
        let is_user_logged_in = Resource::new(|| (), move |_| get_current_user());
        view! {
            <Title text="Animals Admin"/>
            <body class="admin-layout">
                <main>
                    <Transition  fallback=move || view! { <p>"Loading..."</p> }
                    >
                        {
                            move || {
                                match is_user_logged_in.get() {
                                    None  | Some(Err(_)) => view! {<span>Error</span>}.into_any(),
                                    | Some(Ok(b)) if !b => view! {
                                        <LoginForm/>
                                    }.into_any(),
                                    _ => view! {
                                        <AdminLayout>
                                            <Outlet/>
                                        </AdminLayout>

                                    }.into_any()
                                }
                            }
                        }
                    </Transition>
                </main>
            </body>
        }
        .into_any()
    }
}

// ---

#[component]
fn LoginForm() -> impl IntoView {
    let login = ServerAction::<Login>::new();
    view! {
        <ActionForm action=login>
            <input type="text" name="username" value="admin" placeholder="Username" required/>
            <input type="password" name="password" value="yebanunzad" placeholder="Password" required/>
            <button type="submit">"Log In"</button>
        </ActionForm>
    }
}

// ---

// #[island]
// fn DummyCreateUserButton() -> impl IntoView {
//     view! {
//         <button
//             on:click = move |_| {
//                 spawn_local(async move {
//                     let _ = create_user("admin".to_string(), "yebanunzad".to_string()).await;
//                 });
//             }
//         >
//             Create Admin User
//         </button>
//     }
// }
