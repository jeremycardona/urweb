(* Copyright (c) 2008, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *)

(* Laconic/Web language parser *)

structure Compiler :> COMPILER = struct 

structure LacwebLrVals = LacwebLrValsFn(structure Token = LrParser.Token)
structure Lex = LacwebLexFn(structure Tokens = LacwebLrVals.Tokens)
structure LacwebP = Join(structure ParserData = LacwebLrVals.ParserData
                         structure Lex = Lex
                         structure LrParser = LrParser)

(* The main parsing routine *)
fun parse filename =
    let
        val () = (ErrorMsg.resetErrors ();
                  ErrorMsg.resetPositioning filename)
	val file = TextIO.openIn filename
	fun get _ = TextIO.input file
	fun parseerror (s, p1, p2) = ErrorMsg.errorAt' (p1, p2) s
	val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
	val (absyn, _) = LacwebP.parse (30, lexer, parseerror, ())
    in
        TextIO.closeIn file;
        SOME absyn
    end
    handle LrParser.ParseError => NONE

fun testParse filename =
    case parse filename of
        NONE => print "Parse error\n"
      | SOME file =>
        if ErrorMsg.anyErrors () then
            print "Recoverable parse error\n"
        else
            (Print.print (SourcePrint.p_file file);
             print "\n")

end
