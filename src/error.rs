use rocket::response::Responder;


#[derive(Debug, Responder)]
#[response(status = 500)]
pub enum Error {
    Io(std::io::Error),
    Yaml(String)
}

impl From<std::io::Error> for Error {
    fn from(err: std::io::Error) -> Self {
        Error::Io(err)
    }
}

impl From<serde_yaml::Error> for Error {
    fn from(err: serde_yaml::Error) -> Self {
        Error::Yaml(err.to_string())
    }
}
