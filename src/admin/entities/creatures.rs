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
                // Some(id) => Some(get_single(id).await),
                Some(id) => Some(get_form_data(id).await),
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
                        Ok(form_data) => view! {
                            <FormInner fd = form_data/>
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
fn FormInner(fd: FormData) -> impl IntoView {
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
                            <input type="hidden" name="creature[id]" value=fd.creature.id/>
                        </label>
                        <label>"Name"
                            <input type="text" name="creature[name]" value=fd.creature.name/>
                        </label>
                        <label>"Scientific name"
                            <input type="text" name="creature[scientific_name]" value=fd.creature.scientific_name/>
                        </label>
                        <label>"Genus"
                            <select name="creature[genus_id]">
                                {
                                    fd.genuses.into_iter().map(| o | view! {
                                        <option
                                            value=o.0.clone()
                                            selected = move || o.0 == fd.creature.genus_id.to_string()
                                        >
                                            {o.1}
                                        </option>
                                    }).collect_view()
                                }
                            </select>
                        </label>
                        <label>"Slug"
                            <input type="text" name = "creature[slug]" value=fd.creature.slug/>
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
    #[table(renderer = "ImageTableCellRenderer")]
    image: Option<String>
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
struct FormData {
    creature: Creature,
    genuses: Vec<(String, String)>
}

#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
struct QueryParams {
    range: Range<usize>
}

// #[server]
// async fn get_list(params: QueryParams) -> Result<Vec<CreatureForList>, ServerFnError> {
//     let pool = use_context::<sqlx::PgPool>().unwrap();
//     let result = sqlx::query_as!(
//         CreatureForList, r#"
//         select c.id, c.name , c.scientific_name, t.name "genus_name", c.slug
//         from creature c
//         join taxonomy t on c.genus_id = t.id,
//         order by 1 limit $1 offset $2 "#, params.range.len() as i64, params.range.start as i64
//     )
//         .fetch_all(&pool)
//         .await
//         ;
//     result.map_err(|e| ServerFnError::new(e.to_string()))
// }

#[server]
async fn get_list(params: QueryParams) -> Result<Vec<CreatureForList>, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let result = sqlx::query_as!(
        CreatureForList, r#"
        with cii as (
        select ci.creature_id, min(i.image) image
        from creature_images ci
        join image i on i.id = ci.image_id
        group by ci.creature_id
        )
        select c.id, c.name , c.scientific_name, t.name "genus_name", cii.image
                from creature c
                join taxonomy t on c.genus_id = t.id
                left join cii on cii.creature_id = c.id

        order by 1 limit $1 offset $2 "#, params.range.len() as i64, params.range.start as i64
    )
        .fetch_all(&pool)
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))
        ?
        ;

    Ok(
        // result.into_iter().map(| mut c | {c.image = Some("1".to_string()); c} ).collect::<Vec<CreatureForList>>()
        result
    )

}

// ---

#[component]
fn ImageTableCellRenderer(
    class: String,
    value: Signal<Option<String>>,
    row: RwSignal<CreatureForList>,
    index: usize,
) -> impl IntoView
{
    view! {
        <td class=class>
            {
                move || match value.get() {
                    Some(url) => {
                        let new_url = format!("/media/images/{}",&url[2..]);
                        view! {<img src=new_url alt="Creature image" height="64"/>}.into_any()
                    },
                    None => view! {"-"}.into_any()
                }
            }
        </td>
    }
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

#[server]
async fn get_form_data(id: i32) -> Result<FormData, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let creature = sqlx::query_as!(
        Creature, "
        select c.id, c.name , c.scientific_name, c.genus_id, c.slug
        from creature c where id = $1", id)
        .fetch_one(&pool)
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))
        ?
        ;
    let genuses = sqlx::query!(
        "
        select id, name  from taxonomy where category_id = 6")
        .fetch_all(&pool)
        .await
        .map_err(|e| ServerFnError::new(e.to_string()))
        ?
        ;
    let genuses:Vec<(String, String)> = genuses.into_iter().map(|r| (r.id.to_string() , r.name)).collect();
    Ok(FormData { creature, genuses})
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
