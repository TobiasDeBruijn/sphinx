use dal::group::Group;
use crate::FromDal;

impl FromDal<Group<'_>> for proto::GroupEntity {
    fn from_dal(value: Group) -> Self {
        Self {
            id: value.id,
            name: value.name,
            photo: value.photo,
            pin_code: value.pin_code,
            minimal_balance: value.minimal_balance,
        }
    }
}
