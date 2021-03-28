#!/usr/bin/env python3

from typing import Optional,TextIO,List,Set

from fastapi import FastAPI
from fastapi.datastructures import UploadFile
from fastapi.params import File
import opml
from pydantic import BaseModel, HttpUrl
from starlette.requests import Request
from requests import get as r_get
import object_stor
import opml_lib
import rss_lib

from uvicorn import run as uvi_run

def convert_form_str(form_submission: list) -> Set:
    proper_set = set(form_submission[0].split(','))
    return proper_set

app = FastAPI()

@app.get("/")
async def read_root(request: Request) -> dict:
    return {"msg":"Checking out more info here: {}{}".format(request.base_url, app.docs_url[1:])}

@app.get("/rss")
async def list_rss() -> dict:
    all_items = object_stor.get_all('rss')
    print(all_items)
    return all_items

@app.get("/rss/{rss_md5}")
async def get_rss_specific_feed(rss_md5: str):
    return {"item_id": rss_md5}

class OpmlObj(BaseModel):
    opml_url: HttpUrl
    selected_shows: Set[str] = set()

@app.post("/opml/")
async def opml_file_url(
            opml_obj: OpmlObj
        ):
    opml_response = r_get(opml_obj.opml_url)
    rss_list = opml_lib.get_feeds(opml_response.content, opml_obj.selected_shows)
    return rss_list

@app.post("/opml_file/")
async def opml_file(
        opml_file: UploadFile = File(...),
        selected_shows: Optional[List[str]] = []
        ):
    if selected_shows:
        selected_shows = convert_form_str(selected_shows)
    opml_contents = await opml_file.read()
    rss_list = opml_lib.get_feeds(opml_contents, selected_shows)
    return rss_list

@app.get("/refresh")
async def refresh_rss():
    current_rss = ''
    return current_rss

if __name__ == "__main__":
    uvi_run(app, host="0.0.0.0", port=8000)
