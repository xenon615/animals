use leptos::prelude::*;

#[cfg_attr(feature = "ssr", derive(sqlx::FromRow))]
#[derive(serde::Deserialize, serde::Serialize, Clone)]
pub struct CreatureBrief {
    pub id: i32,
    pub name: String,
    pub slug: String,
    pub image: Option<String>
}

#[derive(serde::Deserialize, serde::Serialize, Clone)]
pub struct Creature {
    pub id: i32,
    pub name: String,
    pub slug: String,
    pub scientific_name: String,
    pub genus_slug: String,
    pub genus_name: String,
    pub images: Option<String>
}

#[derive(serde::Deserialize, serde::Serialize, Clone, Debug)]
pub enum ListParams {
    Empty,
    Genus(String)
}

#[derive(serde::Deserialize, serde::Serialize, Clone, Debug)]
pub struct  Term {
    pub id: i32,
    pub parent_id: i32,
    pub name: String,
    pub slug: String,
    pub cat_name: String,
    pub hierarchy: i32,
    pub image: Option<String>
}

#[server]
pub async  fn get_creatures_list(lp: ListParams) -> Result<Vec<CreatureBrief>, ServerFnError> {
    #[cfg(feature = "ssr")]
    {

        use sqlx::QueryBuilder;
        let pool = use_context::<sqlx::PgPool>().unwrap();

        let base_sql = "SELECT ac.id, MAX(ac.name) name, MAX(ac.slug) slug , MAX(ai.image) AS image
        FROM creature ac
        LEFT JOIN creature_images aci ON ac.id = aci.creature_id
        LEFT JOIN image ai ON ai.id = aci.image_id";

        let mut builder: QueryBuilder<sqlx::Postgres> = sqlx::QueryBuilder::new(base_sql);
         // dbg!(builder.sql());
        match lp {
            ListParams::Genus(genus) => {builder.push(format!("
                JOIN taxonomy t ON t.id = ac.genus_id
                WHERE t.slug = '{}'
                ", genus));},
            _ => ()
        };
        builder.push(" GROUP BY ac.id");

        let query = builder.build_query_as::<CreatureBrief>();

        let res = query
            .fetch_all(&pool)
            .await
            ;
        match res {
            Ok(result) => Ok(result),
            Err(e) => Err(ServerFnError::ServerError(e.to_string()))
        }
    }
}

// ---

#[server]
pub async  fn get_creature(slug: String) -> Result<Creature, ServerFnError> {
    #[cfg(feature = "ssr")]
    {
        let pool = use_context::<sqlx::PgPool>().unwrap();
        let res = sqlx::query_as!(
            Creature,
        r#"
        SELECT ac.id, ac.name , ac.scientific_name, ac.slug,
        max(t.slug)  as "genus_slug!", max(t.name) as "genus_name!",
        string_agg(ai.image, ',' ) images
        FROM creature ac
        JOIN taxonomy t ON ac.genus_id = t.id
        JOIN creature_images aci ON ac.id = aci.creature_id
        LEFT JOIN image ai ON ai.id = aci.image_id
        WHERE ac.slug  = $1
        GROUP BY ac.id
        "#, slug)
            .fetch_one(&pool)
            .await
            ;
        match res {
            Ok(result) => Ok(result),
            Err(e) => Err(ServerFnError::ServerError(e.to_string()))
        }
    }
}

// ---

#[server]
pub async  fn get_hierarchy(parent_id: i32) -> Result<Vec<Term>, ServerFnError> {
    #[cfg(feature = "ssr")]
    {
        let pool = use_context::<sqlx::PgPool>().unwrap();
        let res = sqlx::query_as!(
            Term,
        r#"
        select t.id, t.parent_id, t.name name,  t.slug, c.name  as "cat_name!", c.hierarchy as "hierarchy!",
        hero_image(t.id) image
        from taxonomy t
        join category c on t.category_id = c.id
        where parent_id = $1
        "#, parent_id)
            .fetch_all(&pool)
            .await
            ;
        match res {
            Ok(result) => Ok(result),
            Err(e) => Err(ServerFnError::ServerError(e.to_string()))
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize, Clone)]
pub struct  Page {
    pub id: i32,
    pub slug: String,
    pub title: String,
    pub content: String
}

#[server]
pub async  fn get_page(slug: String) -> Result<Page, ServerFnError> {
    #[cfg(feature = "ssr")]
    {
        let pool = use_context::<sqlx::PgPool>().unwrap();
        let res = sqlx::query_as!(
            Page,
        r#"
        select id, slug, title, content
        from page t
        where slug = $1
        "#, slug)
            .fetch_one(&pool)
            .await
            ;
        match res {
            Ok(result) => Ok(result),
            Err(e) => Err(ServerFnError::ServerError(e.to_string()))
        }
    }
}
