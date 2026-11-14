use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};

#[derive(Clone, Default)]
pub struct DashBoardRoute;

#[lazy_route]
impl LazyRoute for DashBoardRoute {
    fn data() -> Self {
        Self
    }
    fn view(this: Self) -> AnyView {
        view! {
            <DashBoard/>
        }
        .into_any()
    }
}


#[island]
fn DashBoard() -> impl IntoView {
    view! {
        "Lazy Dashboard"
    }
}
