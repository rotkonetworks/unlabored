# extract_version.py
import sys
import requests
import yaml

def extract_current_version(yaml_file, version_key):
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)
        return data[version_key]

def replace_version(yaml_file, version_key, new_version):
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)
    data[version_key] = new_version
    with open(yaml_file, 'w') as file:
        yaml.dump(data, file)

def get_latest_github_release(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    response = requests.get(url)
    response.raise_for_status()  # Ensure to raise an error for a bad response
    return response.json()['tag_name']

if __name__ == "__main__":
    yaml_file = sys.argv[1]
    version_key = sys.argv[2]
    owner = sys.argv[3]
    repo = sys.argv[4]
    should_update = sys.argv[5] == 'true'  # Expects 'true' or 'false'

    current_version = extract_current_version(yaml_file, version_key)
    latest_release = get_latest_github_release(owner, repo)

    print(f"::set-output name=current_version::{current_version}")
    print(f"::set-output name=latest_release::{latest_release}")

    if should_update and current_version != latest_release:
        replace_version(yaml_file, version_key, latest_release)
        print("Version updated.")
