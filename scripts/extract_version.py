import sys
import requests
import yaml
import re

def strip_version_name(version_name):
    """
    Strip the version name to retain only the numeric part.
    """
    pattern = re.compile(r'\d+\.\d+\.\d+')
    match = pattern.search(version_name)
    if match:
        return match.group()
    return version_name  # Return the original if no match is found

def extract_current_version(yaml_file, version_key):
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)
        # Strip the version to its numeric part when extracting
        return strip_version_name(data[version_key])

def replace_version(yaml_file, version_key, new_version):
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)
    # Assume new_version is already stripped to numeric part
    data[version_key] = new_version
    with open(yaml_file, 'w') as file:
        yaml.dump(data, file, default_flow_style=False)

def get_latest_github_release(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    response = requests.get(url)
    response.raise_for_status()
    # Strip the version to its numeric part when fetching
    return strip_version_name(response.json()['tag_name'])

if __name__ == "__main__":
    yaml_file = sys.argv[1]
    version_key = sys.argv[2]
    owner = sys.argv[3]
    repo = sys.argv[4]
    should_update = sys.argv[5] == 'true'

    current_version = extract_current_version(yaml_file, version_key)
    latest_release = get_latest_github_release(owner, repo)

    print(f"::set-output name=current_version::{current_version}")
    print(f"::set-output name=latest_release::{latest_release}")

    if should_update and current_version != latest_release:
        # Only update if there's a change and if updating is enabled
        replace_version(yaml_file, version_key, latest_release)
        print("Version updated.")
