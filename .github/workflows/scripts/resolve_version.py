#!/usr/bin/env python3
"""Resolve the version name and build number to use for this TestFlight upload.

App Store Connect rejects an upload (error 90062) when CFBundleShortVersionString
is not higher than the last approved version, rejects a version whose TestFlight
train is closed (error 90186), and rejects duplicate build numbers (error 90360).
This script asks App Store Connect what already exists and picks the next free
pair, so a stale pubspec.yaml version can never fail the workflow.

A version is "taken" if it exists as an App Store version *or* as a pre-release
(TestFlight) train. Only asking about the former is how this script used to hand
back a train that had already shipped to testers: those trains close, and a
closed train rejects every further build.

Inputs (environment):
  APP_STORE_CONNECT_KEY_ID, APP_STORE_CONNECT_ISSUER_ID, APP_STORE_CONNECT_API_KEY_P8
  APP_BUNDLE_ID           - bundle id extracted from the provisioning profile
  INPUT_BUILD_NAME        - manual override, wins as-is when set
  INPUT_BUILD_NUMBER      - manual override, wins as-is when set
  PUBSPEC_PATH            - path to pubspec.yaml (version: x.y.z+n)

Writes BUILD_NAME / BUILD_NUMBER to $GITHUB_ENV.
"""

import base64
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

import jwt

API = "https://api.appstoreconnect.apple.com/v1"


def log(msg):
    print(msg, flush=True)


def make_token():
    key_id = os.environ["APP_STORE_CONNECT_KEY_ID"]
    issuer_id = os.environ["APP_STORE_CONNECT_ISSUER_ID"]
    private_key = base64.b64decode(os.environ["APP_STORE_CONNECT_API_KEY_P8"]).decode()
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 15 * 60,
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})


def get(path, token):
    req = urllib.request.Request(
        f"{API}/{path}", headers={"Authorization": f"Bearer {token}"}
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)


def parse_version(text):
    parts = re.findall(r"\d+", text or "")
    nums = [int(p) for p in parts[:3]]
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums)


def format_version(nums):
    return ".".join(str(n) for n in nums)


def pubspec_version(path):
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            if line.startswith("version:"):
                return line.split(":", 1)[1].strip().split("+")[0]
    return "1.0.0"


def emit(build_name, build_number):
    log(f"Resolved version: {build_name} ({build_number})")
    with open(os.environ["GITHUB_ENV"], "a", encoding="utf-8") as handle:
        handle.write(f"BUILD_NAME={build_name}\n")
        handle.write(f"BUILD_NUMBER={build_number}\n")


def main():
    manual_name = os.environ.get("INPUT_BUILD_NAME", "").strip()
    manual_number = os.environ.get("INPUT_BUILD_NUMBER", "").strip()
    local_name = manual_name or pubspec_version(os.environ["PUBSPEC_PATH"])

    if manual_name and manual_number:
        emit(manual_name, manual_number)
        return

    try:
        token = make_token()
        bundle_id = os.environ["APP_BUNDLE_ID"]
        apps = get(f"apps?filter[bundleId]={bundle_id}&limit=1", token)["data"]
        if not apps:
            raise RuntimeError(f"No App Store Connect app found for {bundle_id}")
        app_id = apps[0]["id"]

        versions = get(f"apps/{app_id}/appStoreVersions?limit=200", token)["data"]
        remote_versions = [v["attributes"]["versionString"] for v in versions]

        # TestFlight trains. A build uploaded here never becomes an App Store
        # version until it is released, so this is the list that actually says
        # which version strings are spent.
        trains = get(
            f"apps/{app_id}/preReleaseVersions?limit=200&filter[platform]=IOS",
            token,
        )["data"]
        remote_trains = [t["attributes"]["version"] for t in trains]

        builds = get(f"builds?filter[app]={app_id}&limit=200", token)["data"]
        remote_builds = [int(b["attributes"]["version"]) for b in builds
                         if str(b["attributes"]["version"]).isdigit()]
    except Exception as exc:  # noqa: BLE001 - never block the build on lookup issues
        log(f"::warning::Could not query App Store Connect ({exc}). "
            f"Falling back to local version.")
        emit(local_name, manual_number or os.environ.get("GITHUB_RUN_NUMBER", "1"))
        return

    log(f"App Store versions: {sorted(remote_versions) or 'none'}")
    log(f"TestFlight trains: {sorted(remote_trains) or 'none'}")
    log(f"Highest existing build number: {max(remote_builds) if remote_builds else 'none'}")

    taken = {parse_version(v) for v in remote_versions + remote_trains}
    highest = max(taken, default=(0, 0, 0))
    candidate = parse_version(local_name)
    if candidate <= highest:
        candidate = (highest[0], highest[1], highest[2] + 1)
        log(f"Local version {local_name} is not higher than {format_version(highest)}; "
            f"bumping to {format_version(candidate)}.")

    # Guard against a gap in what the API reports: walk past anything already
    # taken rather than handing back a version that will be rejected.
    while candidate in taken:
        candidate = (candidate[0], candidate[1], candidate[2] + 1)
        log(f"Version {format_version(candidate)} chosen; the previous one is taken.")

    if manual_name and parse_version(manual_name) != candidate:
        log(f"::warning::Requested version {manual_name} is not free; "
            f"uploading as {format_version(candidate)} instead.")

    build_number = manual_number or str(
        max(remote_builds + [int(os.environ.get("GITHUB_RUN_NUMBER", "0"))]) + 1
    )
    emit(format_version(candidate), build_number)


if __name__ == "__main__":
    sys.exit(main())
