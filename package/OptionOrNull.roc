## Represents either a value, a missing field, or a null field
## Normally you would only need `Option` but this type exists for use with APIs that
## make a distinction between a json field being `null` and being missing altogether
##
## Ensure you set `nullAsUndefined` and `emptyEncodeAsNull` to false in your jsonOptions
## eg: `core.jsonwithoptions { emptyencodeasnull: bool.false, nullasundefined: bool.false }`
module [none, null, some, get, getResult, from]

import Core

OptionOrNull val := [Some val, None, Null]
    implements [
        Eq,
        Decoding {
            decoder: decoderRes,
        },
        Encoding {
            toEncoder: toEncoderRes,
        },
    ]

## Missing field
none = \{} -> @OptionOrNull (None)
## Null
null = \{} -> @OptionOrNull (Null)
## Some value
some = \val -> @OptionOrNull (Some val)

## Get option internals.
## For access to convinence methods and error accumulation you may want `Option.getResult`
get = \@OptionOrNull val -> val

## Option as a result
getResult = \@OptionOrNull val ->
    when val is
        Some v -> Ok v
        e -> Err e

from = \val -> @OptionOrNull val

nullChars = "null" |> Str.toUtf8

toEncoderRes = \@OptionOrNull val ->
    Encode.custom \bytes, fmt ->
        when val is
            Some contents -> bytes |> Encode.append contents fmt
            None -> bytes
            Null -> bytes |> List.concat (nullChars)

decoderRes = Decode.custom \bytes, fmt ->
    when bytes is
        [] -> { result: Ok (none {}), rest: [] }
        ['n', 'u', 'l', 'l', .. as rest] -> { result: Ok (null {}), rest: rest }
        _ ->
            when bytes |> Decode.decodeWith (Decode.decoder) fmt is
                { result: Ok res, rest } -> { result: Ok (some res), rest }
                { result: Err a, rest } -> { result: Err a, rest }

## Used to indicate to roc highlighting that a string is json
json = \a -> a

OptionTest : { name : OptionOrNull Str, lastName : OptionOrNull Str, age : U8 }
expect
    decoded : Result OptionTest _
    decoded =
        """
        {"name":null,"age":1}
        """
        |> json
        |> Str.toUtf8
        |> Decode.fromBytes (Core.jsonWithOptions { emptyEncodeAsNull: Core.encodeAsNullOption { record: Bool.false }, nullDecodeAsEmpty: Bool.false })

    expected = Ok ({ age: 1u8, name: null {}, lastName: none {} })
    expected == decoded

# Encode Option None record with null
expect
    encoded =
        dat : OptionTest
        dat = { lastName: none {}, name: null {}, age: 1 }
        dat
        |> Encode.toBytes (Core.jsonWithOptions { emptyEncodeAsNull: Core.encodeAsNullOption { record: Bool.false } })
        |> Str.fromUtf8

    expected =
        """
        {"age":1,"name":null}
        """
        |> json
        |> Ok
    expected == encoded

