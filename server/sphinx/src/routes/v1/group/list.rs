use actix_multiresponse::Payload;
use dal::group::Group;
use proto::ListGroupsResponse;
use proto_convert::FromDal;
use crate::Database;
use crate::error::WebResult;

pub async fn list(data: Database) -> WebResult<Payload<ListGroupsResponse>> {
    let groups = Group::list(&data).await?;
    Ok(Payload(ListGroupsResponse {
        groups: groups.into_iter().map(proto::GroupEntity::from_dal).collect(),
    }))
}