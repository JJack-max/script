use std::path::Path;

fn main() {
    print_dir(Path::new("/workspace/script/solana/mini-redis"), 0);
}

fn print_dir(path: &Path, level: usize) {
    if path.exists() {
        let entries = path.read_dir().unwrap().map(|e| e.ok()).collect::<Vec<_>>();

        for entry in entries {
            let entry = entry.unwrap();
            println!(
                "{}{}",
                "——".repeat(level),
                entry.path().file_name().unwrap().to_str().unwrap()
            );
            if entry.path().is_dir() {
                print_dir(&entry.path(), level + 1);
            }
        }
    }
}
