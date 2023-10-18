use actix_multiresponse::Payload;
use actix_web::web;
use serde::Deserialize;
use dal::group::Group;
use proto::GroupEntity;
use proto_convert::FromDal;
use crate::Database;
use crate::error::{Error, WebResult};

#[derive(Debug, Deserialize)]
pub struct Query {
    id: u32,
}

pub async fn get(data: Database, query: web::Query<Query>) -> WebResult<Payload<GroupEntity>> {
    let group = Group::get(&data, query.id).await?
        .ok_or(Error::NotFound)?;

    Ok(Payload(GroupEntity::from_dal(group)))
}