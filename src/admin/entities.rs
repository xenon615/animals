pub mod dashboard;
pub mod users;

use leptos::prelude::*;
#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct Entity {
    pub slug: String,
    pub label: String,
}

// #[server]
// pub async fn get_list() -> Result<Vec<Entity>, ServerFnError> {
//     Ok(vec![
//         Entity {
//             label: "DashBoard".to_string(),
//             slug: "".to_string(),
//         },
//         Entity {
//             label: "Users".to_string(),
//             slug: "users".to_string(),
//         },
//     ])
// }

pub fn get_list() -> Vec<Entity> {
    vec![
        Entity {
            label: "Dashboard".to_string(),
            slug: "".to_string(),
        },
        Entity {
            label: "Users".to_string(),
            slug: "users".to_string(),
        },
    ]
}
