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
    let id_sig: RwSignal<Option<i32>> =  RwSignal::new(None);

    provide_context(id_sig);
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
                        on_selection_change={move |evt: SelectionChangeEvent<CreatureForList>| {
                            id_sig.write().replace(evt.row.get().id);
                        }}
                    />
                </table>
            </div>
        </div>
    }
}

// ---

#[server]
async fn submit_action(creature: Creature) -> Result<(), ServerFnError> {
    // dbg!(&creature);
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let res  = sqlx::query!("update creature set name=$1, scientific_name = $2, genus_id = $3, slug= $4  where id = $5",
        creature.name, creature.scientific_name, creature.genus_id, creature.slug, creature.id)
        .execute(&pool)
        .await;
    res.map(|_| ()).map_err(| e | ServerFnError::new(e.to_string()))
}

// ---

#[island]
pub fn FormModal() -> impl IntoView {
    let id = expect_context::<RwSignal<Option<i32>>>();
    let modal_ref = NodeRef::<leptos::html::Dialog>::new();
    let data_res = Resource::new(
        move || id.get(),
        |id_opt| async move {
            match id_opt {
                Some(id) => Some(get_single(id).await),
                None => None,
            }
        },
    );

    Effect::new(move || {
        if let Some(modal) = modal_ref.get() {
            if id.get().is_some() {
                let _ = modal.show_modal();
            } else {
                modal.close();
            }
        }
    });

    view! {
        <dialog
            node_ref=modal_ref
            on:close=move |_| id.set(None)
        >
            <Suspense fallback=move || view! { <p>"Loading server data..."</p> }>
                { move || {
                    data_res.get().flatten().map(|result| match result {
                        Ok(creature) => view! {
                            <FormInner r = creature/>
                        }.into_any(),
                        Err(err) => view! {
                            <p class="error">{format!("Error: {err}")}</p>
                        }.into_any(),
                    })
                }}
            </Suspense>
            <button on:click=move |_| id.set(None)>"Close"</button>
        </dialog>
    }
}

// ---

#[island]
fn FormInner(r: Creature) -> impl IntoView {
    let submit = ServerAction::<SubmitAction>::new();
    let err_message = move || {
        match submit.value().get() {
            Some(Err(ServerFnError::ServerError(s))) => Some(s),
            _ => None
        }
    };

    view! {
        <div class="form-wrap">
            <pre>
                <ActionForm action = submit>
                    <fieldset>
                        <legend>Creature</legend>
                        <label>"Id"
                            <input type="text" name="creature[id]" value=r.id/>
                        </label>
                        <label>"Name"
                            <input type="text" name="creature[name]" value=r.name/>
                        </label>
                        <label>"Scientific name"
                            <input type="text" name="creature[scientific_name]" value=r.scientific_name/>
                        </label>
                        <label>"Genus Id"
                            <input type="text" name="creature[genus_id]" value=r.genus_id/>
                        </label>
                        <label>"Slug"
                            <input type="text" name = "creature[slug]" value=r.slug/>
                        </label>

                    </fieldset>
                    <input type="submit"/>
                </ActionForm>
                {err_message()}
            </pre>
        </div>
    }
}

// ---

#[derive(serde::Deserialize, serde::Serialize, Debug ,Clone, TableRow)]
pub struct CreatureForList {
    id: i32,
    name: String,
    scientific_name: String,
    genus_name: String,
    slug: String
}

#[derive(serde::Deserialize, serde::Serialize, Debug ,Clone, TableRow)]
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
async fn get_list(params: QueryParams) -> Result<Vec<CreatureForList>, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let result = sqlx::query_as!(
        CreatureForList, r#"
        select c.id, c.name , c.scientific_name, t.name "genus_name", c.slug
        from creature c
        join taxonomy t on c.genus_id = t.id
        order by 1 limit $1 offset $2 "#, params.range.len() as i64, params.range.start as i64
    )
        .fetch_all(&pool)
        .await
        ;
    result.map_err(|e| ServerFnError::new(e.to_string()))
}

// ---

#[server]
async fn get_single(id: i32) -> Result<Creature, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let result = sqlx::query_as!(
        Creature, "
        select c.id, c.name , c.scientific_name, c.genus_id, c.slug
        from creature c where id = $1", id)
        .fetch_one(&pool)
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
impl TableDataProvider<CreatureForList, usize> for CreatureTableDataProvider {
    async fn get_rows(&self, range:Range<usize>) -> Result<(Vec<CreatureForList>, Range<usize>), String> {

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
