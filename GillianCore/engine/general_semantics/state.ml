(** @canonical Gillian.General.State

  Interface for GIL General States.
  
  They are considered to be mutable. *)

(** @canonical Gillian.General.State.S *)
module type S = sig
  (** Type of GIL values *)
  type vt [@@deriving yojson, show]

  (** Type of GIL general states *)
  type t [@@deriving yojson]

  (** Type of GIL substitutions *)
  type st

  (** Type of GIL stores *)
  type store_t

  type heap_t

  (** Errors *)
  type m_err_t

  type err_t = (m_err_t, vt) StateErr.t [@@deriving yojson, show]
  type fix_t

  exception Internal_State_Error of err_t list * t

  type action_ret = (t * vt list, err_t) Res_list.t
  type variants_t = (string, Expr.t option) Hashtbl.t [@@deriving yojson]
  type init_data

  val execute_action : ?unification:bool -> string -> t -> vt list -> action_ret
  val ga_to_setter : string -> string
  val ga_to_getter : string -> string
  val ga_to_deleter : string -> string
  val get_pred_defs : t -> UP.preds_tbl_t option
  val is_overlapping_asrt : string -> bool

  (** Expression Evaluation *)
  val eval_expr : t -> Expr.t -> vt

  (** Get store of given symbolic state *)
  val get_store : t -> store_t

  (** Set store of given symbolic state *)
  val set_store : t -> store_t -> t

  (** Assume expression *)
  val assume : ?unfold:bool -> t -> vt -> t list

  (** Assume assertion *)
  val assume_a :
    ?unification:bool ->
    ?production:bool ->
    ?time:string ->
    t ->
    Formula.t list ->
    t option

  (** Assume type *)
  val assume_t : t -> vt -> Type.t -> t option

  (** Satisfiability check *)
  val sat_check : t -> vt -> bool

  val sat_check_f : t -> Formula.t list -> st option

  (** Assert assertion *)
  val assert_a : t -> Formula.t list -> bool

  (** Value Equality *)
  val equals : t -> vt -> vt -> bool

  val get_type : t -> vt -> Type.t option

  (** State simplification *)
  val simplify :
    ?save:bool -> ?kill_new_lvars:bool -> ?unification:bool -> t -> st * t list

  (** Value simplification *)
  val simplify_val : t -> vt -> vt

  (** Convert value to object location, with possible allocation *)
  val to_loc : t -> vt -> (t * vt) option

  val fresh_loc : ?loc:vt -> t -> vt

  (** Printers *)
  val pp : Format.formatter -> t -> unit

  val pp_by_need :
    Containers.SS.t ->
    Containers.SS.t ->
    Containers.SS.t ->
    Format.formatter ->
    t ->
    unit

  val pp_err : Format.formatter -> err_t -> unit
  val pp_fix : Format.formatter -> fix_t -> unit
  val get_recovery_tactic : t -> err_t list -> vt Recovery_tactic.t

  (** State Copy *)
  val copy : t -> t

  (** Add Spec Var *)
  val add_spec_vars : t -> Var.Set.t -> t

  (** Get Spec Vars *)
  val get_spec_vars : t -> Var.Set.t

  (** Get all logical variables *)
  val get_lvars : t -> Var.Set.t

  (** Turns a state into a list of assertions *)
  val to_assertions : ?to_keep:Containers.SS.t -> t -> Asrt.t list

  val evaluate_slcmd : 'a UP.prog -> SLCmd.t -> t -> (t, err_t) Res_list.t

  (** [unify_invariant prog revisited state invariant binders] returns a list of pairs of states.
      In each pair, the first element is the framed off state, and the second one is the invariant,
      i.e. the state obtained by producing the invariant *)
  val unify_invariant :
    'a UP.prog ->
    bool ->
    t ->
    Asrt.t ->
    string list ->
    (t * t, err_t) Res_list.t

  val frame_on : t -> (string * t) list -> string list -> (t, err_t) Res_list.t

  val run_spec :
    UP.spec ->
    t ->
    string ->
    vt list ->
    (string * (string * vt) list) option ->
    (t * Flag.t, err_t) Res_list.t

  val unfolding_vals : t -> Formula.t list -> vt list
  val try_recovering : t -> vt Recovery_tactic.t -> (t list, string) result
  val substitution_in_place : ?subst_all:bool -> st -> t -> t list
  val clean_up : ?keep:Expr.Set.t -> t -> unit
  val unify_assertion : t -> st -> UP.step -> (t, err_t) Res_list.t
  val produce_posts : t -> st -> Asrt.t list -> t list
  val produce : t -> st -> Asrt.t -> (t, err_t) Res_list.t
  val update_subst : t -> st -> unit
  val mem_constraints : t -> Formula.t list
  val can_fix : err_t -> bool
  val get_failing_constraint : err_t -> Formula.t
  val get_fixes : t -> err_t -> fix_t list list
  val apply_fixes : t -> fix_t list -> t list
  val get_equal_values : t -> vt list -> vt list
  val get_heap : t -> heap_t
end
