use sqlx::{Decode, Encode, FromRow, Type};
use crate::{Database, DatabaseResult, FromWithDatabase, impl_enum_type};
use crate::group::Group;

pub struct Product<'a> {
    database: &'a Database,
    pub id: u32,
    pub name: String,
    pub quantity_liters: Option<f64>,
    pub stock: u32,
    pub photo: Vec<u8>,
    pub price: f64,
    pub category: Category,
}

#[derive(Debug, Decode, Encode)]
pub enum Category {
    Alcohol,
    SoftDrink
}

impl_enum_type!(Category);

#[derive(FromRow)]
struct _Product {
    id: u32,
    name: String,
    quantity_liters: Option<f64>,
    stock: u32,
    photo: Vec<u8>,
    price: f64,
    category: Category,
}

impl<'a> FromWithDatabase<'a, _Product> for Product<'a> {
    fn from_with_database(value: _Product, database: &'a Database) -> Self {
        Self {
            database,
            id: value.id,
            name: value.name,
            quantity_liters: value.quantity_liters,
            stock: value.stock,
            photo: value.photo,
            price: value.price,
            category: value.category,
        }
    }
}

impl<'a> Product<'a> {
    pub async fn get_by_id(database: &'a Database, id: u32) -> DatabaseResult<Option<Product<'a>>> {
        let product: Option<_Product> = sqlx::query_as("SELET * FROM products WHERE id = ?")
            .bind(id)
            .fetch_optional(&**database)
            .await?;
        Ok(product.map(|e| Product::from_with_database(e, database)))
    }

    pub async fn list_in_group(database: &'a Database, group: &Group<'_>) -> DatabaseResult<Vec<Product<'a>>> {
        let products = sqlx::query_as("SELECT * FROM products WHERE group_id = ?")
            .bind(group.id)
            .fetch_all(&**database)
            .await?;
        Ok(products.into_iter().map(|e| Product::from_with_database(e, database)).collect())
    }
}