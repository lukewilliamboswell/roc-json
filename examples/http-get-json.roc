app [main!] {
    # TODO restore with basic-cli release
    pf: platform "../../basic-cli/platform/main.roc",
    json: "../package/main.roc", # use release URL (ends in tar.br) for local example, see github.com/lukewilliamboswell/roc-json/releases
}

# To run this example: check the README.md in this folder

import pf.Http
import pf.Stdout
import json.Json

# HTTP GET request with easy decoding to json
main! = \_args ->

    # Easy decoding/deserialization of { "foo": "something" } into a Roc var
    { foo } = Http.get!("http://localhost:8000", Json.utf8)?
    # If you want to see an example of the server side, see basic-cli/ci/rust_http_server/src/main.rs

    Stdout.line! "The json I received was: { foo: \"${foo}\" }"
