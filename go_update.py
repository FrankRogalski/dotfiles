import subprocess
import os
import concurrent.futures

gopath: str = subprocess.run(
    ["go", "env", "GOPATH"], capture_output=True, text=True
).stdout.strip()
bindir: str = os.path.join(gopath, "bin")


def get_mod_path(binary: str) -> str | None:
    result = subprocess.run(
        ["go", "version", "-m", os.path.join(bindir, binary)],
        capture_output=True,
        text=True,
    )
    for line in result.stdout.splitlines():
        parts: list[str] = line.split()
        if parts and parts[0] == "path":
            return parts[1]
    return None


def update(binary: str) -> str:
    mod_path: str | None = get_mod_path(binary)
    if mod_path:
        result = subprocess.run(
            ["go", "install", f"{mod_path}@latest"], capture_output=True, text=True
        )
        status: str = (
            "updated" if result.returncode == 0 else f"failed: {result.stderr.strip()}"
        )
        return f"{binary}: {status}"
    return f"{binary}: no module path found"


bins: list[str] = os.listdir(bindir)
print(f"Updating {len(bins)} go binaries in parallel...")
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    for result in executor.map(update, bins):
        print(result)
print("Done!")
