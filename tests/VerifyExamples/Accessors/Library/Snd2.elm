module VerifyExamples.Accessors.Library.Snd2 exposing (..)

-- This file got generated by [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples).
-- Please don't modify this file by hand!

import Test
import Expect

import Accessors.Library exposing (..)
import Accessors.Library exposing (..)
import Accessors exposing (..)



meh : (String, Int)
meh = ("It's over", 1)



spec2 : Test.Test
spec2 =
    Test.test "#snd: \n\n    get snd meh\n    --> 1" <|
        \() ->
            Expect.equal
                (
                get snd meh
                )
                (
                1
                )