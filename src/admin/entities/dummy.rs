use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};

#[derive(Clone, Default)]
pub struct DummyRoute;

#[lazy_route]
impl LazyRoute for DummyRoute {
    fn data() -> Self {
        Self
    }
    fn view(_this: Self) -> AnyView {
        let r = Resource::new(||(), move | _ | get_dummy_data());
        view! {
            <Transition fallback = move || view! {"Loading ..."}>
                {
                    move || {
                        match r.get() {
                            Some(Err(_)) => view! {"shit happens"}.into_any(),
                            None => view! {"none shit happens"}.into_any(),
                            Some(Ok(dummy_data)) => view! {<DummyTable dummy_data/>}.into_any()
                        }
                    }
                }

            </Transition>

        }
        .into_any()
    }
}




#[component]
fn DummyTable(dummy_data: Vec<DummyData> ) -> impl IntoView {
    view! {
        "HREN"
    }
}
#[derive(serde::Deserialize, serde::Serialize, Clone)]
struct DummyData {
    id: u32,
    data: String
}


#[server]
async fn get_dummy_data() -> Result<Vec<DummyData>, ServerFnError> {
    Ok(
        vec![
            DummyData {id: 1, data:"info 1".to_string()},
            DummyData {id: 2, data:"info 2".to_string()}
        ]
    )
}
