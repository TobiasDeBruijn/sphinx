use std::ops::Deref;
use sqlx::migrate::Migrator;
use sqlx::mysql::MySqlConnectOptions;
use sqlx::{migrate, MySqlPool};
use thiserror::Error;

pub mod group;

pub struct Database(MySqlPool);

pub struct Opts<'a> {
    pub user: &'a str,
    pub passw: &'a str,
    pub host: &'a str,
    pub name: &'a str,
}

impl Deref for Database {
    type Target = MySqlPool;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

pub(crate) type DatabaseResult<T> = Result<T, DatabaseError>;

#[derive(Debug, Error)]
pub enum DatabaseError {
    #[error("{0}")]
    Sqlx(#[from] sqlx::Error),
    #[error("{0}")]
    Migrate(#[from] migrate::MigrateError),
}

const MIGRATOR: Migrator = migrate!("./migrations");

impl Database {
    async fn new(opts: Opts<'_>) -> DatabaseResult<Self> {
        let opts = MySqlConnectOptions::new()
            .username(opts.user)
            .password(opts.passw)
            .host(opts.host)
            .database(opts.name);
        let pool = MySqlPool::connect_with(opts).await?;

        let mut conn = pool.acquire().await?;
        MIGRATOR.run(&mut conn).await?;

        Ok(Self(pool))
    }
}

trait FromWithDatabase<'a, T> {

    fn from_with_database(value: T, database: &'a Database) -> Self;
}