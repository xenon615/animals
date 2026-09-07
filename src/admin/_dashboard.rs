use leptos::{
    // leptos_dom:: logging::console_log,
    prelude::*,
    task::spawn_local,
};
use leptos_router::hooks::use_location;
use leptos_router::{LazyRoute, lazy_route};

use crate::admin::parts::{footer::Footer, header::Header, sidebar::SideBar};
use crate::backend::create_user;

#[derive(Clone, Default)]
pub struct AdminDashBoardRoute;

#[lazy_route]
impl LazyRoute for AdminDashBoardRoute {
    fn data() -> Self {
        Self
    }
    fn view(this: Self) -> AnyView {
        view! {
                <div class="wrapper">
                    <div class="header">
                        <div class="inner">
                            <Header/>
                        </div>
                    </div>

                    <aside class="sidebar">
                        <div class="inner">
                            <SideBar/>
                        </div>
                    </aside>
                    <main class="content">
                        <div class="inner">
                            content
                        </div>
                    </main>

                    <div class="footer">
                        <div class="inner">
                            <Footer/>
                        </div>
                    </div>
                </div>
        }
        .into_any()
    }
}
// #[component]
// pub fn DashBoard() -> impl IntoView {
//     view! {
//         <div class="wrapper">
//             <div class="header">
//                 <div class="inner">
//                     <Header/>
//                 </div>
//             </div>

//             <aside class="sidebar">
//                 <div class="inner">
//                     sidebar
//                 </div>
//             </aside>
//             <main class="content">
//                 <div class="inner">
//                     content
//                 </div>
//             </main>

//             <div class="footer">
//                 <div class="inner">
//                     <Footer/>
//                 </div>
//             </div>
//         </div>
//     }
// }

#[island]
fn DummyCreateUserButton() -> impl IntoView {
    view! {
        <button
            on:click = move |_| {
                spawn_local(async move {
                    let _ = create_user("admin".to_string(), "yebanunzad".to_string()).await;
                });
            }
        >
            Create Admin User
        </button>
    }
}
