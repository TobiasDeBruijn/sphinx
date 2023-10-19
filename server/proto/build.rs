use std::{fs, io};
use std::path::{Path, PathBuf};
use color_eyre::Result;

fn main() -> Result<()> {
    let mut config = prost_build::Config::new();

    println!("cargo:rerun-if-changed=protos/");

    config.protoc_arg("--experimental_allow_proto3_optional");
    config.type_attribute(".", r#"#[derive(serde::Serialize, serde::Deserialize)]"#);

    let proto_files = discover("protos/")?;
    let stringified_paths = proto_files
        .into_iter()
        .map(|x| x.to_string_lossy().to_string())
        .collect::<Vec<_>>();

    config.compile_protos(&stringified_paths, &["protos/"])?;

    Ok(())
}

fn discover<P: AsRef<Path>>(dir: P) -> io::Result<Vec<PathBuf>> {
    let mut dirs = Vec::new();
    let dir = fs::read_dir(dir)?;

    for entry in dir {
        let entry = entry?;
        let path = entry.path();

        if path.is_dir() {
            dirs.append(&mut discover(&path)?);
        } else if let Some(ext) = path.extension() {
            if ext.eq("proto") {
                dirs.push(path);
            }
        }
    }

    Ok(dirs)
}