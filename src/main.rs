#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
    use axum::{Router, routing::{post, get}};
    use leptos::logging::log;
    use leptos::prelude::*;
    use leptos_axum::{generate_route_list, LeptosRoutes};

    // use tower_sessions_sqlx_store::{PostgresStore, sqlx::PgPool, sqlx};
    use tower_sessions_sqlx_store::{PostgresStore, sqlx::PgPool, sqlx};
    use tracing_subscriber::{
        layer::SubscriberExt,
        util::SubscriberInitExt,
        filter::EnvFilter
    };
    use axum_login::{
        AuthManagerLayerBuilder,
        tower_sessions::SessionManagerLayer
    };
    use animals::app::*;
    use animals::auth_backend::UsersBase;



    tracing_subscriber::registry()
        .with(EnvFilter::new(std::env::var("RUST_LOG").unwrap_or_else(
            |_| "axum_login=debug,tower_sessions=debug,sqlx=warn,tower_http=debug".into(),
        )))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let conf = get_configuration(None).unwrap();

    let addr = conf.leptos_options.site_addr;
    let routes = generate_route_list(App);

    let pool = PgPool::connect("postgres://dbuser:dbpass@localhost:5432/animals").await.unwrap();

    let session_store = PostgresStore::new(pool.clone());
    session_store.migrate().await.expect("failed database migration");
    let session_layer = SessionManagerLayer::new(session_store);

    let auth_layer = AuthManagerLayerBuilder::new(UsersBase(pool.clone()), session_layer.clone()).build();

    let app = Router::new()
        // .route("/admin", get(leptos_axum::handle_server_fns))
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
        // .layer(session_layer)
        .layer(auth_layer)

    ;

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
