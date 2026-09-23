"""Publish a tagged release and submit the Nimble registry entry from CI."""
import base64
import json
import os
from pathlib import Path
import re
import time
import urllib.error
import urllib.parse
import urllib.request


def api(path, data=None, method=None, missing_ok=False):
    token = os.environ.get("GH_TOKEN") or os.environ["CI_NETRC_PASSWORD"]
    request = urllib.request.Request(
        "https://api.github.com/" + path,
        data=None if data is None else json.dumps(data).encode(),
        headers={"Authorization": "Bearer " + token,
                 "Accept": "application/vnd.github+json",
                 "Content-Type": "application/json", "User-Agent": "nim-libs3-ci"},
        method=method)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        if missing_ok and error.code == 404:
            return None
        raise


def main():
    repo = os.environ["CI_REPO"]
    tag = os.environ["CI_COMMIT_TAG"]
    version = re.search(r'^version = "([^"]+)"', Path("libs3.nimble").read_text(), re.M)[1]
    if tag != "v" + version:
        raise SystemExit("Release tag does not match libs3.nimble version")
    if not api(f"repos/{repo}/releases/tags/{tag}", missing_ok=True):
        release = api(f"repos/{repo}/releases", {
            "tag_name": tag, "name": tag, "generate_release_notes": True,
            "body": "Nim bindings and synchronous client for libs3 4.1. "
                    "Requires a separately installed libs3 4.1 C library. "
                    "Validated with local HTTP and S3Proxy integration tests."})
        print("Release:", release["html_url"], flush=True)
    upstream = "nim-lang/packages"
    entry = {"name": "libs3", "url": f"https://github.com/{repo}",
             "method": "git", "tags": ["s3", "aws", "bindings", "storage"],
             "description": "Nim bindings and synchronous client for bji/libs3 4.1",
             "license": "MIT", "web": f"https://github.com/{repo}"}
    source = api(f"repos/{upstream}/contents/packages.json")
    original = base64.b64decode(source["content"]).decode()
    for package in json.loads(original):
        if package["name"].lower().replace("_", "") == "libs3":
            if package.get("url") != entry["url"]:
                raise SystemExit("The libs3 package name is already registered to another URL")
            print("Package is already registered")
            return
    owner = api("user")["login"]
    branch = "add-nim-libs3"
    prs = api(f"repos/{upstream}/pulls?" + urllib.parse.urlencode({
        "state": "open", "head": f"{owner}:{branch}"}))
    if prs:
        print("Registry pull request:", prs[0]["html_url"])
        return
    fork = f"{owner}/packages"
    if not api(f"repos/{fork}", missing_ok=True):
        api(f"repos/{upstream}/forks", {})
        for attempt in range(30):
            if api(f"repos/{fork}", missing_ok=True):
                break
            time.sleep(2)
        else:
            raise SystemExit("GitHub fork did not become available")
    if not api(f"repos/{fork}/git/ref/heads/{branch}", missing_ok=True):
        default = api(f"repos/{upstream}")["default_branch"]
        sha = api(f"repos/{upstream}/git/ref/heads/{default}")["object"]["sha"]
        api(f"repos/{fork}/git/refs", {"ref": f"refs/heads/{branch}", "sha": sha})
    current = api(f"repos/{fork}/contents/packages.json?ref={branch}")
    text = base64.b64decode(current["content"]).decode()
    if not any(p["name"] == "libs3" for p in json.loads(text)):
        addition = "\n".join("  " + line for line in json.dumps(entry, indent=2).splitlines())
        updated = text.rstrip()[:-1].rstrip() + ",\n" + addition + "\n]\n"
        json.loads(updated)
        api(f"repos/{fork}/contents/packages.json", {
            "message": "Add libs3 package", "branch": branch, "sha": current["sha"],
            "content": base64.b64encode(updated.encode()).decode()}, method="PUT")
    pr = api(f"repos/{upstream}/pulls", {
        "title": "Add libs3: Nim bindings for bji/libs3",
        "head": f"{owner}:{branch}",
        "base": api(f"repos/{upstream}")["default_branch"],
        "body": f"Adds [{repo}](https://github.com/{repo}), released as {tag}.\n\n"
                "Provides raw bindings and a synchronous S3 client. Requires system libs3 4.1. "
                "Woodpecker validates the local HTTP suite, S3Proxy suite, and release build. "
                "Original wrapper code is MIT; upstream licensing notices are included."})
    print("Registry pull request:", pr["html_url"])


if __name__ == "__main__":
    main()
