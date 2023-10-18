mod group;

pub trait FromDal<T> {
    fn from_dal(value: T) -> Self;
}