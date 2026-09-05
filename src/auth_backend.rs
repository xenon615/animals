#[cfg(feature="ssr")]
use axum_login::{AuthUser, AuthnBackend, UserId};

#[cfg(feature="ssr")]
use sqlx::{query_as, query};

#[cfg(feature="ssr")]
use argon2::{
    password_hash::{
        phc::PasswordHash,
        PasswordHasher, PasswordVerifier,
    },
    Argon2
};


#[cfg(feature="ssr")]
#[derive(Clone, Debug)]
pub struct UsersBase(pub sqlx::PgPool);

#[cfg(feature="ssr")]
#[derive(Debug, Clone) ]
pub struct User{
    id: i32,
    username: String,
    pass_hash: Vec<u8>
}

#[cfg(feature="ssr")]
#[derive(Clone, Debug,thiserror::Error, serde::Deserialize, serde::Serialize)]
pub enum UserBaseError {
    #[error("Not Found")]
    NotFound,
    #[error("Wrong Password")]
    WrongPassword,
    #[error("Duplicate username")]
    Duplicate,
    #[error("Database Error")]
    DBerror,
}


#[cfg(feature="ssr")]
impl AuthUser for User {
    type Id = String;
    fn id(&self) -> Self::Id {
        self.username.clone()
    }
    fn session_auth_hash(&self) -> &[u8] {
        &self.pass_hash
    }
}

#[cfg(feature="ssr")]
impl UsersBase {
    pub async fn create_user(
        &self,
        username: String,
        password: String
    ) -> Result<i32, UserBaseError>
    {

        let argon2 = Argon2::default();
        let pass_hash = argon2.hash_password(&password.as_bytes().to_vec())
            .map_err(|_| UserBaseError::WrongPassword)?.to_string();

        let rec  = query!("insert into users(username, pass_hash) values($1, $2) returning id ", username, pass_hash)
            .fetch_one(&self.0)
            .await;

        match rec {
            Ok(r) => Ok(r.id),
            Err(sqlx::Error::Database(e)) if e.is_unique_violation() => Err(UserBaseError::Duplicate),
            _ => Err(UserBaseError::DBerror)
        }
    }

    // ---

    pub async fn delete_user(
        &self,
        id: i32,
    ) -> Result<(), UserBaseError>
    {

        let res  = query!("delete from users where id = $1", id)
            .execute(&self.0)
            .await;

        match res {
            Ok(_) => Ok(()),
            Err(sqlx::Error::RowNotFound) => Err(UserBaseError::NotFound),
            _ => Err(UserBaseError::DBerror)
        }
    }
}

#[cfg(feature="ssr")]
impl AuthnBackend for UsersBase {
    type User = User;
    type Credentials = (String, String);
    type Error = UserBaseError;

    async fn authenticate(
        &self,
        (username, password): Self::Credentials,
    ) -> Result<Option<Self::User>, Self::Error> {
        let user_maybe = self.get_user(&username).await;

        match user_maybe {
            Ok(Some(user)) => {
                let stored_string  = String::from_utf8(user.pass_hash.clone()).map_err(|_| UserBaseError::WrongPassword)?;
                let parsed_hash = PasswordHash::new(&stored_string).map_err(|_| UserBaseError::WrongPassword)?;
                match Argon2::default().verify_password(&password.into_bytes(), &parsed_hash) {
                    Ok(_) => Ok(Some(user)),
                    Err(_) => Err(UserBaseError::WrongPassword)
                }
            },
            _ => user_maybe
        }
    }

    //  ---
    #[cfg(feature="ssr")]
    async fn get_user(
        &self,
        username: &UserId<Self>,
    ) -> Result<Option<Self::User>, Self::Error> {
        query_as!(User,"select id, username, pass_hash from users where username = $1", username)
            .fetch_optional(&self.0)
            .await
            .map_err(|_|  UserBaseError::NotFound)

    }



}
