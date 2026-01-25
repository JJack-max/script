use std::{fmt, num::TryFromIntError, string::FromUtf8Error};

use bytes::Bytes;

#[derive(Debug)]
pub(crate) enum Frame {
    Simple(String),
    Error(String),
    Integer(u64),
    Bulk(Bytes),
    Null,
    Array(Vec<Frame>),
}

#[derive(Debug)]
pub(crate) enum Error {
    InComplete,
    Other(crate::Error),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::InComplete => "stream ended early".fmt(f),
            Error::Other(error) => error.fmt(f),
        }
    }
}

impl std::error::Error for Error {}

impl From<String> for Error {
    fn from(value: String) -> Self {
        Self::Other(value.into())
    }
}

impl From<&str> for Error {
    fn from(value: &str) -> Self {
        Self::Other(value.into())
    }
}

impl From<FromUtf8Error> for Error {
    fn from(_: FromUtf8Error) -> Self {
        "protocol error; invalid frame format".into()
    }
}

impl From<TryFromIntError> for Error {
    fn from(_: TryFromIntError) -> Self {
        "protocol error; invalid frame format".into()
    }
}
