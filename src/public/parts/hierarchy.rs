
use leptos::{
    // leptos_dom::logging::console_log,
    prelude::*
};
use serde::{Deserialize, Serialize};
use crate::backend::{get_hierarchy,  Term};


#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
struct Parent {
    id: i32,
    subtitle: String
}


#[island]
pub fn Hierarchy() -> impl IntoView {
    let grandpas = RwSignal::new(vec![Parent{id: 1 , subtitle: "Animalia ( kingdom )".to_string()}]);
    let terms_r = Resource::new(
        move | | grandpas.get().last().unwrap().id, | c | get_hierarchy(c)
    );
    let subtitle = move || grandpas.get().last().unwrap().subtitle.clone();
    view! {
        <h1 class="page-title">Hierarchy</h1>
        <div class="subtitle">
            <h3>{subtitle}</h3>
            {
                move | | if grandpas.get().len() > 1 {
                        Some(view! {
                            <div class="back">
                                <a on:click = move |_|  {
                                        grandpas.update(|u|   u.truncate(u.len() - 1))
                                    }
                                >
                                    Back
                                </a>
                            </div>
                        })
                } else {
                    None
                }
            }

        </div>
        <div class="list-container">
            <Transition  fallback=move || view! { <p>"Loading..."</p> }
            >
                {
                    move || {
                        match terms_r.get() {
                            None => view! {}.into_any(),
                            Some(Err(e)) => view! {{e.to_string()}}.into_any(),
                            Some(Ok(terms)) =>  terms.into_iter().map(| term | view! {<TermTile term grandpas/>}).collect_view().into_any(),
                        }
                    }
                }
            </Transition>
        </div>
    }
}

// ---

#[island]
fn TermTile(
    term: Term, grandpas : RwSignal<Vec<Parent>> ) -> impl IntoView {
    let image_url = move ||  {
        match term.image.clone() {
            None => "".to_string(),
            Some(url) => {
                let cropped = &url[2..].to_string();
                format!("url(/media/images/{})",cropped)
            }
        }
    };

    let subtitle = format!("{}( {} )",term.name.clone(), term.cat_name);
    let label  =  format!("{}-{}-{}", term.name.clone(), term.parent_id, term.id);
    view! {
        <div class="tile clickable"
            style:background-image= move || image_url()
            on:click = move |_| {
                if term.hierarchy < 5  {
                    grandpas.update(|u|  u.push(Parent {id: term.id, subtitle: subtitle.clone()}))
                } else {
                       document().location().unwrap().set_href(&format!("/animals/genus/{}", term.slug.clone())).unwrap()
                }
            }
        >
            {label}
        </div>
    }
}
