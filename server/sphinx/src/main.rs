use actix_web::web;

mod routes;
mod error;

pub type Database = web::Data<dal::Database>;

#[tokio::main]
async fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;

    println!("Hello, world!");

    Ok(())
}
