open Gillian.Debugger

module SMemory =
  Gillian.Symbolic.Legacy_s_memory.Modernize (WSemantics.WislSMemory)

module CLI =
  Gillian.Command_line.Make
    (Gillian.General.Init_data.Dummy)
    (WSemantics.WislCMemory)
    (SMemory)
    (WParserAndCompiler)
    (Gillian.General.External.Dummy (WParserAndCompiler.Annot))
    (Gillian.Bulk.Runner.DummyRunners)
    (Lifter.Gil_fallback_lifter.Make (SMemory) (WParserAndCompiler)
       (WDebugging.WislLifter.Make))

let () = CLI.main ()
