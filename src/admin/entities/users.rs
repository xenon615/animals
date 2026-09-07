use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};

#[derive(Clone, Default)]
pub struct UsersRoute;
#[lazy_route]
impl LazyRoute for UsersRoute {
    fn data() -> Self {
        Self
    }
    fn view(this: Self) -> AnyView {
        view! {
            "Lazy Users"
        }
        .into_any()
    }
}
