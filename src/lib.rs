pub mod app;
pub mod backend;
pub mod public;
pub mod admin;

#[cfg(feature = "hydrate")]
#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
    // use crate::app::*;
    console_error_panic_hook::set_once();
    // leptos::mount::hydrate_body(App);
    leptos::mount::hydrate_islands();
}
