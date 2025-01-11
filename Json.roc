module [
    Json,
    utf8,
    utf8_with,
    encode_as_null_option,
]

expect
    input : List U8
    input = Str.to_utf8("{\"first_segment\":\"ab\"}")

    actual : DecodeResult { first_segment : Str }
    actual = Decode.from_bytes_partial(input, @Json({}))

    expected : DecodeResult { first_segment : Str }
    expected = { rest: [], result: Ok({ first_segment: "ab" }) }

    actual == expected

## An opaque type with the `Encode.EncoderFormatting` and
## `DecoderFormatting` abilities.
Json := { field_name_mapping : FieldNameMapping, skip_missing_properties : Bool, null_decode_as_empty : Bool, empty_encode_as_null : EncodeAsNull }
    implements [
        Encode.EncoderFormatting {
            u8: encode_u8,
            u16: encode_u16,
            u32: encode_u32,
            u64: encode_u64,
            u128: encode_u128,
            i8: encode_i8,
            i16: encode_i16,
            i32: encode_i32,
            i64: encode_i64,
            i128: encode_i128,
            f32: encode_f32,
            f64: encode_f64,
            dec: encode_dec,
            bool: encode_bool,
            string: encode_string,
            list: encode_list,
            record: encode_record,
            tuple: encode_tuple,
            tag: encode_tag,
        },
        DecoderFormatting {
            u8: decode_u8,
            u16: decode_u16,
            u32: decode_u32,
            u64: decode_u64,
            u128: decode_u128,
            i8: decode_i8,
            i16: decode_i16,
            i32: decode_i32,
            i64: decode_i64,
            i128: decode_i128,
            f32: decode_f32,
            f64: decode_f64,
            dec: decode_dec,
            bool: decode_bool,
            string: decode_string,
            list: decode_list,
            record: decode_record,
            tuple: decode_tuple,
        },
    ]

## Returns a JSON `Encode.Encoder` and `Decoder`
utf8 = @Json({ field_name_mapping: Default, skip_missing_properties: Bool.true, null_decode_as_empty: Bool.true, empty_encode_as_null: default_encode_as_null })

## Returns a JSON `Encode.Encoder` and `Decoder` with configuration options
##
## **skip_missing_properties** - if `True` the decoder will skip additional properties
## in the json that are not present in the model. (Default: `True`)
##
## **null_decode_as_empty** - if `True` the decoder will convert `null` to an empty byte array.
## This makes `{"email":null,"name":"bob"}` decode the same as `{"name":"bob"}`. (Default: `True`)
##
## **empty__encode_as_null** - if `True` encoders that return `[]` will result in a `null` in the
## json. If `False` when an encoder returns `[]` the record field, or list/tuple element, will be ommitted.
## eg: `{email:@Option None, name:"bob"}` encodes to `{"email":null, "name":"bob"}` instead of `{"name":"bob"}` (Default: `True`)

utf8_with : { field_name_mapping ?? FieldNameMapping, skip_missing_properties ?? Bool, null_decode_as_empty ?? Bool, empty_encode_as_null ?? EncodeAsNull } -> Json
utf8_with = \{ field_name_mapping ?? Default, skip_missing_properties ?? Bool.true, null_decode_as_empty ?? Bool.true, empty_encode_as_null ?? default_encode_as_null } ->
    @Json({ field_name_mapping, skip_missing_properties, null_decode_as_empty, empty_encode_as_null })

EncodeAsNull : {
    list : Bool,
    tuple : Bool,
    record : Bool,
}

encode_as_null_option : { list ?? Bool, tuple ?? Bool, record ?? Bool } -> EncodeAsNull
encode_as_null_option = \{ list ?? Bool.false, tuple ?? Bool.true, record ?? Bool.true } -> {
    list,
    tuple,
    record,
}
default_encode_as_null = {
    list: Bool.false,
    tuple: Bool.true,
    record: Bool.true,
}
## Mapping between Roc record fields and JSON object names
FieldNameMapping : [
    Default, # no transformation
    SnakeCase, # snake_case
    PascalCase, # PascalCase
    KebabCase, # kabab-case
    CamelCase, # camelCase
    Custom (Str -> Str), # provide a custom formatting
]

encode_u8 : U8 -> Encoder Json
encode_u8 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u16 : U16 -> Encoder Json
encode_u16 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u32 : U32 -> Encoder Json
encode_u32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u64 : U64 -> Encoder Json
encode_u64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_u128 : U128 -> Encoder Json
encode_u128 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i8 : I8 -> Encoder Json
encode_i8 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i16 : I16 -> Encoder Json
encode_i16 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i32 : I32 -> Encoder Json
encode_i32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i64 : I64 -> Encoder Json
encode_i64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_i128 : I128 -> Encoder Json
encode_i128 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_f32 : F32 -> Encoder Json
encode_f32 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_f64 : F64 -> Encoder Json
encode_f64 = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_dec : Dec -> Encoder Json
encode_dec = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_bool : Bool -> Encoder Json
encode_bool = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_string : Str -> Encoder Json
encode_string = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_list : List elem, (elem -> Encoder Json) -> Encoder Json
encode_list = \_, _ -> Encode.custom(\bytes, _ -> bytes)

encode_record : List { key : Str, value : Encoder Json } -> Encoder Json
encode_record = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_tuple : List (Encoder Json) -> Encoder Json
encode_tuple = \_ -> Encode.custom(\bytes, _ -> bytes)

encode_tag : Str, List (Encoder Json) -> Encoder Json
encode_tag = \_, _ -> Encode.custom(\bytes, _ -> bytes)

decode_u8 : Decoder U8 Json
decode_u8 = Decode.custom(\bytes, _ -> { result: Ok(1u8), rest: bytes })

decode_u16 : Decoder U16 Json
decode_u16 = Decode.custom(\bytes, _ -> { result: Ok(1u16), rest: bytes })

decode_u32 : Decoder U32 Json
decode_u32 = Decode.custom(\bytes, _ -> { result: Ok(1u32), rest: bytes })

decode_u64 : Decoder U64 Json
decode_u64 = Decode.custom(\bytes, _ -> { result: Ok(1u64), rest: bytes })

decode_u128 : Decoder U128 Json
decode_u128 = Decode.custom(\bytes, _ -> { result: Ok(1u128), rest: bytes })

decode_i8 : Decoder I8 Json
decode_i8 = Decode.custom(\bytes, _ -> { result: Ok(1i8), rest: bytes })

decode_i16 : Decoder I16 Json
decode_i16 = Decode.custom(\bytes, _ -> { result: Ok(1i16), rest: bytes })

decode_i32 : Decoder I32 Json
decode_i32 = Decode.custom(\bytes, _ -> { result: Ok(1i32), rest: bytes })

decode_i64 : Decoder I64 Json
decode_i64 = Decode.custom(\bytes, _ -> { result: Ok(1i64), rest: bytes })

decode_i128 : Decoder I128 Json
decode_i128 = Decode.custom(\bytes, _ -> { result: Ok(1i128), rest: bytes })

decode_f32 : Decoder F32 Json
decode_f32 = Decode.custom(\bytes, _ -> { result: Ok(1f32), rest: bytes })

decode_f64 : Decoder F64 Json
decode_f64 = Decode.custom(\bytes, _ -> { result: Ok(1f64), rest: bytes })

decode_dec : Decoder Dec Json
decode_dec = Decode.custom(\bytes, _ -> { result: Ok(1dec), rest: bytes })

decode_bool : Decoder Bool Json
decode_bool = Decode.custom(\bytes, _ -> { result: Ok(Bool.true), rest: bytes })

decode_tuple : state, (state, U64 -> [Next (Decoder state fmt), TooLong]), (state -> Result val DecodeError) -> Decoder val fmt
decode_tuple = \initial_state, step_elem, finalizer ->
    Decode.custom(
        \initial_bytes, json_fmt ->
            # NB: the stepper function must be passed explicitly until #2894 is resolved.
            decode_elems = \stepper, state, index, bytes ->
                decode_attempt =
                    when stepper(state, index) is
                        TooLong ->
                            bytes
                            |> anything
                            |> try_decode(
                                \{ rest: before_comma_or_break } ->
                                    { result: Ok(state), rest: before_comma_or_break },
                            )

                        Next(decoder) ->
                            decode_potential_null(eat_whitespace(bytes), decoder, json_fmt)

                try_decode(
                    decode_attempt,
                    \{ val: new_state, rest: before_comma_or_break } ->
                        { result: comma_result, rest: next_bytes } = comma(before_comma_or_break)

                        when comma_result is
                            Ok({}) -> decode_elems(step_elem, new_state, (index + 1), next_bytes)
                            Err(_) -> { result: Ok(new_state), rest: next_bytes },
                )

            initial_bytes
            |> open_bracket
            |> try_decode(
                \{ rest: after_bracket_bytes } ->
                    decode_elems(step_elem, initial_state, 0, eat_whitespace(after_bracket_bytes))
                    |> try_decode(
                        \{ val: end_state_result, rest: before_closing_bracket_bytes } ->
                            (eat_whitespace(before_closing_bracket_bytes))
                            |> closing_bracket
                            |> try_decode(
                                \{ rest: after_tuple_bytes } ->
                                    when finalizer(end_state_result) is
                                        Ok(val) -> { result: Ok(val), rest: after_tuple_bytes }
                                        Err(e) -> { result: Err(e), rest: after_tuple_bytes },
                            ),
                    ),
            ),
    )

parse_exact_char : List U8, U8 -> DecodeResult {}
parse_exact_char = \bytes, char ->
    when List.get(bytes, 0) is
        Ok(c) ->
            if
                c == char
            then
                { result: Ok({}), rest: (List.split_at(bytes, 1)).others }
            else
                { result: Err(TooShort), rest: bytes }

        Err(_) -> { result: Err(TooShort), rest: bytes }

open_bracket : List U8 -> DecodeResult {}
open_bracket = \bytes -> parse_exact_char(bytes, '[')

closing_bracket : List U8 -> DecodeResult {}
closing_bracket = \bytes -> parse_exact_char(bytes, ']')

anything : List U8 -> DecodeResult {}
anything = \bytes -> { result: Err(TooShort), rest: bytes }

comma : List U8 -> DecodeResult {}
comma = \bytes -> parse_exact_char(bytes, ',')

try_decode : DecodeResult a, ({ val : a, rest : List U8 } -> DecodeResult b) -> DecodeResult b
try_decode = \{ result, rest }, mapper ->
    when result is
        Ok(val) -> mapper({ val, rest })
        Err(e) -> { result: Err(e), rest }

# JSON NUMBER PRIMITIVE --------------------------------------------------------

# Takes the bytes for a valid Json number primitive into a RocStr
#
# Note that this does not handle leading whitespace, any whitespace must be
# handled in json list or record decoding.
#
# |> List.drop_if(\b -> b == '+')
# TODO ^^ not needed if roc supports "1e+2", this supports
# "+" which is permitted in Json numbers
#
# |> List.map(\b -> if b == 'E' then 'e' else b)
# TODO ^^ not needed if roc supports "1E2", this supports
# "E" which is permitted in Json numbers
take_json_number : List U8 -> { taken : List U8, rest : List U8 }
take_json_number = \bytes ->
    when List.walk_until(bytes, Start, number_help) is
        Finish(n) | Zero(n) | Integer(n) | FractionB(n) | ExponentC(n) ->
            taken =
                bytes
                |> List.sublist({ start: 0, len: n })
                |> List.drop_if(\b -> b == '+')
                |> List.map(\b -> if b == 'E' then 'e' else b)

            { taken, rest: List.drop_first(bytes, n) }

        _ ->
            { taken: [], rest: bytes }

number_help : NumberState, U8 -> [Continue NumberState, Break NumberState]
number_help = \state, byte ->
    when (state, byte) is
        (Start, b) if b == '0' -> Continue(Zero(1))
        (Start, b) if b == '-' -> Continue(Minus(1))
        (Start, b) if is_digit1to9(b) -> Continue(Integer(1))
        (Minus(n), b) if b == '0' -> Continue(Zero((n + 1)))
        (Minus(n), b) if is_digit1to9(b) -> Continue(Integer((n + 1)))
        (Zero(n), b) if b == '.' -> Continue(FractionA((n + 1)))
        (Zero(n), b) if is_valid_end(b) -> Break(Finish(n))
        (Integer(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(Integer((n + 1)))
        (Integer(n), b) if b == '.' && n < max_bytes -> Continue(FractionA((n + 1)))
        (Integer(n), b) if is_valid_end(b) && n <= max_bytes -> Break(Finish(n))
        (FractionA(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(FractionB((n + 1)))
        (FractionB(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(FractionB((n + 1)))
        (FractionB(n), b) if b == 'e' || b == 'E' && n <= max_bytes -> Continue(ExponentA((n + 1)))
        (FractionB(n), b) if is_valid_end(b) && n <= max_bytes -> Break(Finish(n))
        (ExponentA(n), b) if b == '-' || b == '+' && n <= max_bytes -> Continue(ExponentB((n + 1)))
        (ExponentA(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(ExponentC((n + 1)))
        (ExponentB(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(ExponentC((n + 1)))
        (ExponentC(n), b) if is_digit0to9(b) && n <= max_bytes -> Continue(ExponentC((n + 1)))
        (ExponentC(n), b) if is_valid_end(b) && n <= max_bytes -> Break(Finish(n))
        _ -> Break(Invalid)

NumberState : [
    Start,
    Minus U64,
    Zero U64,
    Integer U64,
    FractionA U64,
    FractionB U64,
    ExponentA U64,
    ExponentB U64,
    ExponentC U64,
    Invalid,
    Finish U64,
]

# TODO confirm if we would like to be able to decode
# "340282366920938463463374607431768211455" which is MAX U128 and 39 bytes
max_bytes : U64
max_bytes = 21 # Max bytes in a double precision float

is_digit0to9 : U8 -> Bool
is_digit0to9 = \b -> b >= '0' && b <= '9'

is_digit1to9 : U8 -> Bool
is_digit1to9 = \b -> b >= '1' && b <= '9'

is_valid_end : U8 -> Bool
is_valid_end = \b ->
    when b is
        ']' | ',' | ' ' | '\n' | '\r' | '\t' | '}' -> Bool.true
        _ -> Bool.false

# JSON STRING PRIMITIVE --------------------------------------------------------

# Decode a Json string primitive into a RocStr
#
# Note that decode_str does not handle leading whitespace, any whitespace must be
# handled in json list or record decodin.
decode_string = Decode.custom(
    \bytes, @Json({}) ->

        { taken: str_bytes, rest } = take_json_string(bytes)

        if List.is_empty(str_bytes) then
            { result: Err(TooShort), rest: bytes }
        else
            # Remove starting and ending quotation marks, replace unicode
            # escpapes with Roc equivalent, and try to parse RocStr from
            # bytes
            result =
                str_bytes
                |> List.sublist(
                    {
                        start: 1,
                        len: Num.sub_saturated(List.len(str_bytes), 2),
                    },
                )
                |> \bytes_without_quotation_marks ->
                    replace_escaped_chars({ in_bytes: bytes_without_quotation_marks, out_bytes: [] })
                |> .out_bytes
                |> Str.from_utf8

            when result is
                Ok(str) ->
                    { result: Ok(str), rest }

                Err(_) ->
                    { result: Err(TooShort), rest: bytes },
)

take_json_string : List U8 -> { taken : List U8, rest : List U8 }
take_json_string = \bytes ->
    when List.walk_until(bytes, Start, string_help) is
        Finish(n) ->
            {
                taken: List.sublist(bytes, { start: 0, len: n }),
                rest: List.drop_first(bytes, n),
            }

        _ ->
            { taken: [], rest: bytes }

string_help : StringState, U8 -> [Continue StringState, Break StringState]
string_help = \state, byte ->
    when (state, byte) is
        (Start, b) if b == '"' -> Continue(Chars(1))
        (Chars(n), b) if b == '"' -> Break(Finish((n + 1)))
        (Chars(n), b) if b == '\\' -> Continue(Escaped((n + 1)))
        (Chars(n), _) -> Continue(Chars((n + 1)))
        (Escaped(n), b) if is_escaped_char(b) -> Continue(Chars((n + 1)))
        (Escaped(n), b) if b == 'u' -> Continue(UnicodeA((n + 1)))
        (UnicodeA(n), b) if is_hex(b) -> Continue(UnicodeB((n + 1)))
        (UnicodeB(n), b) if is_hex(b) -> Continue(UnicodeC((n + 1)))
        (UnicodeC(n), b) if is_hex(b) -> Continue(UnicodeD((n + 1)))
        (UnicodeD(n), b) if is_hex(b) -> Continue(Chars((n + 1)))
        _ -> Break(InvalidNumber)

StringState : [
    Start,
    Chars U64,
    Escaped U64,
    UnicodeA U64,
    UnicodeB U64,
    UnicodeC U64,
    UnicodeD U64,
    Finish U64,
    InvalidNumber,
]

is_escaped_char : U8 -> Bool
is_escaped_char = \b ->
    when b is
        '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' -> Bool.true
        _ -> Bool.false

escaped_char_from_json : U8 -> U8
escaped_char_from_json = \b ->
    when b is
        '"' -> 0x22 # U+0022 Quotation mark
        '\\' -> 0x5c # U+005c Reverse solidus
        '/' -> 0x2f # U+002f Solidus
        'b' -> 0x08 # U+0008 Backspace
        'f' -> 0x0c # U+000c Form feed
        'n' -> 0x0a # U+000a Line feed
        'r' -> 0x0d # U+000d Carriage return
        't' -> 0x09 # U+0009 Tab
        _ -> b

is_hex : U8 -> Bool
is_hex = \b ->
    (b >= '0' && b <= '9')
    || (b >= 'a' && b <= 'f')
    || (b >= 'A' && b <= 'F')

json_hex_to_decimal : U8 -> U8
json_hex_to_decimal = \b ->
    if b >= '0' && b <= '9' then
        b - '0'
    else if b >= 'a' && b <= 'f' then
        b - 'a' + 10
    else if b >= 'A' && b <= 'F' then
        b - 'A' + 10
    else
        crash("got an invalid hex char")

# decimal_hex_to_byte : U8, U8 -> U8
# decimal_hex_to_byte = \upper, lower ->
#    Num.bitwise_or(Num.shift_left_by(upper, 4), lower)

hex_to_utf8 : U8, U8, U8, U8 -> List U8
hex_to_utf8 = \a, b, c, d ->
    i = json_hex_to_decimal(a)
    j = json_hex_to_decimal(b)
    k = json_hex_to_decimal(c)
    l = json_hex_to_decimal(d)

    cp = (16 * 16 * 16 * Num.to_u32(i)) + (16 * 16 * Num.to_u32(j)) + (16 * Num.to_u32(k)) + Num.to_u32(l)
    codepoint_to_utf8(cp)

# Copied from https://github.com/roc-lang/unicode/blob/e1162d49e3a2c57ed711ecdee7dc8537a19479d8/
# from package/CodePoint.roc and modified
codepoint_to_utf8 : U32 -> List U8
codepoint_to_utf8 = \u32 ->
    if u32 < 0x80 then
        [Num.to_u8(u32)]
    else if u32 < 0x800 then
        byte1 =
            u32
            |> Num.shift_right_by(6)
            |> Num.bitwise_or(0b11000000)
            |> Num.to_u8

        byte2 =
            u32
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        [byte1, byte2]
    else if u32 < 0x10000 then
        byte1 =
            u32
            |> Num.shift_right_by(12)
            |> Num.bitwise_or(0b11100000)
            |> Num.to_u8

        byte2 =
            u32
            |> Num.shift_right_by(6)
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        byte3 =
            u32
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        [byte1, byte2, byte3]
    else if u32 < 0x110000 then
        ## This was an invalid Unicode scalar value, even though it had the Roc type Scalar.
        ## This should never happen!
        # expect u32 < 0x110000
        crash("Impossible")
    else
        byte1 =
            u32
            |> Num.shift_right_by(18)
            |> Num.bitwise_or(0b11110000)
            |> Num.to_u8

        byte2 =
            u32
            |> Num.shift_right_by(12)
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        byte3 =
            u32
            |> Num.shift_right_by(6)
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        byte4 =
            u32
            |> Num.bitwise_and(0b111111)
            |> Num.bitwise_or(0b10000000)
            |> Num.to_u8

        [byte1, byte2, byte3, byte4]

unicode_replacement = [0xEF, 0xBF, 0xBD]

replace_escaped_chars : { in_bytes : List U8, out_bytes : List U8 } -> { in_bytes : List U8, out_bytes : List U8 }
replace_escaped_chars = \{ in_bytes, out_bytes } ->

    first_byte = List.get(in_bytes, 0)
    second_byte = List.get(in_bytes, 1)
    in_bytes_without_first_two = List.drop_first(in_bytes, 2)
    in_bytes_without_first_six = List.drop_first(in_bytes, 6)

    when Pair(first_byte, second_byte) is
        Pair(Ok(a), Ok(b)) if a == '\\' && b == 'u' ->
            # Extended json unicode escape
            when in_bytes_without_first_two is
                [c, d, e, f, ..] ->
                    utf8_bytes = hex_to_utf8(c, d, e, f)

                    replace_escaped_chars(
                        {
                            in_bytes: in_bytes_without_first_six,
                            out_bytes: List.concat(out_bytes, utf8_bytes),
                        },
                    )

                _ ->
                    # Invalid Unicode Escape
                    replace_escaped_chars(
                        {
                            in_bytes: in_bytes_without_first_two,
                            out_bytes: List.concat(out_bytes, unicode_replacement),
                        },
                    )

        Pair(Ok(a), Ok(b)) if a == '\\' && is_escaped_char(b) ->
            # Shorthand json unicode escape
            replace_escaped_chars(
                {
                    in_bytes: in_bytes_without_first_two,
                    out_bytes: List.append(out_bytes, escaped_char_from_json(b)),
                },
            )

        Pair(Ok(a), _) ->
            # Process next character
            replace_escaped_chars(
                {
                    in_bytes: List.drop_first(in_bytes, 1),
                    out_bytes: List.append(out_bytes, a),
                },
            )

        _ ->
            { in_bytes, out_bytes }

# JSON ARRAYS ------------------------------------------------------------------

decode_list = \elem_decoder ->
    Decode.custom(
        \bytes, json_fmt ->

            decode_elems = array_elem_decoder(elem_decoder, json_fmt)

            result =
                when List.walk_until(bytes, BeforeOpeningBracket(0), array_opening_help) is
                    AfterOpeningBracket(n) -> Ok(List.drop_first(bytes, n))
                    _ -> Err(ExpectedOpeningBracket)

            when result is
                Ok(elem_bytes) -> decode_elems(elem_bytes, [])
                Err(ExpectedOpeningBracket) -> { result: Err(TooShort), rest: bytes },
    )

array_elem_decoder = \elem_decoder, json_fmt ->

    decode_elems = \bytes, accum ->

        # Done't need a comma before the first element
        state =
            if List.is_empty(accum) then
                BeforeNextElement(0)
            else
                BeforeNextElemOrClosingBracket(0)

        when List.walk_until(bytes, state, array_closing_help) is
            AfterClosingBracket(n) ->
                # Eat remaining whitespace
                rest = List.drop_first(bytes, n)

                # Return List of decoded elements
                { result: Ok(accum), rest }

            BeforeNextElement(n) ->
                # Eat any whitespace before element
                elem_bytes = List.drop_first(bytes, n)

                # Decode current element
                { result, rest } = decode_potential_null(elem_bytes, elem_decoder, json_fmt)

                when result is
                    Ok(elem) ->
                        # Accumulate decoded value and walk to next element
                        # or the end of the list
                        decode_elems(rest, List.append(accum, elem))

                    Err(_) ->
                        # Unable to decode next element
                        { result: Err(TooShort), rest }

            BeforeNextElemOrClosingBracket(_) ->
                if List.is_empty(accum) then
                    # Handle empty lists
                    { result: Ok([]), rest: bytes }
                else
                    # Expected comma or closing bracket after last element
                    { result: Err(TooShort), rest: bytes }

    decode_elems

array_opening_help : ArrayOpeningState, U8 -> [Continue ArrayOpeningState, Break ArrayOpeningState]
array_opening_help = \state, byte ->
    when (state, byte) is
        (BeforeOpeningBracket(n), b) if is_whitespace(b) -> Continue(BeforeOpeningBracket((n + 1)))
        (BeforeOpeningBracket(n), b) if b == '[' -> Continue(AfterOpeningBracket((n + 1)))
        (AfterOpeningBracket(n), b) if is_whitespace(b) -> Continue(AfterOpeningBracket((n + 1)))
        _ -> Break(state)

array_closing_help : ArrayClosingState, U8 -> [Continue ArrayClosingState, Break ArrayClosingState]
array_closing_help = \state, byte ->
    when (state, byte) is
        (BeforeNextElemOrClosingBracket(n), b) if is_whitespace(b) -> Continue(BeforeNextElemOrClosingBracket((n + 1)))
        (BeforeNextElemOrClosingBracket(n), b) if b == ',' -> Continue(BeforeNextElement((n + 1)))
        (BeforeNextElemOrClosingBracket(n), b) if b == ']' -> Continue(AfterClosingBracket((n + 1)))
        (BeforeNextElement(n), b) if is_whitespace(b) -> Continue(BeforeNextElement((n + 1)))
        (BeforeNextElement(n), b) if b == ']' -> Continue(AfterClosingBracket((n + 1)))
        (AfterClosingBracket(n), b) if is_whitespace(b) -> Continue(AfterClosingBracket((n + 1)))
        _ -> Break(state)

is_whitespace = \b ->
    when b is
        ' ' | '\n' | '\r' | '\t' -> Bool.true
        _ -> Bool.false

ArrayOpeningState : [
    BeforeOpeningBracket U64,
    AfterOpeningBracket U64,
]

ArrayClosingState : [
    BeforeNextElemOrClosingBracket U64,
    BeforeNextElement U64,
    AfterClosingBracket U64,
]

# JSON OBJECTS -----------------------------------------------------------------

decode_record = \initial_state, step_field, finalizer ->
    Decode.custom(
        \bytes, @Json({ field_name_mapping, skip_missing_properties, null_decode_as_empty, empty_encode_as_null }) ->

            # Recursively build up record from object field:value pairs
            decode_fields = \record_state, bytes_before_field ->

                # Decode the JSON string field name
                { result: object_name_result, rest: bytes_after_field } =
                    Decode.decode_with(bytes_before_field, decode_string, utf8)

                # Count the bytes until the field value
                count_bytes_before_value =
                    when List.walk_until(bytes_after_field, BeforeColon(0), object_help) is
                        AfterColon(n) -> n
                        _ -> 0

                value_bytes = List.drop_first(bytes_after_field, count_bytes_before_value)

                when object_name_result is
                    Err(TooShort) ->
                        # Invalid object, unable to decode field name or find colon ':'
                        # after field and before the value
                        { result: Err(TooShort), rest: bytes }

                    Ok(object_name) ->
                        decode_attempt =
                            field_name =
                                from_object_name_using_map(object_name, field_name_mapping)

                            # Retrieve value decoder for the current field
                            when (step_field(record_state, field_name), skip_missing_properties) is
                                (Skip, should_skip) if should_skip == Bool.true ->
                                    # Count the bytes until the field value
                                    count_bytes_before_next_field =
                                        when List.walk_until(value_bytes, FieldValue(0), skip_field_help) is
                                            FieldValueEnd(n) -> n
                                            _ -> 0

                                    droped_value_bytes = List.drop_first(value_bytes, count_bytes_before_next_field)

                                    { result: Ok(record_state), rest: droped_value_bytes }

                                (Skip, _) ->
                                    { result: Ok(record_state), rest: value_bytes }

                                (Keep(value_decoder), _) ->
                                    # Decode the value using the decoder from the recordState
                                    decode_potential_null(value_bytes, value_decoder, @Json({ field_name_mapping, skip_missing_properties, null_decode_as_empty, empty_encode_as_null }))

                        # Decode the json value
                        try_decode(
                            decode_attempt,
                            \{ val: updated_record, rest: bytes_after_value } ->
                                # Check if another field or '}' for end of object
                                when List.walk_until(bytes_after_value, AfterObjectValue(0), object_help) is
                                    ObjectFieldNameStart(n) ->
                                        rest = List.drop_first(bytes_after_value, n)

                                        # Decode the next field and value
                                        decode_fields(updated_record, rest)

                                    AfterClosingBrace(n) ->
                                        rest = List.drop_first(bytes_after_value, n)

                                        # Build final record from decoded fields and values
                                        when finalizer(updated_record, utf8) is
                                            ## This step is where i can implement my special decoding of options
                                            Ok(val) -> { result: Ok(val), rest }
                                            Err(e) ->
                                                { result: Err(e), rest }

                                    _ ->
                                        # Invalid object
                                        { result: Err(TooShort), rest: bytes_after_value },
                        )

            count_bytes_before_first_field =
                when List.walk_until(bytes, BeforeOpeningBrace(0), object_help) is
                    ObjectFieldNameStart(n) -> n
                    _ -> 0

            if count_bytes_before_first_field == 0 then
                # Invalid object, expected opening brace '{' followed by a field
                { result: Err(TooShort), rest: bytes }
            else
                bytes_before_first_field = List.drop_first(bytes, count_bytes_before_first_field)

                # Begin decoding field:value pairs
                decode_fields(initial_state, bytes_before_first_field),
    )

skip_field_help : SkipValueState, U8 -> [Break SkipValueState, Continue SkipValueState]
skip_field_help = \state, byte ->
    when (state, byte) is
        (FieldValue(n), b) if b == '}' -> Break(FieldValueEnd(n))
        (FieldValue(n), b) if b == '[' -> Continue(InsideAnArray({ index: (n + 1), nesting: 0 }))
        (FieldValue(n), b) if b == '{' -> Continue(InsideAnObject({ index: (n + 1), nesting: 0 }))
        (FieldValue(n), b) if b == '"' -> Continue(InsideAString((n + 1)))
        (FieldValue(n), b) if b == ',' -> Break(FieldValueEnd(n))
        (FieldValue(n), _) -> Continue(FieldValue((n + 1)))
        # strings
        (InsideAString(n), b) if b == '\\' -> Continue(Escaped((n + 1)))
        (Escaped(n), _) -> Continue(InsideAString((n + 1)))
        (InsideAString(n), b) if b == '"' -> Continue(FieldValue((n + 1)))
        (InsideAString(n), _) -> Continue(InsideAString((n + 1)))
        # arrays
        (InsideAnArray({ index, nesting }), b) if b == '"' -> Continue(StringInArray({ index: index + 1, nesting }))
        (InsideAnArray({ index, nesting }), b) if b == '[' -> Continue(InsideAnArray({ index: index + 1, nesting: nesting + 1 }))
        (InsideAnArray({ index, nesting }), b) if nesting == 0 && b == ']' -> Continue(FieldValue((index + 1)))
        (InsideAnArray({ index, nesting }), b) if b == ']' -> Continue(InsideAnArray({ index: index + 1, nesting: nesting - 1 }))
        (InsideAnArray({ index, nesting }), _) -> Continue(InsideAnArray({ index: index + 1, nesting }))
        # arrays escape strings
        (StringInArray({ index, nesting }), b) if b == '\\' -> Continue(EcapdedStringInArray({ index: index + 1, nesting }))
        (EcapdedStringInArray({ index, nesting }), _) -> Continue(StringInArray({ index: index + 1, nesting }))
        (StringInArray({ index, nesting }), b) if b == '"' -> Continue(InsideAnArray({ index: index + 1, nesting }))
        (StringInArray({ index, nesting }), _) -> Continue(StringInArray({ index: index + 1, nesting }))
        # objects
        (InsideAnObject({ index, nesting }), b) if b == '"' -> Continue(StringInObject({ index: index + 1, nesting }))
        (InsideAnObject({ index, nesting }), b) if b == '{' -> Continue(InsideAnObject({ index: index + 1, nesting: nesting + 1 }))
        (InsideAnObject({ index, nesting }), b) if nesting == 0 && b == '}' -> Continue(FieldValue((index + 1)))
        (InsideAnObject({ index, nesting }), b) if b == '}' -> Continue(InsideAnObject({ index: index + 1, nesting: nesting - 1 }))
        (InsideAnObject({ index, nesting }), _) -> Continue(InsideAnObject({ index: index + 1, nesting }))
        # objects escape strings
        (StringInObject({ index, nesting }), b) if b == '\\' -> Continue(EncodedStringInObject({ index: index + 1, nesting }))
        (EncodedStringInObject({ index, nesting }), _) -> Continue(StringInObject({ index: index + 1, nesting }))
        (StringInObject({ index, nesting }), b) if b == '"' -> Continue(InsideAnObject({ index: index + 1, nesting }))
        (StringInObject({ index, nesting }), _) -> Continue(StringInObject({ index: index + 1, nesting }))
        _ -> Break(InvalidObject)

SkipValueState : [
    FieldValue U64,
    FieldValueEnd U64,
    InsideAString U64,
    InsideAnObject { index : U64, nesting : U64 },
    StringInObject { index : U64, nesting : U64 },
    EncodedStringInObject { index : U64, nesting : U64 },
    InsideAnArray { index : U64, nesting : U64 },
    StringInArray { index : U64, nesting : U64 },
    EcapdedStringInArray { index : U64, nesting : U64 },
    Escaped U64,
    InvalidObject,
]

object_help : ObjectState, U8 -> [Break ObjectState, Continue ObjectState]
object_help = \state, byte ->
    when (state, byte) is
        (BeforeOpeningBrace(n), b) if is_whitespace(b) -> Continue(BeforeOpeningBrace((n + 1)))
        (BeforeOpeningBrace(n), b) if b == '{' -> Continue(AfterOpeningBrace((n + 1)))
        (AfterOpeningBrace(n), b) if is_whitespace(b) -> Continue(AfterOpeningBrace((n + 1)))
        (AfterOpeningBrace(n), b) if b == '"' -> Break(ObjectFieldNameStart(n))
        (BeforeColon(n), b) if is_whitespace(b) -> Continue(BeforeColon((n + 1)))
        (BeforeColon(n), b) if b == ':' -> Continue(AfterColon((n + 1)))
        (AfterColon(n), b) if is_whitespace(b) -> Continue(AfterColon((n + 1)))
        (AfterColon(n), _) -> Break(AfterColon(n))
        (AfterObjectValue(n), b) if is_whitespace(b) -> Continue(AfterObjectValue((n + 1)))
        (AfterObjectValue(n), b) if b == ',' -> Continue(AfterComma((n + 1)))
        (AfterObjectValue(n), b) if b == '}' -> Continue(AfterClosingBrace((n + 1)))
        (AfterComma(n), b) if is_whitespace(b) -> Continue(AfterComma((n + 1)))
        (AfterComma(n), b) if b == '"' -> Break(ObjectFieldNameStart(n))
        (AfterClosingBrace(n), b) if is_whitespace(b) -> Continue(AfterClosingBrace((n + 1)))
        (AfterClosingBrace(n), _) -> Break(AfterClosingBrace(n))
        _ -> Break(InvalidObject)

ObjectState : [
    BeforeOpeningBrace U64,
    AfterOpeningBrace U64,
    ObjectFieldNameStart U64,
    BeforeColon U64,
    AfterColon U64,
    AfterObjectValue U64,
    AfterComma U64,
    AfterClosingBrace U64,
    InvalidObject,
]

# from_yelling_case = \str ->
#    Str.to_utf8(str)
#    |> List.map(to_lowercase)
#    |> Str.from_utf8
#    |> crash_on_bad_utf8_error

# Complex example from IETF RFC 8259 (2017)
# complex_example_json = Str.to_utf8("{\"Image\":{\"Animated\":false,\"Height\":600,\"Ids\":[116,943,234,38793],\"Thumbnail\":{\"Height\":125,\"Url\":\"http:\\/\\/www.example.com\\/image\\/481989943\",\"Width\":100},\"Title\":\"View from 15th Floor\",\"Width\":800}}")
# complex_example_record = {
#    image: {
#        width: 800,
#        height: 600,
#        title: "View from 15th Floor",
#        thumbnail: {
#            url: "http://www.example.com/image/481989943",
#            height: 125,
#            width: 100,
#        },
#        animated: Bool.false,
#        ids: [116, 943, 234, 38793],
#    },
# }

from_object_name_using_map : Str, FieldNameMapping -> Str
from_object_name_using_map = \object_name, field_name_mapping ->
    when field_name_mapping is
        Default -> object_name
        SnakeCase -> from_snake_case(object_name)
        PascalCase -> from_pascal_case(object_name)
        KebabCase -> from_kebab_case(object_name)
        CamelCase -> from_camel_case(object_name)
        Custom(transformation) -> transformation(object_name)

to_object_name_using_map : Str, FieldNameMapping -> Str
to_object_name_using_map = \field_name, field_name_mapping ->
    when field_name_mapping is
        Default -> field_name
        SnakeCase -> to_snake_case(field_name)
        PascalCase -> to_pascal_case(field_name)
        KebabCase -> to_kebab_case(field_name)
        CamelCase -> to_camel_case(field_name)
        Custom(transformation) -> transformation(field_name)

# Convert a `snake_case` JSON Object name to a Roc Field name
from_snake_case = \str ->
    snake_to_camel(str)

# Convert a `PascalCase` JSON Object name to a Roc Field name
from_pascal_case = \str ->
    pascal_to_camel(str)

# Convert a `kabab-case` JSON Object name to a Roc Field name
from_kebab_case = \str ->
    kebab_to_camel(str)

# Convert a `camelCase` JSON Object name to a Roc Field name
from_camel_case = \str ->
    # Nothing to change as Roc field names are camelCase by default
    str

# Convert a `camelCase` Roc Field name to a `snake_case` JSON Object name
to_snake_case = \str ->
    camel_to_snake(str)

# Convert a `camelCase` Roc Field name to a `PascalCase` JSON Object name
to_pascal_case = \str ->
    camel_to_pascal(str)

# Convert a `camelCase` Roc Field name to a `kabab-case` JSON Object name
to_kebab_case = \str ->
    camel_to_kebeb(str)

# Convert a `camelCase` Roc Field name to a `camelCase` JSON Object name
to_camel_case = \str ->
    # Nothing to change as Roc field names are camelCase by default
    str

snake_to_camel : Str -> Str
snake_to_camel = \str ->
    segments = Str.split_on(str, "_")
    when segments is
        [first, .. as rest] ->
            rest
            |> List.map(uppercase_first)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

pascal_to_camel : Str -> Str
pascal_to_camel = \str ->
    segments = Str.to_utf8(str)
    when segments is
        [a, .. as rest] ->
            first = to_lowercase(a)
            rest |> List.prepend(first) |> Str.from_utf8 |> crash_on_bad_utf8_error

        _ -> str

kebab_to_camel : Str -> Str
kebab_to_camel = \str ->
    segments = Str.split_on(str, "-")
    when segments is
        [first, .. as rest] ->
            rest
            |> List.map(uppercase_first)
            |> List.prepend(first)
            |> Str.join_with("")

        _ -> str

camel_to_pascal : Str -> Str
camel_to_pascal = \str ->
    segments = Str.to_utf8(str)
    when segments is
        [a, .. as rest] ->
            first = to_uppercase(a)
            rest |> List.prepend(first) |> Str.from_utf8 |> crash_on_bad_utf8_error

        _ -> str

camel_to_kebeb : Str -> Str
camel_to_kebeb = \str ->
    rest = Str.to_utf8(str)
    taken = List.with_capacity(List.len(rest))

    camel_to_kebab_help({ taken, rest })
    |> .taken
    |> Str.from_utf8
    |> crash_on_bad_utf8_error

camel_to_kebab_help : { taken : List U8, rest : List U8 } -> { taken : List U8, rest : List U8 }
camel_to_kebab_help = \{ taken, rest } ->
    when rest is
        [] -> { taken, rest }
        [a, ..] if is_upper_case(a) ->
            camel_to_kebab_help(
                {
                    taken: List.concat(taken, ['-', to_lowercase(a)]),
                    rest: List.drop_first(rest, 1),
                },
            )

        [a, ..] ->
            camel_to_kebab_help(
                {
                    taken: List.append(taken, a),
                    rest: List.drop_first(rest, 1),
                },
            )

camel_to_snake : Str -> Str
camel_to_snake = \str ->
    rest = Str.to_utf8(str)
    taken = List.with_capacity(List.len(rest))

    camel_to_snake_help({ taken, rest })
    |> .taken
    |> Str.from_utf8
    |> crash_on_bad_utf8_error

camel_to_snake_help : { taken : List U8, rest : List U8 } -> { taken : List U8, rest : List U8 }
camel_to_snake_help = \{ taken, rest } ->
    when rest is
        [] -> { taken, rest }
        [a, ..] if is_upper_case(a) ->
            camel_to_snake_help(
                {
                    taken: List.concat(taken, ['_', to_lowercase(a)]),
                    rest: List.drop_first(rest, 1),
                },
            )

        [a, ..] ->
            camel_to_snake_help(
                {
                    taken: List.append(taken, a),
                    rest: List.drop_first(rest, 1),
                },
            )

uppercase_first : Str -> Str
uppercase_first = \str ->
    segments = Str.to_utf8(str)
    when segments is
        [a, .. as rest] ->
            first = to_uppercase(a)
            rest |> List.prepend(first) |> Str.from_utf8 |> crash_on_bad_utf8_error

        _ -> str

to_uppercase : U8 -> U8
to_uppercase = \codeunit ->
    if 'a' <= codeunit && codeunit <= 'z' then
        codeunit - (32) # 32 is the difference to the respecive uppercase letters
    else
        codeunit

to_lowercase : U8 -> U8
to_lowercase = \codeunit ->
    if 'A' <= codeunit && codeunit <= 'Z' then
        codeunit + 32 # 32 is the difference to the respecive lowercase letters
    else
        codeunit

is_upper_case : U8 -> Bool
is_upper_case = \codeunit ->
    'A' <= codeunit && codeunit <= 'Z'

eat_whitespace : List U8 -> List U8
eat_whitespace = \bytes ->
    when bytes is
        [a, ..] if is_whitespace(a) -> eat_whitespace(List.drop_first(bytes, 1))
        _ -> bytes

crash_on_bad_utf8_error : Result Str _ -> Str
crash_on_bad_utf8_error = \res ->
    when res is
        Ok(str) -> str
        Err(_) -> crash("invalid UTF-8 code units")

null_chars = "null" |> Str.to_utf8

## Returns `Null` if the input starts with "null"
## If make_null_empty is true Null{bytes} will be empty
null_to_empty : List U8, Bool -> [Null _, NotNull]
null_to_empty = \bytes, make_null_empty ->
    when bytes is
        ['n', 'u', 'l', 'l', .. as rest] ->
            if make_null_empty then
                Null({ bytes: [], rest })
            else
                Null({ bytes: null_chars, rest })

        _ -> NotNull

empty_to_null : List U8, Bool -> List U8
empty_to_null = \bytes, make_empty_null ->
    if bytes == [] && make_empty_null then
        null_chars
    else
        bytes

## If the field value is "null" we may want to make it the same as the field simply not being there for decoding simplicity
decode_potential_null = \bytes, decoder, @Json(json_fmt) ->
    when null_to_empty(bytes, json_fmt.null_decode_as_empty) is
        Null({ bytes: null_bytes, rest: null_rest }) ->
            decode = Decode.decode_with(null_bytes, decoder, @Json(json_fmt))
            # We have to replace the rest because if the null was converted to empty the decoder would return an empty rest
            { result: decode.result, rest: null_rest }

        NotNull ->
            Decode.decode_with(bytes, decoder, @Json(json_fmt))
