use leptos::prelude::*;
mod footer;
mod header;
mod sidebar;
use footer::Footer;
use header::Header;
use sidebar::SideBar;

#[component]
pub fn AdminLayout(children: Children) -> impl IntoView {
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
                    {children()}
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
