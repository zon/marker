mod error;

use error::Error;

use std::path::{Path, PathBuf};

use rocket::tokio::fs::{self};
use rocket_dyn_templates::Template;
use serde::{Serialize, Deserialize};

#[macro_use] extern crate rocket;

const HEADER_SEPARATOR: &str = "^^^";
const DEFAULT_STYLE: &str = "layout";

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct Header {
    title: Option<String>,
    style: Option<String>
}

#[derive(Serialize)]
struct Response {
    title: String,
    style: String,
    body: String
}

#[get("/")]
async fn index() -> Result<Template, Error> {
    files(Path::new("index.md").to_path_buf()).await
}

#[get("/<file..>")]
async fn files(file: PathBuf) -> Result<Template, Error> {
    let title = file.to_str().expect("invalid file").to_string();
    let path = Path::new("content/").join(file);
    let ext = path
        .extension().expect("invalid path")
        .to_str().expect("invalid path str");
    
    let contents = fs::read_to_string(path.clone()).await?;
    let res = match ext {
        "md" => {
            let md = contents.as_str();
            
            let parts: Vec<&str> = md.split(HEADER_SEPARATOR).collect();
            if parts.len() > 1 {
                let header: Header = serde_yaml::from_str(parts[0])?;
                let title = header.title.unwrap_or(title);
                let style = header.style.unwrap_or(DEFAULT_STYLE.to_string());
                let body = markdown::to_html(parts[1]);
                Response { title, style, body }
            
            } else {
                Response {
                    title,
                    style: DEFAULT_STYLE.to_string(),
                    body: markdown::to_html(md)
                }
            }
        }
        _ => Response {
            title,
            style: DEFAULT_STYLE.to_string(),
            body: contents
        }
    };
    
    Ok(Template::render("layout", res))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index, files])
        .attach(Template::fairing())
}
