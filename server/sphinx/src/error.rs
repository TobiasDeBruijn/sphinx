use thiserror::Error;

pub type WebResult<T> = Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("{0}")]
    Database(#[from] dal::DatabaseError),
    #[error("Not found")]
    NotFound,
    #[error("Bad request")]
    BadRequest,
}