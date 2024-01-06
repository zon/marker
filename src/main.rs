use std::path::{Path, PathBuf};

use rocket::tokio::fs::{self};
use rocket_dyn_templates::{Template, context};

#[macro_use] extern crate rocket;

#[get("/")]
async fn index() -> Result<Template, std::io::Error> {
    files(Path::new("index.md").to_path_buf()).await
}

#[get("/<file..>")]
async fn files(file: PathBuf) -> Result<Template, std::io::Error> {
    let path = Path::new("content/").join(file);
    let title = path.to_str().expect("invalid path");
    let ext = path
        .extension().expect("invalid path")
        .to_str().expect("invalid path str");
    
    let contents = fs::read_to_string(path.clone()).await?;
    let body = match ext {
        "md" => {
            let md = contents.as_str();
            markdown::to_html(md)
        }
        _ => contents
    };
    
    Ok(Template::render("layout", context! {
        title,
        body
    }))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index, files])
        .attach(Template::fairing())
}
