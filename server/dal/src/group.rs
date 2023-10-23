use sqlx::FromRow;
use crate::{Database, DatabaseResult, FromWithDatabase};

pub struct Group<'a> {
    database: &'a Database,
    pub id: u32,
    pub name: String,
    pub photo: Vec<u8>,
    pub pin_code: Vec<u8>,
    pub minimal_balance: f64,
}

#[derive(Debug, FromRow)]
struct _Group {
    id: u32,
    name: String,
    photo: Vec<u8>,
    pin_code: Vec<u8>,
    minimal_balance: f64,
}

impl<'a> FromWithDatabase<'a, _Group> for Group<'a> {
    fn from_with_database(value: _Group, database: &'a Database) -> Self {
        Self {
            database,
            id: value.id,
            name: value.name,
            photo: value.photo,
            pin_code: value.pin_code,
            minimal_balance: value.minimal_balance,
        }
    }
}

impl<'a> Group<'a> {
    pub async fn new(database: &'a Database, name: String, pin_code: Vec<u8>) -> DatabaseResult<Group<'a>> {
        let mut tx = database.begin().await?;
        let id = sqlx::query("INSERT INTO groups (name, pin_code, minimal_balance) VALUES (?, ?, -10.0)")
            .bind(&name)
            .bind(&pin_code)
            .execute(&mut *tx)
            .await?
            .last_insert_id();

        Ok(Self {
            database,
            id: id as u32,
            name,
            photo: vec![],
            pin_code,
            minimal_balance: -10.0,
        })
    }

    pub async fn get(database: &'a Database, id: u32) -> DatabaseResult<Option<Group<'a>>> {
        let group: Option<_Group> = sqlx::query_as("SELECT * FROM groups WHERE id = ?")
            .bind(id)
            .fetch_optional(&**database)
            .await?;
        Ok(group.map(|g| Group::from_with_database(g, database)))
    }

    pub async fn list(database: &'a Database) -> DatabaseResult<Vec<Group<'a>>> {
        let groups: Vec<_Group> = sqlx::query_as("SELECT * FROM groups")
            .fetch_all(&**database)
            .await?;
        Ok(groups.into_iter().map(|g| Group::from_with_database(g, database)).collect())
    }
}
