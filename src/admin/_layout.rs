use leptos::prelude::*;
use leptos_meta::Title;
use leptos_router::{
    Lazy, LazyRoute, MatchNestedRoutes, StaticSegment,
    any_nested_route::IntoAnyNestedRoute,
    components::{ParentRoute, Route},
    lazy_route,
    nested_router::Outlet,
    path,
};

use crate::{
    admin::dashboard::AdminDashBoardRoute,
    backend::{Login, get_current_user},
};

// #[component]
// pub fn Layout() -> impl IntoView {
// let is_user_logged_in = Resource::new(| | (), move | _ | get_current_user());
//     view! {
//         <Title text="Animals Admin"/>
//         <body class="admin-layout">
//             <main>
//                 <Transition  fallback=move || view! { <p>"Loading..."</p> }
//                 >
//                     {
//                         move || {
//                             match is_user_logged_in.get() {
//                                 None  | Some(Err(_)) => view! {<span>Error</span>}.into_any(),
//                                 | Some(Ok(b)) if !b => view! {
//                                     <LoginForm/>
//                                 }.into_any(),
//                                 _ => view! {<Outlet/>}.into_any()
//                             }
//                         }
//                     }
//                 </Transition>
//             </main>
//         </body>
//     }
// }

#[derive(Clone, Default)]
pub struct AdminLayoutRoute;

#[lazy_route]
impl LazyRoute for AdminLayoutRoute {
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
                                    _ => view! {<Outlet/>}.into_any()
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

#[component(transparent)]
pub fn AdminRoutes() -> impl MatchNestedRoutes + Clone {
    view! {
        // <Route path= StaticSegment("") view = {Lazy::<AdminDashBoardRoute>::new()} />
        <Route path= path!("*") view = {Lazy::<AdminDashBoardRoute>::new()} />
    }
    .into_inner()
    .into_any_nested_route()
}

#[component]
fn Users() -> impl IntoView {
    view! {}
}
