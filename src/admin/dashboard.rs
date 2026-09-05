use leptos::{
    leptos_dom::{
        helpers::window,
        // logging::console_log
    },
        prelude::*,
        task::spawn_local
};

use crate::backend::create_user;
use crate::admin::parts::{
    header::Header,
    footer::Footer
};

#[component]
pub fn DashBoard() -> impl IntoView  {
    view! {
        <div class="wrapper">
            <div class="header">
                <div class="inner">
                    <Header/>
                </div>
            </div>

            <aside class="sidebar">
                <div class="inner">
                    sidebar
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
}

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
