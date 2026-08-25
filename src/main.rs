// #[derive(axum::extract::FromRef, Debug, Clone)]
// pub struct AppState {
//     pub leptos_options: LeptosOptions,
//     pub pool: sqlx::SqlitePool
// }



#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
    use axum::Router;
    use leptos::logging::log;
    use leptos::prelude::*;
    use leptos_axum::{generate_route_list, LeptosRoutes};
    use animals::app::*;

    let conf = get_configuration(None).unwrap();
    // dbg!(&conf);
    let addr = conf.leptos_options.site_addr;
    let routes = generate_route_list(App);
    // dbg!(&routes);



    // let app = Router::new()
    //     .leptos_routes(
    //         &conf.leptos_options,
    //         routes,
    //         {
    //             let leptos_options = conf.leptos_options.clone();
    //             move || shell(leptos_options.clone())
    //         }
    //     )
    //     .fallback(leptos_axum::file_and_error_handler(shell))
    //     .with_state(conf.leptos_options)
    // ;

    // let pool = sqlx::SqlitePool::connect("sqlite:db/db.sqlite3").await.unwrap();
    let pool = sqlx::PgPool::connect("postgres://dbuser:dbpass@localhost:5432/animals").await.unwrap();

    let app = Router::new()
        .leptos_routes_with_context(
            &conf.leptos_options,
            routes,
            move || provide_context(pool.clone()),
            {
                let leptos_options = conf.leptos_options.clone();
                move || shell(leptos_options.clone())
            }
        )
        .fallback(leptos_axum::file_and_error_handler(shell))
        .with_state(conf.leptos_options)

    ;

    // run our app with hyper
    // `axum::Server` is a re-export of `hyper::Server`
    log!("listening on http://{}", &addr);
    let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
    axum::serve(listener, app.into_make_service())
        .await
        .unwrap();
}

#[cfg(not(feature = "ssr"))]
pub fn main() {
    // no client-side main function
    // unless we want this to work with e.g., Trunk for pure client-side testing
    // see lib.rs for hydration function instead
}
