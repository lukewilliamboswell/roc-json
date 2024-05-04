## Represents either a value, or nothing
## If you need to distinguish between a missing field and a `null` field you should use `OptionOrNull`
module [none, some, get, getResult, from, fromResult]

import Json

Option val := [Some val, None]
    implements [
        Eq,
        Decoding {
            decoder: decoderRes,
        },
        Encoding {
            toEncoder: toEncoderRes,
        },
    ]
## Missing or null
none = \{} -> @Option (None)
## A value
some = \val -> @Option (Some val)
get = \@Option val -> val
getResult = \@Option val -> val
## use like `Option.from Ok val`
from = \val -> @Option val
## Convert a result with any `Err` to an Option
fromResult : Result a * -> _
fromResult = \val ->
    when val is
        Ok a -> some a
        Err _ -> none {}

toEncoderRes = \@Option val ->
    Encode.custom \bytes, fmt ->
        when val is
            Some contents -> bytes |> Encode.append contents fmt
            None -> bytes

decoderRes = Decode.custom \bytes, fmt ->
    when bytes is
        [] -> { result: Ok (none {}), rest: [] }
        _ ->
            when bytes |> Decode.decodeWith (Decode.decoder) fmt is
                { result: Ok res, rest } -> { result: Ok (some res), rest }
                { result: Err a, rest } -> { result: Err a, rest }

## Used to indicate to roc highlighting that a string is json
json = \a -> a

OptionTest : { name : Str, lastName : Option Str, age : Option U8 }
expect
    decoded : Result OptionTest _
    decoded =
        """
        { "age":1, "name":"hi" }
        """
        |> json
        |> Str.toUtf8
        |> Decode.fromBytes Json.utf8

    expected = Ok ({ name: "hi", lastName: none {}, age: some 1u8 })
    expected == decoded

expect
    decoded : Result OptionTest _
    decoded =
        """
        { "age":1, "name":"hi", "lastName":null }
        """
        |> json
        |> Str.toUtf8
        |> Decode.fromBytes Json.utf8

    expected = Ok ({ name: "hi", lastName: none {}, age: some 1u8 })
    expected == decoded

# TODO restore these tests
# expect
#     toEncode : OptionTest
#     toEncode =
#         { name: "hi", lastName: none {}, age: some 1u8 }
#     encoded =
#         toEncode
#         |> Encode.toBytes Json.utf8
#         |> Str.fromUtf8

#     expected =
#         """
#         { "age":1, "name":"hi", "lastName":null }
#         """
#         |> json
#         |> Ok
#     expected == encoded

# expect
#     toEncode : OptionTest
#     toEncode =
#         { name: "hi", lastName: none {}, age: some 1u8 }
#     encoded =
#         toEncode
#         |> Encode.toBytes (Json.utf8With { emptyEncodeAsNull: Json.encodeAsNullOption { record: Bool.false } })
#         |> Str.fromUtf8

#     expected =
#         """
#         { "age":1, "name":"hi" }
#         """
#         |> json
#         |> Ok
#     expected == encoded
