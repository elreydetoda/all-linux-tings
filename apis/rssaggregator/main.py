#!/usr/bin/env python3

from typing import Optional,TextIO

from fastapi import FastAPI
from fastapi.datastructures import UploadFile
from pydantic import BaseModel, HttpUrl
from starlette.requests import Request

from uvicorn import run as uvi_run

app = FastAPI()

@app.get("/")
async def read_root(request: Request) -> dict:
    return {"msg":"Checking out more info here: {}{}".format(request.base_url, app.docs_url[1:])}

@app.get("/rss/")
async def list_rss() -> dict:
    all_items = ''
    # object_stor.get_all()
    return all_items

@app.get("/rss/{rss_md5}")
async def get_rss_specific_feed(rss_md5: str):
    return {"item_id": rss_md5}

class OpmlUrl(BaseModel):
    url: HttpUrl
    selected_shows: Optional[list]

@app.post("/opml/")
async def opml_file_url(opml_url: OpmlUrl ):
    print(opml_url)
    return opml_url

class OpmlFile(BaseModel):
    opml_file: UploadFile
    selected_shows: Optional[list]

@app.post("/opml_file/")
async def opml_file(opml_file: OpmlFile ):
    return opml_file

if __name__ == "__main__":
    uvi_run(app, host="0.0.0.0", port=8000)
