module CLI =
  Gillian.CommandLine.Make (WSemantics.WislCMemory) (WSemantics.WislSMemory)
    (Gillian.General.External.Dummy)
    (WParserAndCompiler)
    (Gillian.Bulk.Runner.DummyRunners)
    (WDebugging.WislDisplayFilter)
    (WDebugging.WislSMemoryDisplayable)
    (WDebugging.WislStoreAndSMemoryLifter)
    (WDebugging.WislMemoryErrorLifter)

let () = CLI.main ()
