# /// script
# requires-python = ">=3.12,<3.13"
# dependencies = [
#     "click>=8.1.7",
#     "pydantic>=2.9.2",
#     "requests>=2.32.3",
# ]
# [tool.uv]
# python-preference = "only-managed"
# ///

## Run this (PEP 723 compliant) script with: uv run --script jwt_refresh.py
# pylint: disable=missing-module-docstring

import sys
from dataclasses import asdict
from datetime import datetime, timedelta
from time import sleep
from pydantic import BaseModel
from pydantic.dataclasses import dataclass as py_dataclass

# pylint: disable=multiple-imports
import requests, click, urllib3

# bypass warning for using burp's cert
urllib3.disable_warnings()

# debug responses if needed
DEBUG = False


@py_dataclass
class RefreshPostData:
    """
    Data required for POST request to refresh token
    """

    grant_type: str
    refresh_token: str
    client_id: str


class RefreshTokenResponse(BaseModel):
    """
    Fields needed (and some optional) from the response of the refresh token request
    """

    access_token: str
    token_type: str
    expires_in: int
    refresh_token: str
    scope: str | None = None
    refresh_expires_in: int | None = None


def __response_debug(response: requests.Response):
    if DEBUG:
        print(response.text, file=sys.stderr)
        print("\n\n")


def _refresh_token_req(
    burp: str,
    url: str,
    grant_type: str,
    refresh_token: str,
    client_id: str,
) -> requests.Response:
    return requests.post(
        url,
        data=asdict(
            RefreshPostData(
                grant_type=grant_type,
                refresh_token=refresh_token,
                client_id=client_id,
            )
        ),
        timeout=300,
        proxies={"https": burp, "http": burp},
        verify=False,
    )


def wait_for_refresh_time(refresh_time: int):
    """
    function to wait for the refresh time to expire
    """

    countdown = int(refresh_time * 0.85)
    # Get the number of digits in the initial countdown value
    num_digits = len(str(countdown))
    print(f"expiration time is {refresh_time} seconds")
    print(f"refreshing token at {countdown} seconds\n\n")
    print(
        f"refresh time will be at {datetime.now() + timedelta(seconds=countdown)}\n\n"
    )

    print("Seconds left:")
    try:
        # Loop until countdown reaches 0
        while countdown >= 0:
            print(f"\r{countdown:0{num_digits}d}", end="")
            # Decrease the countdown value by 1
            countdown -= 1
            # Pause for 1 second
            sleep(1)
    except KeyboardInterrupt:
        # allows you to refresh your token early
        exiting = input("\n\nExit?(y/N): ")
        if exiting.lower() == "y":
            exit(0)

    print("\nRefreshing token now...")


@click.command()
@click.option(
    "--burp",
    default="http://127.0.0.1:8080",
    help="Burp proxy string (default: http://127.0.0.1:8080)",
)
@click.option(
    "-d",
    "--debug/--no-debug",
    default=False,
    help="Debug mode",
)
@click.option(
    "--grant-type",
    default="refresh_token",
    help="Grant type (default: refresh_token)",
)
@click.option(
    "--client-id",
    type=str,
    required=True,
    help="Client ID",
)
@click.option(
    "--refresh-token",
    type=str,
    required=True,
    prompt=True,
    help="Refresh token",
)
@click.option(
    "--refresh-url",
    type=str,
    required=True,
    prompt=True,
)
# pylint: disable=missing-function-docstring,too-many-arguments
def main(
    burp: str,
    debug: bool,
    grant_type: str,
    refresh_token: str,
    client_id: str,
    refresh_url,
):
    # pylint: disable=global-statement
    global DEBUG
    DEBUG = debug
    jwt = None
    while True:
        response = _refresh_token_req(
            burp,
            refresh_url,
            grant_type,
            refresh_token,
            client_id,
        )
        __response_debug(response=response)

        data = RefreshTokenResponse.model_validate_json(response.text)
        if jwt:
            print(f"Old JWT: {jwt}")

        # access_token
        jwt = data.access_token
        print(f"\n{jwt=}\n\n")

        print(f"Old refresh token: {refresh_token}")
        refresh_token = data.refresh_token
        print(f"{refresh_token=}")

        wait_for_refresh_time(data.expires_in)


if __name__ == "__main__":
    # pylint: disable=no-value-for-parameter
    main()
