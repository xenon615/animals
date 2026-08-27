use leptos::{
    prelude::*,
};
use leptos_router::{
     components::A,  hooks::{use_params_map},
};

use crate::backend:: {Creature, ListParams, CreatureBrief, get_creature, get_creatures_list};
#[component]
pub fn  Animals() -> impl IntoView {
    let params = use_params_map();

    let arg = move || params.with(|p|
        match p.get("slug") {
            Some(slug) => ListParams::Genus(slug),
            None => ListParams::Empty
        }
    );

    let cl_res = Resource::new(| | (), move | _ |get_creatures_list(arg()));

    view! {
        <h1 class="page-title">"Animals"</h1>
            <div class="list-container">
                <Transition  fallback=move || view! { <p>"Loading..."</p> }
                >
                    {
                        move || {
                            match cl_res.get() {
                                None => view! {}.into_any(),
                                Some(Err(e)) => view! {{e.to_string()}}.into_any(),
                                Some(Ok(creatures)) => {
                                    creatures.into_iter().map(| creature | view! {<CreatureTile creature/>}).collect_view()
                                }
                                .into_any(),
                            }
                        }
                    }
                </Transition>
            </div>
    }
}

// ---

#[component]
pub fn CreatureTile(creature: CreatureBrief) -> impl IntoView {
    let image_url = move ||  {
            match creature.image.clone() {
                None => "".to_string(),
                Some(url) => {
                    let cropped = &url[2..].to_string();
                    format!("url(/media/images/{})",cropped)
                }
            }
    };

    view! {
            <div
                class="tile"
                style:background-image= move || image_url()
            >
                <A attr:class="stretched-link" href= format!("/animals/{}", creature.slug)>
                    {creature.name}
                </A>
            </div>

    }
}

// ---

#[component]
pub fn Animal() -> impl IntoView {
    let params = use_params_map();
    let slug = move || params.with(|p| p.get("slug").unwrap_or_default());
    let creature_res = Resource::new(| | (), move | _ |get_creature(slug()));
    view! {
        <Transition  fallback=move || view! { <p>"Loading..."</p> }
        >
            {
                move || {
                    match creature_res.get() {
                        None => view! {}.into_any(),
                        Some(Err(e)) => view! {{e.to_string()}}.into_any(),
                        Some(Ok(creature)) =>  view! {<AnimalSingle creature/>}.into_any(),
                    }
                }
            }
        </Transition>
    }
}

// ---

#[component]
fn AnimalSingle(creature: Creature) -> impl IntoView {
    view! {
        <div class="creature-container">
            <h1 class="page-title">
                {creature.name}
            </h1>
            <div class="subtitle">
                <h3>{creature.scientific_name}</h3>
                <div class="genus-name">
                    <A href= format!("/animals/genus/{}", creature.genus_slug)>
                        {creature.genus_name}
                    </A>
                </div>
            </div>

            <div class="gallery">
                {
                     creature.images.unwrap_or_default()
                        .split(",")
                        .into_iter()
                        .map(|url| {
                            let cropped = &url[2..].to_string();
                            view! {
                                <img src= format!("/media/images/{}",cropped) />
                            }
                        })
                        .collect_view()
                }
            </div>
        </div>
    }
}
