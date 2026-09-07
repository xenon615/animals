use leptos::prelude::*;
use crate::backend::Logout;
#[component]
pub fn Header () -> impl IntoView {
    view! {
        <LogOut/>
    }
}

#[island]
fn LogOut() -> impl IntoView {
    let logout_action = ServerAction::<Logout>::new();
    let value = logout_action.value();
    Effect::new( move | | {
        if value.get().is_some() {
            let _= window().location().reload();
        }
    });
    view! {
        <button on:click=move |_| { logout_action.dispatch(Logout {}); }>
            "Log Out"
        </button>
    }
}
