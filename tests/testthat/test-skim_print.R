context("Print a skim_df object")

test_that("Skim prints a header for the entire output and each type", {
  withr::local_options(list(cli.unicode = FALSE))
  skip_if_not(l10n_info()$`UTF-8`)
  input <- skim(iris)
  expect_print_matches_file(input, "print/default.txt")

  input$numeric.hist <- NULL
  expect_print_matches_file(input, "print/no-hist.txt",
    skip_on_windows = FALSE
  )
})

test_that("Skim prints a special header for grouped data frames", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  input <- skim(dplyr::group_by(iris, Species))
  expect_print_matches_file(input, "print/groups.txt")
})

test_that("Skim lists print as expected", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  input <- partition(skimmed)
  expect_print_matches_file(input, "print/list.txt")
})

test_that("knit_print produces expected results", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  input <- knit_print(skimmed)
  expect_s3_class(input, "knit_asis")
  expect_length(input, 1)
  if (packageVersion("knitr") <= "1.28") {
    expect_matches_file(input, "print/knit_print-knitr_old.txt")
  } else {
    expect_matches_file(input, "print/knit_print.txt")
  }
})

test_that("knit_print works with skim summaries", {
   withr::local_options(list(cli.unicode = FALSE))
    skimmed <- skim(iris)
    summarized <- summary(skimmed)
    input <- knitr::knit_print(summarized)
    if (packageVersion("knitr") <= "1.28") {
      expect_matches_file(input, "print/knit_print-summary-knitr_old.txt")
    } else {
  expect_matches_file(input, "print/knit_print-summary.txt")
  }
})

test_that("knit_print appropriately falls back to tibble printing", {
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  reduced <- dplyr::select(skimmed, skim_variable, numeric.mean)
  if (packageVersion("dplyr") <= "0.8.5") {
    expect_known_output(
      input <- knitr::knit_print(reduced),
      "print/knit_print-fallback.txt"
    )
  } else {
    expect_known_output(
      input <- knitr::knit_print(reduced),
      "print/knit_print-fallback-dplyrv1.txt"
    )
  }
  expect_s3_class(input, "data.frame")
})

test_that("Summaries can be suppressed within knitr", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  options <- list(skimr_include_summary = FALSE)
  input <- knitr::knit_print(skimmed, options = options)
  expect_matches_file(input, "print/knit_print-suppressed.txt")
})

test_that("Skim lists have a separate knit_print method", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  skim_list <- partition(skimmed)
  input <- knit_print(skim_list)
  expect_matches_file(input, "print/knit_print-skim_list.txt")
})

test_that("You can yank a type from a skim_df and call knit_print", {
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  skim_one <- yank(skimmed, "factor")
  input <- knit_print(skim_one)
  expect_matches_file(input, "print/knit_print-yank.txt")
})

test_that("make_utf8 produces the correct result ", {
  withr::local_options(list(cli.unicode = FALSE))
  input <- make_utf8(c("<U+2585><U+2587>"))
  correct <- "▅"
  expect_identical(input, correct)
})

test_that("Skim falls back to tibble::print.tbl() appropriately", {
  withr::local_options(list(cli.unicode = FALSE))
  input <- skim(iris)
  mean_only <- dplyr::select(input, numeric.mean)
  if (packageVersion("dplyr") <= "0.8.5") {
    expect_print_matches_file(mean_only, "print/fallback.txt")
  } else {
    expect_print_matches_file(mean_only, "print/fallback_dplyrv1.txt")
  }
})

test_that("Print focused objects appropriately", {
  withr::local_options(list(cli.unicode = FALSE))
  skip_if_not(l10n_info()$`UTF-8`)
  skimmed <- skim(iris)
  input <- focus(skimmed, n_missing)
  expect_print_matches_file(input, "print/focus.txt")
})

test_that("Metadata is stripped from smaller consoles", {
  withr::local_options(list(cli.unicode = FALSE))
  skip_if_not(l10n_info()$`UTF-8`)
  skimmed <- skim(iris)
  expect_print_matches_file(skimmed, "print/smaller.txt", width = 50)
})

test_that("Crayon is supported", {
  skip("Temporary skip due to issues with crayon support on some platforms")
  withr::local_options(list(cli.unicode = FALSE))
  withr::with_options(list(crayon.enabled = TRUE), {
    with_mock(
      .env = "skimr",
      render_skim_body = function(...) {
        paste0(..., sep = "\n", collapse = "\n")
      },
      {
        skimmed <- skim(iris)
        numeric <- yank(skimmed, "numeric")
        rendered <- print(numeric)
      }
    )
    expect_match(rendered, "\\\033")
  })
})

test_that("skimr creates appropriate output for Jupyter", {
  withr::local_options(list(cli.unicode = FALSE))
  skip_if_not(l10n_info()$`UTF-8`)
  skimmed <- skim(iris)
  expect_known_output(repr_text(skimmed), "print/repr.txt")
})

test_that("Metadata can be included: print", {
  withr::local_options(list(cli.unicode = FALSE))
  skip_if_not(l10n_info()$`UTF-8`)
  skimmed <- skim(iris)
  expect_known_output(print(skimmed, strip_metadata = FALSE), "print/strip.txt")
})


test_that("Metadata can be included: option", {
  skip_if_not(l10n_info()$`UTF-8`)
  withr::local_options(list(cli.unicode = FALSE))
  skimmed <- skim(iris)
  withr::with_options(list(skimr_strip_metadata = FALSE), {
    expect_known_output(print(skimmed), "print/strip-opt.txt")
  })
})
