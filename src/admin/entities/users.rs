use leptos::prelude::*;
use leptos_router::{LazyRoute, lazy_route};
use leptos_struct_table::{TableContent, TableDataProvider, TableRow};

#[derive(Clone, Default)]
pub struct UsersRoute;

#[lazy_route]
impl LazyRoute for UsersRoute {
    fn data() -> Self {
        Self
    }
    fn view(_this: Self) -> AnyView {
        view! { <UserTable/> }
        .into_any()
    }
}


#[island]
fn UserTable() -> impl IntoView {
    let scroll_container = NodeRef::new();
    let rows = UserTableDataProvider::default();
    view! {
        <div node_ref=scroll_container class="overflow-auto grow min-h-0">
            <table>
                <TableContent rows scroll_container/>
            </table>
        </div>
    }
}

#[derive(serde::Deserialize, serde::Serialize, Clone, TableRow)]
// #[cfg_attr(feature = "ssr", derive(sqlx::FromRow))]

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

// ---

#[server]
async fn get_users_count() -> Result<usize, ServerFnError> {
    let pool = use_context::<sqlx::PgPool>().unwrap();
    let count = sqlx::query_scalar::<_, i64>("select count(*) from users")
        .fetch_one(&pool)
        .await
        .map_err(|err| ServerFnError::new(format!("{err:?}")))?
    ;
    Ok(count as usize)
}

// ---

#[derive(Default)]
struct UserTableDataProvider;
impl TableDataProvider<User, usize> for UserTableDataProvider {
    async fn get_rows(&self, range: std::ops::Range<usize>) -> Result<(Vec<User>, std::ops::Range<usize>), String> {
         get_users()
            .await
            .map(|rows| {
                let len = rows.len();
                (rows, range.start .. range.start + len)
            })
            .map_err(|e| format!("{e:?}"))
    }

    async fn row_count(&self) -> Option<usize> {
        get_users_count().await.ok()
    }
}
