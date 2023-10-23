use sqlx::FromRow;
use crate::{Database, DatabaseResult, FromWithDatabase};
use crate::group::Group;

pub struct User<'a> {
    database: &'a Database,
    pub id: u32,
    pub name: String,
    pub photo: Vec<u8>,
    pub balance: f64,
    pub group_id: u32,
}

#[derive(FromRow)]
struct _User {
    id: u32,
    name: String,
    photo: Vec<u8>,
    balance: f64,
    group_id: u32,
}

impl<'a> FromWithDatabase<'a, _User> for User<'a> {
    fn from_with_database(value: _User, database: &'a Database) -> Self {
        Self {
            database,
            id: value.id,
            name: value.name,
            photo: value.photo,
            balance: value.balance,
            group_id: value.group_id,
        }
    }
}

impl<'a> User<'a> {
    pub async fn get_by_id(database: &'a Database, id: u32) -> DatabaseResult<Option<User<'a>>> {
        let user: Option<_User> = sqlx::query_as("SELECT * FROM users WHERE id = ?")
            .bind(id)
            .fetch_optional(&**database)
            .await?;
        Ok(user.map(|e| User::from_with_database(e, database)))
    }

    pub async fn list_in_group(database: &'a Database, group: &Group<'_>) -> DatabaseResult<Vec<User<'a>>> {
        let users = sqlx::query_as("SELECT * FROM users WHERE group_id = ?")
            .bind(group.id)
            .fetch_all(&**database)
            .await?;
        Ok(users.into_iter().map(|e| User::from_with_database(e, database)).collect())
    }

    pub async fn create(database: &'a Database, group: &Group<'_>, name: String) -> DatabaseResult<User<'a>> {
        let id = sqlx::query("INSERT INTO users (name, group_id) VALUES (?, ?)")
            .bind(&name)
            .bind(group.id)
            .execute(&**database)
            .await?
            .last_insert_id();

        Ok(User {
            database,
            id: id as u32,
            name,
            photo: vec![],
            balance: 0.00,
            group_id: group.id,
        })
    }
}