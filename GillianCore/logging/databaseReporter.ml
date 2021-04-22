(* let filename = "./database.log"

let fd = ref None

let initialize () =
  let () = if Sys.file_exists filename then Sys.remove filename else () in
  (* rw-r--r-- *)
  let permissions = 0o644 in
  fd := Some (Unix.openfile filename [ O_WRONLY; O_APPEND; O_CREAT ] permissions)

let log report  =
  let yojson = Yojson.Safe.to_string report in
  match !fd with
  | None -> ()
  | Some fd ->
    Unix.lockf fd F_LOCK 0;
    ignore (Unix.write_substring fd yojson 0 (String.length yojson));
    Unix.lockf fd F_ULOCK 0

let log_specific loggable report =
  let yojson = Report.to_yojson (Loggable.to_yojson loggable) report in
  let yojson = Yojson.Safe.to_string yojson in
  match !fd with
  | None -> ()
  | Some fd ->
    Unix.lockf fd F_LOCK 0;
    ignore (Unix.write_substring fd yojson 0 (String.length yojson));
    Unix.lockf fd F_ULOCK 0

let wrap_up () =
  match !fd with
  | None -> ()
  | Some fd -> Unix.close fd *)

module Types = struct
  type conf = { filename : string }

  type state = { fd : Unix.file_descr }
end

include Reporter.Make (struct
  include Types

  let conf =
    let filename = "database.log" in
    if Sys.file_exists filename then Sys.remove filename;
    { filename }

  let initialize { filename } =
    (* rw-r--r-- *)
    let perm = 0o644 in
    { fd = Unix.openfile filename [ O_WRONLY; O_APPEND; O_CREAT ] perm }

  let wrap_up { fd } = Unix.close fd
end)

let get_fd () = (get_state ()).fd

let write yojson =
  let yojson = Yojson.Safe.to_string yojson ^ "\n" in
  Unix.lockf (get_fd ()) F_LOCK 0;
  ignore (Unix.write_substring (get_fd ()) yojson 0 (String.length yojson));
  Unix.lockf (get_fd ()) F_ULOCK 0

class virtual t =
  object
    method log (report : Report.t) =
      if enabled () then
        match report.type_ with
        | Store -> write (Report.to_yojson report)
        | _     -> ()

    method wrap_up = wrap_up ()
  end

let default : unit -> t =
 fun () ->
  object
    inherit t
  end
