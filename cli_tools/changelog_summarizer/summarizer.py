#!/usr/bin/env python3

from collections.abc import Sequence
from datetime import datetime
from typing import List, Optional, Union
import click
from pydantic.dataclasses import dataclass as py_dataclass
from pydantic import HttpUrl
from playwright.sync_api import (
    Playwright,
    APIRequestContext,
    sync_playwright,
    APIResponse,
)


@py_dataclass
class Author:
    login: str
    id: int
    node_id: str
    avatar_url: HttpUrl
    gravatar_id: str
    url: HttpUrl
    html_url: HttpUrl
    followers_url: HttpUrl
    following_url: HttpUrl
    gists_url: HttpUrl
    starred_url: HttpUrl
    subscriptions_url: HttpUrl
    organizations_url: HttpUrl
    repos_url: HttpUrl
    events_url: HttpUrl
    received_events_url: HttpUrl
    type: str
    site_admin: bool


@py_dataclass
class Asset:
    url: HttpUrl
    browser_download_url: HttpUrl
    id: int
    node_id: str
    name: str
    label: str
    state: str
    content_type: str
    size: int
    download_count: int
    created_at: datetime
    updated_at: datetime
    uploader: Author


# based on this: https://docs.github.com/en/rest/releases/releases#get-a-release-by-tag-name
@py_dataclass
class RepoRelease:
    url: HttpUrl
    html_url: HttpUrl
    assets_url: HttpUrl
    upload_url: HttpUrl
    tarball_url: HttpUrl
    zipball_url: HttpUrl
    id: int
    # till https://github.com/pydantic/pydantic/issues/692 is implemented
    node_id: str
    tag_name: str
    target_commitish: str
    name: str
    body: str
    draft: bool
    prerelease: bool
    created_at: datetime
    published_at: datetime
    author: Author
    assets: List[Asset]
    discussion_url: Optional[HttpUrl] = None


@py_dataclass
class RepoReleases:
    releases: List[RepoRelease]


def build_md(
    final_md_str: str,
    current_release: RepoRelease,
) -> str:
    final_md_str += f"# {current_release.tag_name}\n"
    final_md_str += f"{current_release.body}\n"
    return final_md_str


def repo_release_list(
    request_context: APIRequestContext,
    repo: str,
) -> RepoReleases:
    return RepoReleases(releases=request_context.get(f"/repos/{repo}/releases").json())


@click.command()
@click.argument(
    "repo",
)
@click.option(
    "-l",
    "--repo-list",
    is_flag=True,
)
@click.option(
    "-c",
    "--compare-release",
    default="latest",
    help="This is the release you'd like to compare against (default: latest)",
)
@click.option(
    "-o",
    "--output",
    default="-",
    help="Place to output contents",
    type=click.File("w"),
)
def main(
    repo: str,
    repo_list: bool,
    compare_release: str,
    output: click.File,
):
    """
    This script summarizes the changelog of a GitHub repository's releases
    the repo arguement is a string in this format: '<gh_username>/<gh_repo>'
    """
    click.echo(f"looking at: {repo}")
    with sync_playwright() as p:
        request_context = p.request.new_context(base_url="https://api.github.com/")
        if repo_list:
            click.echo(
                "\n".join(
                    [
                        release.tag_name
                        for release in repo_release_list(request_context, repo).releases
                    ]
                )
            )
        else:
            final_md_str = ""
            if compare_release == "latest":
                final_md_str = build_md(
                    final_md_str,
                    RepoRelease(
                        **request_context.get(f"/repos/{repo}/releases/latest").json()
                    ),
                )
            else:
                releases = repo_release_list(request_context, repo)
                stop_tag = RepoRelease(
                    **request_context.get(
                        f"/repos/{repo}/releases/tags/{compare_release}"
                    ).json()
                ).tag_name

                for release in releases.releases:
                    final_md_str = build_md(final_md_str, release)
                    if release.tag_name == stop_tag:
                        break

            click.echo(final_md_str, file=output)


if __name__ == "__main__":
    main()
