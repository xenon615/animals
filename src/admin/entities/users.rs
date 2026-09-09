use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};
use leptos_struct_table::*;

#[derive(Clone, Default)]
pub struct UsersRoute;

#[lazy_route]
impl LazyRoute for UsersRoute {
    fn data() -> Self {
        Self
    }
    fn view(this: Self) -> AnyView {
        let r = Resource::new(||(), move | _ | get_users());
        view! {
            <Transition fallback = move || view! {"Loading users ..."}>
                {
                    move || {
                        match r.get() {
                            Some(Err(_)) => view! {"shit happens"}.into_any(),
                            None => view! {"none shit happens"}.into_any(),
                            Some(Ok(users)) => view! {<UserTable users/>}.into_any()
                        }
                    }
                }

            </Transition>

        }
        .into_any()
    }
}

#[derive(TableRow, Clone)]
#[table(impl_vec_data_provider)]
pub struct Person {
    pub id: u32,
    pub name: String,
    pub age: u32,
}

#[component]
fn UserTable(users: Vec<User>) -> impl IntoView {
    let rows = vec![
            Person { id: 1, name: "Alice".to_string(), age: 30 },
            Person { id: 2, name: "Bob".to_string(), age: 25 },
            Person { id: 3, name: "Charlie".to_string(), age: 35 },
    ];
    view! {
        <table>
            <TableContent rows scroll_container="" />
        </table>
       }
}

#[derive(serde::Deserialize, serde::Serialize, Clone)]
// #[table(impl_vec_data_provider)]
pub struct User {
    id: i32,
    username: String
}

#[server]
async fn get_users() -> Result<Vec<User>, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let result = sqlx::query_as!(User, "select id, username from users")
        .fetch_all(&pool)
        .await
        ;
    result.map_err(|e| ServerFnError::new(e.to_string()))
}
