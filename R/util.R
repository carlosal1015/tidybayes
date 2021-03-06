# Utility functions for tidybayes
#
# Author: mjskay
###############################################################################


# deparse that is guaranteed to return a single string (instead of
# a list of strings if the expression goes to multiple lines)
deparse0 = function(expr, width.cutoff = 500, ...) {
  paste0(deparse(expr, width.cutoff = width.cutoff, ...), collapse = "")
}

# Based on https://stackoverflow.com/a/14838753
# Escapes a string for inclusion in a regex
escape_regex = function(string) {
  gsub("(\\W)", "\\\\\\1", string)
}

combine_chains_for_deprecated_ = function(x) {
  x$.chain = NA_integer_
  x$.iteration = x$.draw
  x$.draw = NULL
  x
}

draw_from_chain_and_iteration_ = function(chain, iteration) {
  max_iteration = max(iteration)
  as.integer(ifelse(is.na(chain), 0, chain - 1) * max_iteration + iteration)
}

# get all variable names from an expression
# based on http://adv-r.had.co.nz/dsl.html
all_names = function(x) {
  if (is.atomic(x)) {
    NULL
  } else if (is.name(x)) {
    name = as.character(x)
    if (name == "") {
      NULL
    }
    else {
      name
    }
  } else if (is.call(x) || is.pairlist(x)) {
    children = lapply(x[-1], all_names)
    unique(unlist(children))
  } else {
    stop("Don't know how to handle type `", typeof(x), "`",
      call. = FALSE)
  }
}


# deprecations and warnings -----------------------------------------------

#' @importFrom rlang enexprs
.Deprecated_arguments = function(old_names, ..., message = "", which = -1, fun = as.character(sys.call(which))[[1]]) {
  deprecated_args = intersect(old_names, names(enexprs(...)))

  if (length(deprecated_args) > 0) {
    stop(
      "\nIn ", fun, "(): The `", deprecated_args[[1]], "` argument is deprecated.\n",
      message,

      call. = FALSE
    )
  }
}

.Deprecated_argument_alias = function(new_arg, old_arg, which = -1, fun = as.character(sys.call(which))[[1]]) {
  if (missing(old_arg)) {
    new_arg
  } else {
    new_name = quo_name(enquo(new_arg))
    old_name = quo_name(enquo(old_arg))

    warning(
      "\nIn ", fun, "(): The `", old_name, "` argument is a deprecated alias for `",
      new_name, "`.\n",
      "Use the `", new_name, "` argument instead.\n",
      "See help(\"tidybayes-deprecated\").\n",

      call. = FALSE
    )

    old_arg
  }
}

stop_on_non_generic_arg_ = function(parent_dot_args, method_type, ..., which = -1, fun = as.character(sys.call(which))[[1]]) {
  old_args = list(...)

  if (any(parent_dot_args %in% old_args)) {
    non_generic_args_passed = intersect(parent_dot_args, old_args)
    non_generic_arg_passed = non_generic_args_passed[[1]]

    stop(
      "In ", fun, "(): ",
      "The argument `", non_generic_arg_passed,
      "` is not supported in `",
      method_type,
      "`. Please use the generic argument `",
      names(old_args)[old_args == non_generic_arg_passed],
      "`. See the documentation for additional details.\n",

      call. = FALSE
    )
  }
}
