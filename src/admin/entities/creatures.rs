use std::ops::Range;

use leptos::{
    prelude::*,
    leptos_dom::logging::console_log
};
use leptos_router::{LazyRoute, lazy_route};
use leptos_struct_table::{TableContent, TableDataProvider, TableRow, Selection, SelectionChangeEvent};

#[derive(Clone, Default)]
pub struct CreaturesRoute;

#[lazy_route]
impl LazyRoute for CreaturesRoute {
    fn data() -> Self {
        Self
    }
    fn view(_this: Self) -> AnyView {
        view! {
            <CreatureTable/>
        }
        .into_any()
    }
}


#[island]
fn CreatureTable() -> impl IntoView {
    let container = NodeRef::new();
    let rows = CreatureTableDataProvider::default();
    let selected_index = RwSignal::new(None);
    // let row = use_context::<RwSignal<Option<Creature>>>().unwrap();
    let row: RwSignal<Option<Creature>> = RwSignal::new(None);
    provide_context(row);


    view! {
        <FormModal/>
        <div class="table-wrapper">
            <div node_ref=container class="table-scroll-container">
                <table>
                    <TableContent
                        rows=rows
                        scroll_container=container
                        loading_cell_inner_class="loading-skeleton"
                        selection=Selection::Single(selected_index)
                        on_selection_change={move |evt: SelectionChangeEvent<Creature>| {
                            row.write().replace(evt.row.get());
                        }}
                    />
                </table>
            </div>
        </div>
    }
}

// ---

#[island]
// pub fn FormModal() -> impl IntoView {
//     let row = expect_context::<RwSignal<Option<Creature>>>();
//     view! {
//         {
//             move | | {
//                 row.get().map(| r | view! {
//                     <div class="form-modal">
//                         <div class="form-wrap">
//                             <pre>
//                                 "Id:      "{r.id} "\n"
//                                 "Name:    "{r.name} "\n"
//                             </pre>
//                         </div>
//                     </div>
//                 })
//             }
//         }
//     }
// }

pub fn FormModal() -> impl IntoView {
    let row = expect_context::<RwSignal<Option<Creature>>>();
    let modal_ref = NodeRef::<leptos::html::Dialog>::new();
    Effect::new(move || {
        if let Some(modal) = modal_ref.get() {
            if row.get().is_some() {
                let _ = modal.show_modal();
            } else {
                modal.close();
            }
        }
    });

    view! {
        <dialog node_ref = modal_ref>
        {
            move | | {
                row.get().map(| r | view! {
                    <div class="form-wrap">
                        <pre>
                            "Id:      "{r.id} "\n"
                            "Name:    "{r.name} "\n"
                        </pre>
                        <button
                            on:click = move |_| row.set(None)
                        >
                            Close
                        </button>
                    </div>
                })
            }
        }

        </dialog>
    }

}


// ---

#[derive(serde::Deserialize, serde::Serialize, Clone, TableRow)]
pub struct Creature {
    id: i32,
    name: String,
    scientific_name: String,
    genus_id: i64,
    slug: String
}

#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
struct QueryParams {
    range: Range<usize>
}

#[server]
async fn get_list(params: QueryParams) -> Result<Vec<Creature>, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let result = sqlx::query_as!(
        Creature, "select id, name, scientific_name, genus_id, slug from creature  limit $1 offset $2 ", params.range.len() as i64, params.range.start as i64
    )
        .fetch_all(&pool)
        .await
        ;
    result.map_err(|e| ServerFnError::new(e.to_string()))
}

// ---

#[server]
async fn get_count() -> Result<usize, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let count = sqlx::query_scalar::<_, i64>("select count(*) from creature")
        .fetch_one(&pool)
        .await
        .map_err(|err| ServerFnError::new(format!("{err:?}")))?
    ;
    Ok(count as usize)
}

// ---

#[derive(Default)]
struct CreatureTableDataProvider;
impl TableDataProvider<Creature, usize> for CreatureTableDataProvider {
    async fn get_rows(&self, range:Range<usize>) -> Result<(Vec<Creature>, Range<usize>), String> {

         get_list(QueryParams { range: range.clone() })
            .await
            .map(|rows| {
                let len = rows.len();
                (rows, range.start .. range.start + len)
            })
            .map_err(|e| format!("{e:?}"))
    }

    async fn row_count(&self) -> Option<usize> {
        get_count().await.ok()
    }
}
