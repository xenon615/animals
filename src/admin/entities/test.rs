
use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};
#[cfg(feature = "hydrate")]
use form_forge::{FForm, FormForge, serde_json};

#[derive(Clone, Default)]
pub struct TestRoute;

#[lazy_route]
impl LazyRoute for TestRoute {
    fn data() -> Self {
        Self
    }
    fn view(_this: Self) -> AnyView {
        view! {
            <Panel/>
        }
        .into_any()
    }
}

#[island]
fn Panel() -> impl IntoView {
    let id_sig:RwSignal<Option<i32>> = RwSignal::new(None);
    view! {
        <Form id_sig/>
        <button
            on:click = move |_| {id_sig.write().replace(1);}
        >
            "Click Me"
        </button>
    }
}

#[server]
async fn submit_action(data: String) -> Result<(), ServerFnError> {
    dbg!(data);
    Err(ServerFnError::new("yes"))
}


#[island]
fn Form(id_sig: RwSignal<Option<i32>>) -> impl IntoView {
    let dialog_ref = NodeRef::<leptos::html::Dialog>::new();

    let submit = ServerAction::<SubmitAction>::new();

    let form_res = Resource::new(
        move || id_sig.get(),
        |id_opt| async move {
            match id_opt {
                Some(id) => Some(get_form(id).await),
                None => None,
            }
        },
    );


    Effect::new( move || {
        if let Some(dialog) = dialog_ref.get() {
            if id_sig.get().is_some() {
                let _ = dialog.show_modal();
            } else {
                dialog.close();
            }
        }
    });

    view! {
        <dialog
            node_ref=dialog_ref
            on:close=move |_| id_sig.set(None)
        >
            <Suspense fallback=move || view! { <p>"Loading server data..."</p> }>
                { move || {
                    form_res.get().flatten().map(|result| match result {
                        Ok((form_str, form_data)) => {
                            #[cfg(feature = "hydrate")]
                            {
                                let form = serde_json::from_str::<FForm>(&form_str).unwrap();
                                let data = RwSignal::new(serde_json::to_value(form_data).unwrap());

                                view! {
                                    { move || data.with(| d |  serde_json::to_string_pretty(d).unwrap_or_default()) }
                                    <FormForge def = form.def data />
                                }.into_any()
                            }
                            #[cfg(not(feature = "hydrate"))]
                            {
                                let _ = form_str;
                                ().into_any()
                            }
                        },
                        Err(err) => view! {
                            <p class="error">{format!("Error: {err}")}</p>
                        }.into_any(),
                    })
                }}
            </Suspense>
            <button on:click=move |_| id_sig.set(None)>"Close"</button>
        </dialog>
    }
}

#[derive(serde::Deserialize, serde::Serialize, Debug ,Clone)]
struct TestData {
    id: i32,
    first_name: String,
    last_name: String,
    email: String
}

#[server]
async fn get_form(id: i32) -> Result<(String, TestData), ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let data = sqlx::query_as!(
        TestData, "
        select id, first_name , last_name, email
        from test_data  where id = $1", id)
        .fetch_one(&pool)
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))
        ?
        ;

    let form = r#"
        {
            "def" : {
                "title": "Minimal",
                "remoteSubmit" : true,
                "buttons" : [
                    {
                        "text" : "Save",
                        "classes" : ["button", "button-primary","button-large"],
                        "type" : "submit",
                        "action": "submit"
                    },
                    {
                        "text" : "Cancel",
                        "classes" : ["button", "button-primary","button-large"],
                        "type" : "button"
                    }
                ],
                "fields" : [
                    {
                        "type": "text",
                        "name": "first_name",
                        "label": "First name",
                        "classes": ["col-12"],
                        "breakAfter": true
                    },
                    {
                        "type": "text",
                        "name": "last_name",
                        "label": "Last name",
                        "classes": ["col-12"]
                    },
                    {
                        "type": "text",
                        "name": "email",
                        "label": "Email",
                        "classes": ["col-12"]
                    }
                ]
            },
            "data" : {
            }
        }
     "#;

    Ok((form.to_string(), data))
}
