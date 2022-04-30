module VerifyExamples.Accessors.Library.DictEntry3 exposing (..)

-- This file got generated by [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples).
-- Please don't modify this file by hand!

import Test
import Expect

import Accessors.Library exposing (..)
import Lens as L
import Accessors.Library exposing (..)
import Accessors exposing (..)
import Dict exposing (Dict)



dict : Dict String {bar : Int}
dict = Dict.fromList [("foo", {bar = 2})]



spec3 : Test.Test
spec3 =
    Test.test "#dictEntry: \n\n    get (dictEntry \"baz\") dict\n    --> Nothing" <|
        \() ->
            Expect.equal
                (
                get (dictEntry "baz") dict
                )
                (
                Nothing
                )